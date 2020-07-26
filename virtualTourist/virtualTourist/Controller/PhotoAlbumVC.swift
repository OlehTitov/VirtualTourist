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

class PhotoAlbumVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    //MARK: - PROPERTIES
    enum Section {
        case main
    }
    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    var altitude: CLLocationDistance!
    var annotation : MKAnnotation!
    var fetchedResultsController: NSFetchedResultsController<SavedPhoto>!
    var selectedPin: Pin!
    
    //MARK: - OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        configureDataSource()
        setupFetchedResultsController()
        // Network request to get images for the selected location
        FlickrClient.getListOfPhotosForLocation(lat: selectedPin.lat, lon: selectedPin.lon, radius: 7, page: 1, completion: handleGetListOfPhotosForLocation(photos:error:))
    }
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    //MARK: - METHODS
    func setupMapView() {
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: mapView.region.span)
        mapView.setRegion(region, animated: true)
        mapView.camera.altitude = altitude
    }
    
    func handleGetListOfPhotosForLocation(photos: [Photo], error: Error?) {
        // Download images for pin, save to Core Data
        for photo in photos {
            guard let photoURL = URL(string: photo.imageURL ?? "") else {
                return
            }
            FlickrClient.downloadImage(path: photoURL, completion: handleImageDownload(data:error:))
        }
    }
    
    func handleImageDownload(data: Data?, error: Error?) {
        guard let data = data else {
            return
        }
        // TO-DO: Save images to Core Data
        let image = SavedPhoto(context: DataController.shared.viewContext)
        image.image = data
        print(image.image)
        try? DataController.shared.viewContext.save()
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<SavedPhoto> = SavedPhoto.fetchRequest()
        fetchRequest.sortDescriptors = []
        let predicate = NSPredicate(format: "pin == %@", selectedPin)
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
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

