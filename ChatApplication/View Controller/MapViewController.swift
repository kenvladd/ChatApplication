//
//  MapViewController.swift
//  ChatApplication
//
//  Created by OPSolutions on 9/1/21.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    
    let register = RegisterViewController()
    var completionHandlerCountry: ((String?) -> Void)?
    var completionHandlerStreet: ((String?) -> Void)?
    var completionHandlerCity: ((String?) -> Void)?
    var completionHandlerZip: ((String?) -> Void)?
    var completionHandlerProvince: ((String?) -> Void)?
    
    let manager = CLLocationManager()
    var street: String?
    var city: String?
    var zipCode: String?
    var country: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        GMSServices.provideAPIKey("AIzaSyC0gfykfl9hPGSsrNswOc45_0xhRlU2njI")

        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        let coordinate = location.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 10.0)
        let mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        view.addSubview(mapView)
        
        let geoCoder = CLGeocoder()
        let pin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                geoCoder.reverseGeocodeLocation(pin, completionHandler:
                    {
                        placemarks, error -> Void in

                        // Place details
                        guard let placeMark = placemarks?.first else { return }

                        // Location name
                        if let locationName = placeMark.location {
                            print(locationName)
                        }
                        // Street address
                        if let streetFunc = placeMark.thoroughfare {
                            self.street = streetFunc
                        }
                        // City
                        if let cityFunc = placeMark.subAdministrativeArea {
                            self.city = cityFunc
                        }
                        // Zip code
                        if let zipFunc = placeMark.isoCountryCode {
                            self.zipCode = zipFunc
                        }
                        // Country
                        if let countryFunc = placeMark.country {
                            self.country = countryFunc
                        }
                        
                        print("street: \(self.street ?? "n/a") city: \(self.city ?? "n/a") country: \(self.country ?? "n/a") \(self.zipCode ?? "n/a")")
                })
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        marker.title = self.city
        marker.snippet = self.country
        marker.map = mapView
    }
}
