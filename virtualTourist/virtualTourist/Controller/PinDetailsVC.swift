//
//  PinDetailsVC.swift
//  virtualTourist
//
//  Created by Oleh Titov on 27.07.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PinDetailsVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    let images: [UIImage] = [UIImage(named: "bmw")!, UIImage(named: "girl")!, UIImage(named: "sky")!, UIImage(named: "sea")!, UIImage(named: "burger")!, UIImage(named: "car")!, UIImage(named: "party")!]
    var altitude: CLLocationDistance!
    var annotation: MKAnnotation!
    var selectedPin: Pin!
    var dataSource: UICollectionViewDiffableDataSource<Int, SavedPhoto>! = nil
    var fetchedResultsController: NSFetchedResultsController<SavedPhoto>!
    var snapshot = NSDiffableDataSourceSnapshot<Int, SavedPhoto>()
    
    @IBOutlet weak var photoCollection: UICollectionView!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Initial check for Selected pin: \(selectedPin.city)")
        setupFetchedResultsController()
        configureDataSource()
        configureLayout()
        downloadImages()
        let numberOfPhotos = fetchedResultsController.fetchedObjects?.count
        print(numberOfPhotos!)
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
    
    //MARK: - COLLECTION VIEW DIFFABLE DATA SOURCE
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, SavedPhoto>(collectionView: photoCollection) {
            (collectionView: UICollectionView, indexPath: IndexPath, photo: SavedPhoto) -> UICollectionViewCell? in
            
            // Get a cell of the desired kind.
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "photoCellIdentifier",
                for: indexPath) as? CollectionViewPhotoCell else { fatalError("Cannot create new cell") }
            
            // Populate the cell with our item description.
            let img = UIImage(data: photo.image!)
            print(img?.size as Any)
            cell.photoView.image = img!
            
            // Make the corner of the cells round and sexy
            //cell.contentView.layer.cornerRadius = 8
            
            // Return the cell.
            return cell
        }
        setupSnapshot()
    }
    
    private func setupSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Int, SavedPhoto>()
        snapshot.appendSections([0])
        snapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        dataSource?.apply(self.snapshot)
    }
    
    //MARK: - SETUP FRC
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<SavedPhoto> = SavedPhoto.fetchRequest()
        fetchRequest.sortDescriptors = []
        //Check if we have selectedPin
        print(selectedPin.city!)
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
    
    //MARK: - NETWORKING
    private func downloadImages() {
        FlickrClient.getListOfPhotosForLocation(lat: selectedPin.lat, lon: selectedPin.lon, radius: 7, page: 1) { (photos, error) in
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
            // Save images to Core Data
            let image = SavedPhoto(context: DataController.shared.viewContext)
            image.image = data
            try? DataController.shared.viewContext.save()
        }
    }
    
    //MARK: - COLLECTION VIEW LAYOUT
    func configureLayout() {
        photoCollection.collectionViewLayout = generateLayout()
        photoCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func generateLayout() -> UICollectionViewLayout {
        // First type. Full
        let fullPhotoItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(2/3)))
        
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2)
        // Second type: Main with pair
        // 3
        let mainItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(2/3),
                heightDimension: .fractionalHeight(1.0)))
        
        mainItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2)
        
        // 2
        let pairItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.5)))
        
        pairItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2)
        
        let trailingGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1.0)),
            subitem: pairItem,
            count: 2)
        
        // 1
        let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(4/9)),
            subitems: [mainItem, trailingGroup])
        // Third type. Triplet
        let tripletItem = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1.0)))

        tripletItem.contentInsets = NSDirectionalEdgeInsets(
          top: 2,
          leading: 2,
          bottom: 2,
          trailing: 2)

        let tripletGroup = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(2/9)),
          subitems: [tripletItem, tripletItem, tripletItem])
        // Fourth type. Reversed main with pair
        let mainWithPairReversedGroup = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(4/9)),
          subitems: [trailingGroup, mainItem])
        //2
        let nestedGroup = NSCollectionLayoutGroup.vertical(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(16/9)),
          subitems: [
            fullPhotoItem,
            mainWithPairGroup,
            tripletGroup,
            mainWithPairReversedGroup
          ]
        )

        let section = NSCollectionLayoutSection(group: nestedGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}
