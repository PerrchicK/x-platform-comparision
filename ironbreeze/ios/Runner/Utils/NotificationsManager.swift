//
//  NotificationsManager.swift
//  Runner
//
//  Created by Perry Shalom on 12/05/2019.
//  Copyright © 2019 perrchick. All rights reserved.
//

import Foundation
//import UserNotificationsUI
import UserNotifications

class NotificationsManager {
    static let shared = NotificationsManager()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onApplicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onApplicationEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func onApplicationEnterBackground() {
//        authorizationStatus = nil
    }

    @objc func onApplicationEnterForeground() {
//        localNotificationsPermissionsStatus { _ in
//            📗(NotificationsManager.shared.authorizationStatus)
//        }
    }

    @discardableResult
    func showLocalNotification(withTitle alertTitle: String, alertBody: String, onTime popTime: Date = Date(timeIntervalSinceNow: 5), soundFileName: String? = nil, additionalInfo: [AnyHashable:Any]? = nil) -> Bool {
        return NotificationsManager.showLocalNotification(withTitle: alertTitle, alertBody: alertBody, onTime: popTime, soundFileName: soundFileName, additionalInfo: additionalInfo)
    }

    @discardableResult
    static func showLocalNotification(withTitle alertTitle: String, alertBody: String, onTime popTime: Date = Date(timeIntervalSinceNow: 5), soundFileName: String? = nil, additionalInfo: [AnyHashable:Any]? = nil) -> Bool {
        
        let content = UNMutableNotificationContent()
        content.title = alertTitle //NSString.localizedUserNotificationString(forKey: "Elon said:", arguments: nil)
        content.body = alertBody//NSString.localizedUserNotificationString(forKey: "Hello Tom！Get up, let's play with Jerry!", arguments: nil)
        if let additionalInfo = additionalInfo {
            content.userInfo = additionalInfo
        }

        if let soundFileName = soundFileName {
            if soundFileName.isEmpty {
                content.sound = UNNotificationSound.default
            } else {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(soundFileName))
            }
        }

        if PerrFuncs.isRunningOnUiThread {
//            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        }

        content.categoryIdentifier = "com.ironbreeze.alerts"

        let deltaFromNow = popTime.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: deltaFromNow, repeats: false)
        let request = UNNotificationRequest(identifier: "com.ironBreeze.alert", content: content, trigger: trigger)
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)

        return true
    }

    func isAuthorizedToShowLocalNotifications(callback: @escaping CallbackClosure<Bool>) {
        localNotificationsPermissionsStatus { (authorizationStatus) in
            callback(authorizationStatus == UNAuthorizationStatus.authorized)
        }
    }

    func localNotificationsPermissionsStatus(callback: @escaping CallbackClosure<UNAuthorizationStatus>) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            callback(settings.authorizationStatus)
        }
    }

    static func requestPermissionsForLocalNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
            AppDelegate.shared.callFlutter(methodName: "local_notifications_permissions_changed")
        }
    }
    
//    func auth() {
//        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//        UNAuthorizationOptions authorizationOptions = 0;
//        if (requestedSoundPermission) {
//            authorizationOptions += UNAuthorizationOptionSound;
//        }
//        if (requestedAlertPermission) {
//            authorizationOptions += UNAuthorizationOptionAlert;
//        }
//        if (requestedBadgePermission) {
//            authorizationOptions += UNAuthorizationOptionBadge;
//        }
//        [center requestAuthorizationWithOptions:(authorizationOptions) completionHandler:^(BOOL granted, NSError * _Nullable error) {
//            if(launchPayload != nil) {
//            [FlutterLocalNotificationsPlugin handleSelectNotification:launchPayload];
//            }
//            result(@(granted));
//            }];
//    }
}
