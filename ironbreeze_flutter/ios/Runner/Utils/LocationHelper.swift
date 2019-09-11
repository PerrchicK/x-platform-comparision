//
//  LocationHelper.swift
//  JobInterviewHW2.0
//
//  Created by Perry on 01/12/2017.
//  Copyright © 2017 perrchick. All rights reserved.
//

import Foundation
import CoreLocation

func == (lhs: LocationCoordinate, rhs: LocationCoordinate) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

struct LocationCoordinate: Codable, CustomStringConvertible {
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init?(json: RawJsonFormat) {
        guard
            let latitude = json["latitude"] as? Double,
            let longitude = json["longitude"] as? Double
            else { return nil }
        
        self.init(latitude: latitude, longitude: longitude)
    }

    func toDictionary() -> [String:Double] {
        return ["latitude": latitude, "longitude": longitude]
    }

    func toLocationString() -> String {
        return "(\(latitude),\(longitude))"
    }

    func toString() -> String {
        return "latitude: \(latitude), longitude: \(longitude)"
    }
    
    var description: String {
        return toString()
    }
}

protocol LocationHelperDelegate: class {
    func onLocationUpdated(updatedLocation: CLLocation)
}

class LocationHelper: NSObject, CLLocationManagerDelegate {
    static let shared: LocationHelper = LocationHelper()

//    let gmsPlacesClient: GMSPlacesClient
//    let placesAutocompleteSessionToken: GMSAutocompleteSessionToken
    
    var callbacks: [CallbackClosure<CLLocation?>]
    var lastKnownLocation: CLLocation? {
        return locationManager.location
    }

    weak var delegate: LocationHelperDelegate?
    private(set) var currentLocation: CLLocation?
    private lazy var locationManager: CLLocationManager = {
        let locationManager: CLLocationManager = CLLocationManager();
        locationManager.delegate = self

        return locationManager
    }()

    override private init() {
        callbacks = []

        /**
         * Create a new session token. Be sure to use the same token for calling
         * findAutocompletePredictions, as well as the subsequent place details request.
         * This ensures that the user's query and selection are billed as a single session.
         */

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func fetchLocation(callback: @escaping CallbackClosure<CLLocation?>) {
        callbacks.append(callback)
        locationManager.requestLocation()
    }

    func initialize() {}

    var distanceFilter: CLLocationDistance {
        get {
            return locationManager.distanceFilter
        }
        set {
            locationManager.distanceFilter = newValue
        }
    }

    func startUpdate() {
        guard isForegroundPermissionGranted else { return }
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
    }

    func stopUpdate() {
        locationManager.stopUpdatingLocation()
        //locationManager.allowsBackgroundLocationUpdates = false
    }

    var isPermissionDenied: Bool {
        return CLLocationManager.authorizationStatus() == .denied
    }

    var isBackgroundPermissionGranted: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways
    }

    var isForegroundPermissionGranted: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse || isBackgroundPermissionGranted
    }

    @objc func applicationWillEnterForeground(notification: Notification) {
        startUpdate()
    }

    @objc func applicationDidEnterBackground(notification: Notification) {
        stopUpdate()
    }
    
    var isCarSpeed: Bool {
        return (currentLocation?.speed).or(0) > 5
    }

    var isAlmostIdle: Bool {
        return (currentLocation?.speed).or(0) < 1
    }

    func requestPermissionsIfNeeded(type: CLAuthorizationStatus) {
        let counterKey: String = type == .authorizedAlways ? Configurations.Keys.Persistency.AlwaysPermissionRequestCounter : Configurations.Keys.Persistency.InUsePermissionRequestCounter
        let permissionRequestCounter: Int = UserDefaults.load(key: counterKey, defaultValue: 0)
        if permissionRequestCounter > 0 {
            //PerrFuncs.goToSettings()
        } else {
            // First time for this life time
            if type == .authorizedAlways {
                locationManager.requestAlwaysAuthorization()
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        }

        UserDefaults.save(value: permissionRequestCounter + 1, forKey: counterKey).synchronize()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        AppDelegate.shared.callFlutter(methodName: "did_change_location_authorization")
    }

    // https://developer.apple.com/documentation/corelocation/monitoring_the_user_s_proximity_to_geographic_regions
    // https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/BackgroundExecution/BackgroundExecution.html#//apple_ref/doc/uid/TP40007072-CH4-SW7
    func startMonitoring() {
        guard isBackgroundPermissionGranted, let lastKnownLocation = lastKnownLocation else { return }
        
        locationManager.startMonitoring(for: CLCircularRegion(center: lastKnownLocation.coordinate, radius: CLLocationDistance(500), identifier: "Your current location"))
    }

//    func addressAutocomplete(phrase: String, completion: @escaping CallbackClosure<[[String:String]]?>) {
//        gmsPlacesClient.findAutocompletePredictions(fromQuery: phrase, bounds: nil, boundsMode: GMSAutocompleteBoundsMode.bias, filter: nil, sessionToken: placesAutocompleteSessionToken) { (results, error) in
//
//            if let error = error {
//                📕("Autocomplete error \(error)")
//            }
//
//            if let results = results {
//                let resultsDictionaries: [[String:String]] = results.filter( { return $0.types.contains("geocode") } ).map( { return [$0.placeID:$0.attributedFullText.string] } )
//
//                completion(resultsDictionaries)
//            } else {
//                completion(nil)
//            }
//        }
//    }

    // https://developers.google.com/places/ios-sdk/client-migration#fetch-place-by-id
//    func fetchPlaceLocation(placeId: String, completion: @escaping CallbackClosure<RawJsonFormat?>) {
//        let fields: GMSPlaceField = GMSPlaceField(rawValue:
//            UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))!
//
//        gmsPlacesClient.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: placesAutocompleteSessionToken, callback: { (place, error) in
//            if let error = error {
//                📕("Fetch place error \(error)")
//            }
//
//            if let place = place {
//                let addressComponents: [RawJsonFormat]? = place.addressComponents?.map( { ["type":$0.type, "long_name":$0.name,"short_name": $0.shortName ?? "" ] } ) ?? []
//                completion(["address_components": addressComponents ?? [:], "geometry": place.coordinate.toLocationCoordinate().toDictionary()])
//            } else {
//                completion(nil)
//            }
//        })
//    }

    /**
     - parameter latitude: Double for latitude value
     - parameter longitude: Double for longitude value
     */
    func geocode(addressString: String, completion: @escaping CallbackClosure<CLLocationCoordinate2D?>) {
        CLGeocoder().geocodeAddressString(addressString) { (placeMarks, error) in
            if let error = error {
                📕("error: '\(error)', returned no result!")
            } else {
                📕("geocode returned no result!")
            }

            guard let placeMarks = placeMarks, let placeMark = placeMarks.first else {
                completion(nil)
                return
            }

            if let coordinate = placeMark.location?.coordinate {
                completion(coordinate)
            } else {
                completion(nil)
            }
        }
    }

    /**
     - parameter latitude: Double for latitude value
     - parameter longitude: Double for longitude value
     */
    func reverseGeocode(latitude: Double, longitude: Double, completion: @escaping CallbackClosure<[String]?>) {
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { (placemarks, error) in
            let didSucceed: Bool
            if let error = error {
                📕(error)
                didSucceed = false
            } else {
                didSucceed = true
            }

            guard let placemark = placemarks?.first else { completion(didSucceed ? [] : nil); return }
            
            let city: String? = placemark.locality
            let country: String? = placemark.country
            var address: String? = placemark.name
            
            if address != nil {
                var addressString = address!
                if let city = city {
                    addressString = addressString + ", " + city
                }
                if let country = country {
                    addressString = addressString + ", " + country
                }

                address = addressString
            } else {
                var addressString: String = ""
                if let subLocality = placemark.subLocality {
                    addressString = addressString + subLocality + ", "
                }
                if let thoroughfare = placemark.thoroughfare  {
                    addressString = addressString + thoroughfare + ", "
                }
                if let locality = placemark.locality {
                    addressString = addressString + locality + ", "
                }
                if let country = placemark.country {
                    addressString = addressString + country + ", "
                }

                address = addressString
            }

            completion([address ?? "", city ?? "", country ?? ""])
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        📕(error)
        callbacks.forEach( { $0(nil) } )
        callbacks.removeAll()
        //delegate?.onLocationUpdated(updatedLocation: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var _callbacks: [CallbackClosure<CLLocation?>]?

        if let location = locations.first {
            currentLocation = location
            _callbacks = callbacks
            callbacks.removeAll()
            delegate?.onLocationUpdated(updatedLocation: location)

            //startMonitoring()
            _callbacks?.forEach( { $0(location) } )
        } else {
            _callbacks?.forEach( { $0(nil) } )
        }
    }
}
