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

class MapVC: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    //MARK: - PROPERTIES
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
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
    
    //MARK: - METHODS
    // Handle gesture recognizer tapping
    @objc func handleTap(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.becomeFirstResponder()
            print("user tapped")
            let location = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let lat = coordinate.latitude
            let lon = coordinate.longitude
            let pin = Pin(context: DataController.shared.viewContext)
            pin.lat = lat
            pin.lon = lon
            try? DataController.shared.viewContext.save()
            
            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
        sender.state = .ended
    }
    
    func configureGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumPressDuration = 0.7
        gestureRecognizer.numberOfTapsRequired = 0
        
    }
    
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
    
    func showPhotoAlbum() {
        let photoAlbumVC = self.storyboard?.instantiateViewController(identifier: "PhotoAlbumVC") as! PhotoAlbumVC
        self.navigationController?.pushViewController(photoAlbumVC, animated: true)
    }
    
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
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
        // Center map view when annotation is selected
        let region = MKCoordinateRegion(center: view.annotation!.coordinate, span: mapView.region.span)
        mapView.setRegion(region, animated: true)
    }
}
