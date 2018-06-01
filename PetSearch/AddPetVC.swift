//
//  AddPetVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import Firebase

class AddPetVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var _uid: String!
    private var selectedImage: UIImage?
    private var needAdjustView = true

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtBreed: UITextField!
    @IBOutlet weak var txtColor: UITextField!
    @IBOutlet weak var txtAge: UITextField!
    @IBOutlet weak var txtMcNumber: UITextField!
    @IBOutlet weak var txtSize: UITextField?
    @IBOutlet weak var txtKind: UITextField?
    @IBOutlet weak var txtGender: UITextField?
    @IBOutlet weak var txtDesexed: UITextField?
    @IBOutlet weak var txtStatus: UITextField?
    @IBOutlet weak var txtSince: UITextField?
    
    @IBAction func goToLibrary(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.delegate = self
        
        self.present(image, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = pickedImage
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didAddPet(_ sender: UIButton) {
        let sv = self.displaySpinner(onView: self.view)
        
        guard let name = txtName.text, !name.isEmpty,
            let breed = txtBreed.text, !breed.isEmpty,
            let age = txtAge.text, !age.isEmpty,
            let color = txtColor.text, !color.isEmpty,
            let mcNumber = txtMcNumber.text, !mcNumber.isEmpty,
            let image = selectedImage else {
                alertMessage(in: self, title: "", message: "Please input required fileds", callback: { (action) in
                    self.removeSpinner(spinner: sv)
                })
                return
        }
        
        let petId = UUID.init().uuidString
        let kind = txtKind?.text ?? ""
        let gender = txtGender?.text ?? ""
        let desexed = txtDesexed?.text ?? ""
        let size = txtSize?.text ?? ""
        let since = txtSince?.text ?? ""
        let status = txtStatus?.text ?? ""
            
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.5)! as Data
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let imageId = UUID.init().uuidString
        
        let _ = Storage.storage().reference().child("images").child(imageId).putData(data, metadata: metaData) {
            (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            if metadata.size > 0 {
                let pet = Pet(PetId: petId, Uid: self._uid, Name: name, Breed: breed, Color: color, Age: age, MicrochipNumber: mcNumber, Photo: imageId, Size: size, Kind: kind, Gender: gender, Desexed: desexed, Status: status, MissingSince: since, Description: "", LastX: 0.00, LastY: 0.00, Region: "")
                
                Firestore.firestore().collection(Pet.TableName).document(petId).setData(pet.dictionary, completion: { (error) in
                    self.removeSpinner(spinner: sv)
                    if let error = error {
                        alertMessage(in: self, title: "", message: "Add information failed. \(error.localizedDescription)")
                    } else {
                        alertMessage(in: self, title: "", message: "Add information successfull", callback: { (action) in
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                    }
                })
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPetVC.dismissKeyword))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func dismissKeyword() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if needAdjustView {
            if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if needAdjustView {
            if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y != 0{
                    self.view.frame.origin.y += keyboardSize.height
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let uid = auth.currentUser?.uid {
                self._uid = uid
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }

}
