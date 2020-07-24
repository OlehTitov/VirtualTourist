//
//  PhotoAlbumVC.swift
//  virtualTourist
//
//  Created by Oleh Titov on 24.07.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var altitude: CLLocationDistance!
    var annotation : MKAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        
    }
    
    func setupMapView() {
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: mapView.region.span)
        mapView.setRegion(region, animated: true)
        mapView.camera.altitude = altitude
    }
    
}

extension PhotoAlbumVC: MKMapViewDelegate {
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
}

