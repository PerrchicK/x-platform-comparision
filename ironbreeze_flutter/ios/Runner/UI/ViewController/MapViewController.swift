//
//  MapViewController.swift
//  Runner
//
//  Created by Perry Sh on 17/01/2019.
//  Copyright © 2019 perrchick. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    static let MAX_ZOOM: Int = 15
    static let MIN_ZOOM: Int = 7

    @IBOutlet weak var handleView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    var flutterLocationObserver: NotificationObserver?

    var lastSpan: MKCoordinateSpan?
    
    static func markerImageView() -> UIImageView {
        return UIImageView(image: UIImage(named: "map_pin"))
    }

    func generateImageViewContainer() -> UIView {
        let markerImageView: UIImageView = MapViewController.markerImageView()
        markerImageView.frame = CGRect(x: 0, y: 0, width: 31, height: 42)
        let imageViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 31, height: 90))
        imageViewContainer.addSubview(markerImageView)
        
        return imageViewContainer
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        handleView.isUserInteractionEnabled = true

        btnClose.setTitleShadowColor(UIColor.yellow, for: UIControl.State.normal)
        btnClose.backgroundColor = UIColor.white //UIColor.black.withAlphaComponent(0.5)
        btnClose.setTitleColor(UIColor.black, for: UIControl.State.normal)
        btnClose.setTitle("X", for: UIControl.State.normal)

        btnClose.makeRoundedCorners(30)

        mapView.showsUserLocation = true
        mapView.delegate = self
    }

    @IBAction func backButtonPressed() {
        PageNavigationController.shared?.showMainScreen()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let currentLocation = LocationHelper.shared.lastKnownLocation {
            setCamera(toCoordinate: currentLocation.coordinate, toDefaultZoom: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        flutterLocationObserver = nil
    }

    func goToCurrentLocation() {
        if let currentLocation = LocationHelper.shared.currentLocation {
            setCamera(toCoordinate: currentLocation.coordinate)
        }
    }

    func setCamera(toCoordinate coordinate: CLLocationCoordinate2D, toDefaultZoom: Bool = false) {

        //let regionRadius: CLLocationDistance = 2000
        let regionRadius: CLLocationDistance = 40000

        if let span = lastSpan {
            mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
        } else if toDefaultZoom {
            let coordinateRegion: MKCoordinateRegion

            coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        } else {
            mapView.setCenter(coordinate, animated: true)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer: MKTileOverlayRenderer = MKTileOverlayRenderer(overlay: overlay)
        renderer.alpha = 0.5
        return renderer
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        lastSpan = mapView.region.span
    }
}

extension MKMapView {
    func removeAllAnnotations() {
        removeAnnotations(annotations)
    }
}
