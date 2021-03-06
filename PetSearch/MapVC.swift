//
//  MapVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

enum MapMode {
    case chooseLocation, petAroundYou, filterLocation
}

class MapVC: UIViewController, GMSMapViewDelegate {
    
    private let locationManager = CLLocationManager()
    var documents: [DocumentSnapshot] = []
    var mapMode = MapMode.chooseLocation
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    var delegateController: UIViewController?
    
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> MapVC {
        let controller = storyboard.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mapMode {
        case .chooseLocation:
            self.zoomLevel = 15.0
        case .petAroundYou:
            self.zoomLevel = 13.0
        case .filterLocation:
            self.zoomLevel = 15.0
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
    }

    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) { // long press is only available on choose location
        if mapMode == .chooseLocation {
            // add a marker and ask user if they want to use this location
            mapView.clear()
            let marker = GMSMarker(position: coordinate)
            GMSGeocoder().reverseGeocodeCoordinate(coordinate) { (result, error) in
                if let address = result?.firstResult() {
                    marker.map = mapView
                    confirmMessage(in: self, message: "Would you like to use this coordinate?", confirmText: "OK", confirmMethod: { (action) in
                        let delegateController = self.delegateController as! AddPetVC
                        //let subLocality = address.subLocality ?? (address.locality ?? "")
                        let locality = address.locality ?? ""
                        delegateController.location = (CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), locality)
                        delegateController.btnMap.setTitle(locality, for: .normal)
                        self.navigationController?.popViewController(animated: true)
                    }, cancel: nil)
                }
            }
        } else if mapMode == .filterLocation {
            mapView.clear()
            let circleCenter = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            var rad : Double = 0.0
            if UserDefaults.standard.object(forKey: "radius") != nil {
                    rad = UserDefaults.standard.double(forKey: "radius")
            } else {
                rad = Double(RADIUS);
            }
            let circ = GMSCircle(position: circleCenter, radius: rad*1000)
            
            circ.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.3)
            circ.strokeColor = .red
            circ.strokeWidth = 1
            
            //let marker = GMSMarker(position: coordinate)
            GMSGeocoder().reverseGeocodeCoordinate(coordinate) { (result, error) in
                if let address = result?.firstResult() {
                    //marker.map = mapView
                    circ.map = mapView
                    confirmMessage(in: self, message: "Would you like to use this coordinate?", confirmText: "OK", confirmMethod: { (action) in
                        let delegateController = self.delegateController as! FilterVC
                        delegateController.latitude = coordinate.latitude
                        delegateController.longitude = coordinate.longitude
                        //let subLocality = address.subLocality ?? (address.locality ?? "")
                        let locality = address.locality ?? ""
                        delegateController.btnMap.setTitle(locality, for: .normal)
                        self.navigationController?.popViewController(animated: true)
                    }, cancel: nil)
                }
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if mapMode == .petAroundYou {
            guard let data = marker.userData else { return }
            
            let controller = SinglePetVC.fromStoryboard()
            let document = data as! DocumentSnapshot
            controller.pet = Pet(dictionary: document.data()!)
            controller.petReference = document.reference
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if mapMode == .petAroundYou {
            guard let data = marker.userData,
                let document = data as? DocumentSnapshot,
                let pet = Pet(dictionary: document.data()!) else { return nil }
            
            let infoWindow = Bundle.main.loadNibNamed("GoogleMapInfoWindow", owner: self, options: nil)?.first as! GoogleMapInfoWindow
            
            let imageRef = Storage.storage().reference().child(pet.Photo)
            imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                infoWindow.petImage.image = image
            }
            
            infoWindow.lblBreed.text = pet.Breed
            infoWindow.lblKind.text = pet.Kind
            infoWindow.lblName.text = pet.Name
            infoWindow.lblStatus.text = pet.Status
            infoWindow.lblColor.text = pet.Color
            
            return infoWindow
        }
        
        return nil
    }
    
}
extension MapVC: CLLocationManagerDelegate {
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        if mapMode == .petAroundYou { // if the map's mode is pet around you, then show markers of pets
            for document in documents {
                if let model = Pet(dictionary: document.data()!) {
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: model.Latitude, longitude: model.Longitude))
                    marker.userData = document
                    marker.map = mapView
                    marker.tracksInfoWindowChanges = true
                }
            }
        }
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
    }
}
