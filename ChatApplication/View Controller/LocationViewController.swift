//
//  LocationViewController.swift
//  ChatApplication
//
//  Created by OPSolutions on 8/23/21.
//

import UIKit
import GoogleMaps

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        GMSServices.provideAPIKey("AIzaSyC0gfykfl9hPGSsrNswOc45_0xhRlU2njI")

        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        view.addSubview(mapView)


        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
  
    }

}
