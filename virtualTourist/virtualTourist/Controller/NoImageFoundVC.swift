//
//  NoImageFoundVC.swift
//  virtualTourist
//
//  Created by Oleh Titov on 29.07.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import UIKit

class NoImageFoundVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func returnToMapTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
        
    }
}

