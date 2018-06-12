//
//  StylesB.swift
//  PetSearch
//
//  Created by Denis Eltcov on 6/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit

class StylesB: UIButton {
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.gray.cgColor
    }

}
