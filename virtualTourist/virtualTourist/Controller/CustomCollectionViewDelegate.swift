//
//  CustomCollectionViewDelegate.swift
//  virtualTourist
//
//  Created by Oleh Titov on 27.07.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import UIKit

class CustomCollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
  
    let numberOfItemsPerRow: CGFloat
    let interItemSpacing: CGFloat
  
  init(numberOfItemsPerRow: CGFloat, interItemSpacing: CGFloat) {
    self.numberOfItemsPerRow = numberOfItemsPerRow
    self.interItemSpacing = interItemSpacing
  }
  
    
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //Calculation for cell size depending on items per row and spacing between items
    let maxWidth = UIScreen.main.bounds.width
    let totalSpacing = (interItemSpacing * 2) + ((numberOfItemsPerRow - 1) * interItemSpacing)
    let itemWidth = (maxWidth - totalSpacing) /  numberOfItemsPerRow
    
    return CGSize(width: itemWidth, height: itemWidth)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return interItemSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return interItemSpacing
  }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: interItemSpacing, left: interItemSpacing, bottom: interItemSpacing, right: interItemSpacing)
    }
}
