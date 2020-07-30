//
//  NoImageFoundVC.swift
//  virtualTourist
//
//  Created by Oleh Titov on 29.07.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import UIKit

class NoImageFoundVC: UIViewController {
    
    var selectedPin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func returnToMapTapped(_ sender: Any) {
        let pinDetailsVC = self.storyboard?.instantiateViewController(identifier: "PinDetailsVC") as! PinDetailsVC
        pinDetailsVC.selectedPin = selectedPin
        navigationController?.popViewController(animated: true)
    }
    
}

