//
//  SinglePetVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import Firebase

class SinglePetVC: UIViewController {
    
    var pet: Pet?
    var petReference: DocumentReference?  // listen realtime updates of comment table from firebase
    
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var txtKind: UILabel!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtBreed: UILabel!
    @IBOutlet weak var txtColor: UILabel!
    @IBOutlet weak var txtStatus: UILabel!
    @IBOutlet weak var txtLocation: UILabel!
    @IBOutlet weak var txtGender: UILabel!
    @IBOutlet weak var txtDesexed: UILabel!
    @IBOutlet weak var txtAge: UILabel!
    @IBOutlet weak var txtChip: UILabel!
    @IBOutlet weak var txtMissing: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> SinglePetVC {
        let controller = storyboard.instantiateViewController(withIdentifier: "SinglePetVC") as! SinglePetVC
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = pet?.Name
        
        let swipeUpRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(showComments))
        swipeUpRecogniser.direction = .up
        self.view.addGestureRecognizer(swipeUpRecogniser)
    }
    
    @objc func showComments() {
        let controller = CommentsVC.fromStoryboard()
        controller.petId = pet?.PetId
        controller.publisher = pet?.Uid
        controller.petReference = self.petReference
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func didTapComment(_ sender: Any) {
        let controller = CommentsVC.fromStoryboard()
        controller.petId = pet?.PetId
        controller.publisher = pet?.Uid
        controller.petReference = self.petReference
        present(controller, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let pet = pet else { return }
        
        let imageRef = Storage.storage().reference().child(pet.Photo)
        imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            guard let data = data else {
                return
            }
            let image = UIImage(data: data)
            self.petImage.image = image
        }
        
        txtKind.text = pet.Kind
        txtKind.sizeToFit()
        txtName.text = pet.Name
        txtName.sizeToFit()
        txtBreed.text = pet.Breed
        txtBreed.sizeToFit()
        txtColor.text = pet.Color
        txtColor.sizeToFit()
        txtStatus.text = pet.Status
        txtStatus.sizeToFit()
        txtLocation.text = pet.Region
        txtLocation.sizeToFit()
        txtGender.text = pet.Gender
        txtGender.sizeToFit()
        txtDesexed.text = pet.Desexed
        txtDesexed.sizeToFit()
        txtAge.text = pet.Age.description
        txtAge.sizeToFit()
        txtChip.text = pet.MicrochipNumber
        txtChip.sizeToFit()
        txtMissing.text = Date(timestamp: pet.MissingSince).description
        txtMissing.sizeToFit()
        txtDescription.text = pet.Description
    }
}
