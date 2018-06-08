//
//  CustomTableViewCell.swift
//  PetSearch
//
//  Created by KK on 2018/5/24.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import FirebaseStorage

class PetTableViewCell: UITableViewCell {

    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var lblKind: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBreed: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
    func popluate(pet: Pet) {
        let imageRef = Storage.storage().reference().child(pet.Photo)
        imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            guard let data = data else {
                return
            }
            let image = UIImage(data: data)
            self.petImage.setToCircle()
            self.petImage.image = image
        }
        
        lblKind.text = pet.Kind
        lblKind.sizeToFit()
        lblName.text = pet.Name
        lblName.sizeToFit()
        lblBreed.text = pet.Breed
        lblBreed.sizeToFit()
        lblColor.text = pet.Color
        lblColor.sizeToFit()
        lblStatus.text = pet.Status
        lblStatus.sizeToFit()
        lblLocation.text = pet.Region
        lblLocation.sizeToFit()
    }
}

extension UIImageView {
    func setToCircle() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
}
