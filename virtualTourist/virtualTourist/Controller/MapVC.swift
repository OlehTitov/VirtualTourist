//
//  MapVC.swift
//  virtualTourist
//
//  Created by Oleh Titov on 21.07.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    //MARK: - PROPERTIES
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var selectedPin: Pin!
    var currentPinLat: Double = 0.0
    var currentPinLon: Double = 0.0
    
    //MARK: - OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        configureGestureRecognizer()
        setupFetchedResultsController()
        attachPins()
    }
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    //MARK: - VIEW WILL DISAPPEAR
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: - LONG PRESS GESTURE
    //Add annotation, create Pin object, reverse geocoding to get place name, save Pin to Core Data and download images
    @objc func handleTap(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.becomeFirstResponder()
            let location = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let pin = Pin(context: DataController.shared.viewContext)
            pin.lat = coordinate.latitude
            pin.lon = coordinate.longitude
            // Reverse geocode
            getPlaceName(pin: pin) { (address) in
                guard let address = address else { return }
                pin.street = address.name
                pin.city = address.locality
                pin.country = address.country
            }
            // Save to Core Data
            try? DataController.shared.viewContext.save()
            setupFetchedResultsController()
            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            //Before downloading images set values to current pin
            currentPinLat = coordinate.latitude
            currentPinLon = coordinate.longitude
            //Start downloading images
            downloadImages()
        }
        // End gesture
        sender.state = .ended
    }
    
    func configureGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumPressDuration = 0.7
        gestureRecognizer.numberOfTapsRequired = 0
    }
    
    //MARK: - SETUP FRC
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    //MARK: - REVERSE GEOCODING TO GET ADDRESS
    // The address name will be used later in the table view
    func getPlaceName(pin: Pin, completion: @escaping (CLPlacemark?) -> Void) {
        let location = CLLocation(latitude: pin.lat, longitude: pin.lon)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (address, error) in
            if error == nil {
                let firstAddress = address?[0]
                completion(firstAddress)
            } else {
                completion(nil)
            }
        }
    }
    
    //MARK: - NETWORKING
    private func downloadImages() {
        FlickrClient.getListOfPhotosForLocation(lat: currentPinLat, lon: currentPinLon, radius: 7, page: 1) { (photos, error) in
            print("Printing number of photos before loop \(photos.count)")
            for photo in photos {
                guard let photoURL = URL(string: photo.imageURL ?? "") else {
                    return
                }
                //Check if there are URLs
                print("Printing URL from loop in getListOfPhotosForLocation \(photoURL)")
                DispatchQueue.global(qos: .userInteractive).async {
                    FlickrClient.downloadImage(path: photoURL, completion: handleImageDownload(data:error:))
                }
            }
        }
        
        func handleImageDownload(data: Data?, error: Error?) {
            guard let data = data else {
                return
            }
            //Check if we have the data
            print("Here goes the data from handleImageDownload: \(data)")
            // Save images to Core Data
            let image = SavedPhoto(context: DataController.shared.viewContext)
            //Find assosiated pin
            guard let pins = fetchedResultsController.fetchedObjects else { return }
            for pin in pins where currentPinLat == pin.lat && currentPinLon == pin.lon {
                selectedPin = pin
            }
            image.pin = self.selectedPin
            image.image = data
            try? DataController.shared.viewContext.save()
        }
    }
    
    //MARK: - SHOW PINS ON THE MAP
    func attachPins() {
        guard let pins = fetchedResultsController.fetchedObjects else {
            return
        }
        for pin in pins {
            let lat = CLLocationDegrees(pin.lat)
            let lon = CLLocationDegrees(pin.lon)
            let coordinates = CLLocationCoordinate2DMake(lat, lon)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            self.mapView.addAnnotation(annotation)
        }
    }
}

//MARK: - MAP VIEW DELEGATE
extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Get zoom level of current view to pass it to the next VC
        let altitude = mapView.camera.altitude
        guard let annotation = view.annotation else { return }
        guard let pins = fetchedResultsController.fetchedObjects else { return }
        for pin in pins where annotation.coordinate.latitude == pin.lat && annotation.coordinate.longitude == pin.lon {
            print("It should be found")
            selectedPin = pin
        }
        // Go to PinDetailVC
        let pinDetailsVC = self.storyboard?.instantiateViewController(identifier: "PinDetailsVC") as! PinDetailsVC
        pinDetailsVC.altitude = altitude
        pinDetailsVC.selectedPin = selectedPin
        pinDetailsVC.annotation = annotation
        self.navigationController?.pushViewController(pinDetailsVC, animated: true)
        //Deselect annotation
        mapView.deselectAnnotation(view.annotation!, animated: false)
    }
}
