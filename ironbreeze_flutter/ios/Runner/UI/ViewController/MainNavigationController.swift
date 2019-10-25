//
//  MainNavigationController.swift
//  Runner
//
//  Created by Perry Shalom on 23/01/2019.
//  Copyright © 2019 perrchick. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    static private(set) weak var shared: MainNavigationController?
    lazy var splashView: SplashView = SplashView.instantiateFromNib()
    private var flutterReadyObserver: NotificationObserver?
    var start: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        MainNavigationController.shared = self
        isNavigationBarHidden = true
        
        flutterReadyObserver = NotificationObserver.newObserverForNotificationWithName(name: Notification.Name.ON_FLUTTER_IS_READY, object: nil, usingBlock: { [weak self] (_) in
            self?.splashView.beGone()
        })

        view.addSubview(splashView)
        splashView.stretchToSuperViewEdges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if splashView.isPresented {
            splashView.begin()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)

        if motion == .motionShake {
            AppDelegate.shared.onDeviceShook()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait //[.portraitUpsideDown, .portrait]
    }
    
    func showLastCrashifExists() {
        if PerrFuncs.isRunningUnderDevelopmentEnvironment() {
            if let lastCrashCallStack: [String] = UserDefaults.load(key: Configurations.Keys.Persistency.LastCrash) {
                UIAlertController.makeAlert(title: "last crash", message: "\(lastCrashCallStack)")
                    .withAction(UIAlertAction(title: "fine", style: .cancel, handler: nil))
                    .withAction(UIAlertAction(title: "delete", style: .destructive, handler: { (alertAction) in
                        UserDefaults.remove(key: Configurations.Keys.Persistency.LastCrash).synchronize()
                    }))
                    .show()
            }
        }
    }
}
