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

class PhotoAlbumVC: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    //MARK: - PROPERTIES
    var dataSource: UICollectionViewDiffableDataSource<Int, SavedPhoto>?
    var snapshot = NSDiffableDataSourceSnapshot<Int, SavedPhoto>()
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
        
        setupFetchedResultsController()
        configureDataSource()
        
        // Network request to get images for the selected location
        FlickrClient.getListOfPhotosForLocation(lat: selectedPin.lat, lon: selectedPin.lon, radius: 7, page: 1, completion: handleGetListOfPhotosForLocation(photos:error:))
        setupMapView()
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
        setupSnapshot()
    }
    
    func handleImageDownload(data: Data?, error: Error?) {
        guard let data = data else {
            return
        }
        // Save images to Core Data
        let image = SavedPhoto(context: DataController.shared.viewContext)
        image.image = data
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
            setupSnapshot()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
 
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, SavedPhoto>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, photo: SavedPhoto) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "imageCell",
                for: indexPath) as? CollectionViewCell else { fatalError("Cannot create new cell") }
            cell.backgroundColor = .red
            // Populate the cell with image
            let image = UIImage(data: photo.image!)
            cell.image.image = image
            cell.city.text = self.selectedPin.city
            return cell
        }
        setupSnapshot()
    }
    
    fileprivate func setupSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Int, SavedPhoto>()
        snapshot.appendSections([0])
        snapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        dataSource?.apply(self.snapshot, animatingDifferences: false)
    }
    
    // Update collectionView when data is changing
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setupSnapshot()
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

