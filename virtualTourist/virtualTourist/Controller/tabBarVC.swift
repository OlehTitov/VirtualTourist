//
//  ViewController.swift
//  virtualTourist
//
//  Created by Oleh Titov on 21.07.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import UIKit

class tabBarVC: UITabBarController {
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLogo()
    }

    //MARK: - SETUP LOGO
    func setupLogo() {
        self.navigationController?.isNavigationBarHidden = false
        let logo = UIImage(named: "travelBag")
        let logoView = UIImageView(image: logo!)
        logoView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = logoView
        self.navigationController?.navigationBar.barTintColor = UIColor.gunPowder
        self.tabBar.barTintColor = UIColor.gunPowder
    }

}

