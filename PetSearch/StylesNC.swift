//
//  StylesNC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 6/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit

class StylesNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor(red:0.18, green:0.81, blue:0.64, alpha:1.0);
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white];
        self.navigationBar.tintColor = UIColor.white;
        // Do any additional setup after loading the view.
    }

}
