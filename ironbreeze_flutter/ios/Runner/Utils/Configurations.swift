//
//  Configurations.swift
//  SomeApp
//
//  Created by Perry on 2/13/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation
//import FirebaseRemoteConfig

class Configurations {
    static let shared = Configurations()

    struct Constants {
        static let ONE_MINUTE_IN_MILLISECONDS: UInt64 = 60 * 1000
        static let ONE_HOUR_IN_MILLISECONDS: UInt64 = 60 * ONE_MINUTE_IN_MILLISECONDS
        //static let MINIMUM_DURATION_WITHOUT_ALERT_IN_MILLISECONDS: UInt64 = 30 * ONE_MINUTE_IN_MILLISECONDS
        static let MINIMUM_DISTANCE_WITHOUT_ALERT_IN_METERS: Int = 1000
        static let ClosestZoomRatioScale: Double = 591657550.50
        static let BreezoApiKey: String = PerrFuncs.isRunningUnderDevelopmentEnvironment() ? "dev_key" : "production_key"

        static let iosAppStoreAddress: String = "https://apps.apple.com/app/your-app-name/id123456789"
    }

    struct Keys {
        struct RemoteConfig {
            static let MaximumParkLifeInMinutes: String                = "MaximumParkLifeInMinutes"
        }
        
        static let NoNoAnimation: String                = "noAnimation" // not using inferred on purpose, to help Swift compiler
        struct Persistency {
            static let InUsePermissionRequestCounter: String  = "InUsePermissionRequestCounter"
            static let AlwaysPermissionRequestCounter: String = "AlwaysPermissionRequestCounter"
            static let LastCrash: String                      = "last crash"
        }
    }

    let GoogleMapsWebApiKey: String
    let GoogleMapsMobileSdkApiKey: String
    private(set) var maximumParkLifeInMinutes: Int

    private init() {
        maximumParkLifeInMinutes = 30

        guard let secretConstantsPlistFilePath: String = Bundle.main.path(forResource: "SecretConstants", ofType: "plist"),
        let config: [String: String] = NSDictionary(contentsOfFile: secretConstantsPlistFilePath) as? [String : String],
        let googleMapsWebApiKey = config["GoogleMapsWebApiKey"],
        let googleMapsMobileSdkApiKey = config["GoogleMapsMobileSdkApiKey"]
        else { fatalError("No way! The app must have this plist file with the mandatory keys") }

        GoogleMapsWebApiKey = googleMapsWebApiKey
        GoogleMapsMobileSdkApiKey = googleMapsMobileSdkApiKey
    }

}
