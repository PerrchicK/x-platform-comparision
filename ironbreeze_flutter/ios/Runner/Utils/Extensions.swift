//
//  Extensions.swift
//  Runner
//
//  Created by Perry Shalom on 23/01/2019.
//  Copyright © 2019 perrchick. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    func toLocationCoordinate() -> LocationCoordinate {
        return LocationCoordinate(latitude: latitude, longitude: longitude)
    }
    
    func toLocation() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension LocationCoordinate {
    func toLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension NotificationCenter {
    static func notify(notificationName: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
    }
}

extension Notification.Name {
    static let UPDATE_LOCATION: Notification.Name = Notification.Name("com.ironBreeze.notification.name.UPDATE_LOCATION")
    static let ON_FLUTTER_IS_READY: Notification.Name = Notification.Name("com.ironBreeze.notification.name.ON_FLUTTER_IS_READY")
}
extension Date {
    
    /// The timestamp in milliseconds
    var timestamp: Timestamp {
        // Attempting to fix crash by calling `.rounded()` method, the solution taken from: https://stackoverflow.com/questions/40134323/date-to-milliseconds-and-back-to-date-in-swift
        return UInt64((timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: UInt64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    func toString(dateFormat: String = "yyyy-MM-dd HH:mm:ss:SSS") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        let timesamp = formatter.string(from: Date())
        
        return timesamp
    }
}

extension Timestamp {
    static var now: Timestamp {
        return Date().timestamp
    }
    
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1000)
    }
}
