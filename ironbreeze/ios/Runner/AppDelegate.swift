import UIKit
import Flutter
import CoreData
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var isFlutterReady: Bool = false {
        didSet {
            guard isFlutterReady else { return }

            PerrFuncs.runBlockAfterDelay(afterDelay: 0.5) { // Otherwise we're gonna have an endless call
                AppDelegate.shared.callFlutterPendingMethods()
            }
        }
    }
    lazy var flutterPendingMethods: [MethodCall] = []
    lazy var flutterViewController: FlutterViewController = FlutterViewController.instantiate();
    lazy var methodChannel = FlutterMethodChannel(name: "main.ironbreeze/flutter_channel", binaryMessenger: flutterViewController)
    private(set) var isConnectedToTheInternet = true {
        didSet {
            if isConnectedToTheInternet {
                //NotificationCenter.
            }
        }
    }

    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    // MARK: - Application Lifecycle Events

    override func application (_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool {

        isFlutterReady = false

        GeneratedPluginRegistrant.register(with: flutterViewController)
        flutterViewController.observeMethodChannel(onFlutterCall: onFlutterCall)

        initReachability()

        if PerrFuncs.isRunningUnderDevelopmentEnvironment() {
            NSSetUncaughtExceptionHandler { (exception) in
                UserDefaults.save(value: exception.callStackSymbols, forKey: "last crash").synchronize()
            }
        }

        UNUserNotificationCenter.current().delegate = self

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        super.application(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)

        callFlutter(methodName: "application_entered_foreground")
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        super.applicationDidEnterBackground(application)

        callFlutter(methodName: "application_entered_background")
    }

    // MARK: - Core Data stack

    // Lazy instantiation variable - will be allocated (and initialized) only once
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.perrchick.SomeApp" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "SomeApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error {
            // Report any error we got.
            let wrappedError = NSError.create(errorDomain: "YOUR_ERROR_DOMAIN", errorCode: 9999, description: "Failed to initialize the application's saved data", failureReason: "There was an error creating or loading the application's saved data.", underlyingError: error)

            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator: NSPersistentStoreCoordinator = persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func initReachability() {
        Reachability.shared?.whenReachable = { _ in
            PerrFuncs.runOnUiThread(block: {
                AppDelegate.shared.isConnectedToTheInternet = true
            })
        }
        Reachability.shared?.whenUnreachable = { _ in
            PerrFuncs.runOnUiThread(block: {
                AppDelegate.shared.isConnectedToTheInternet = false
            })
        }
        try? Reachability.shared?.startNotifier()
    }

    func onDeviceShook() {
        //ToastMessage.show(messageText: "Device Shook")
        PageNavigationController.shared?.toggleMap()
        UtilsObjC.showFlex()
        if PerrFuncs.isRunningUnderDevelopmentEnvironment() {
            LocationHelper.shared.fetchLocation { (location) in
                ToastMessage.show(messageText: "location: \(location?.coordinate.toLocationCoordinate().toString() ?? "nil")")
            }
        }
    }

    //MARK: - Flutter Method Channel

    func callFlutter(methodName: String, arguments: Any? = nil, callback: CallbackClosure<Any?>? = nil) {
        if (isFlutterReady) {
            flutterViewController.callFlutter(methodName: methodName, arguments: arguments, callback: callback)
        } else {
            flutterPendingMethods.append(MethodCall(methodName: methodName, arguments: arguments, callback: callback))
        }
    }

    func callFlutterPendingMethods() {
        flutterPendingMethods.forEach {
            callFlutter(methodName: $0.methodName, arguments: $0.arguments, callback: $0.callback)
        }

        flutterPendingMethods.removeAll()
    }

//    private lazy var _onFlutterCall: ((FlutterMethodCall, FlutterResult) -> Void) = {
//        return
//    }()

    func onDeepLinkPressed(urlString: String = "ironbreeze://blah-blah") {
        flutterViewController.callFlutter(methodName: "on_deep_link_pressed", arguments: ["url":urlString], callback: { result in
            📗(result)
        })
    }

    func showMap() {
        PageNavigationController.shared?.showMap()
    }

    func showMainScreen() {
        PageNavigationController.shared?.showMainScreen()
    }
}

// https://fluffy.es/perform-action-notification-tap/
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // This function will be called when the app receive notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // show the notification alert (banner), and with sound
        completionHandler([.alert, .sound])
    }
    
    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo

        if let eventName = userInfo["analytics_event"] as? String {
            callFlutter(methodName: "send_analytics_event", arguments: ["event_name": eventName])
        }

        // tell the app that we have finished processing the user’s action / response
        completionHandler()
    }
}

class MethodCall {
    let methodName: String
    let arguments: Any?
    var callback: CallbackClosure<Any?>? = nil

    init(methodName: String, arguments: Any?, callback: CallbackClosure<Any?>? = nil) {
        self.methodName = methodName
        self.arguments = arguments
        self.callback = callback
    }
}

extension PerrFuncs {
    static func debugToast(message: String) {
        guard PerrFuncs.isRunningUnderDevelopmentEnvironment() else { return }

        ToastMessage.show(messageText: message)
    }
}
