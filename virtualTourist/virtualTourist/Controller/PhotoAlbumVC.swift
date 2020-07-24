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
    
    //MARK: - PROPERTIES
    enum Section {
        case main
    }
    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    var altitude: CLLocationDistance!
    var annotation : MKAnnotation!
    
    //MARK: - OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        configureDataSource()
    }
    
    //MARK: - METHODS
    func setupMapView() {
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: mapView.region.span)
        mapView.setRegion(region, animated: true)
        mapView.camera.altitude = altitude
    }
    
    private func configureDataSource() {
        let dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CollectionViewCell.identifier,
                for: indexPath) as? CollectionViewCell else { fatalError("Cannot create new cell") }

            // Populate the cell with image
            //cell.image.image = "\(identifier)"

            return cell
        }
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

