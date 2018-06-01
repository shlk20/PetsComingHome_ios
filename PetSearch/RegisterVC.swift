//
//  RegisterVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {

    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var txtName: RemoveCursor!
    @IBOutlet weak var txtEmail: RemoveCursor!
    @IBOutlet weak var txtPhoneNumber: RemoveCursor!
    @IBOutlet weak var txtPassword: RemoveCursor!
    @IBOutlet weak var txtConfirmPassword: RemoveCursor!
    
    @IBAction func didRegister(_ sender: UIButton) {
        if let email = txtEmail.text, let password = txtPassword.text, let confirmPassword = txtConfirmPassword.text, let name = txtName.text, let phone = txtPhoneNumber.text {
            if password == confirmPassword {
                Auth.auth().createUserAndRetrieveData(withEmail: email, password: password) { (result, error) in
                    guard let _ = result?.user.email, let uid = result?.user.uid, error == nil else {
                        alertMessage(in: self, title: "", message: error!.localizedDescription)
                        return
                    }
                    
                    let user = User(Uid: uid, Email: email, Username: name, Phone: phone)
                    
                    Firestore.firestore().collection(User.TableName).document(uid).setData(user.dictionary, completion: { (error) in
                        if let error = error {
                            alertMessage(in: self, title: "", message: "Register failed. \(error.localizedDescription)")
                        } else {
                            UserDefaults.standard.set(name, forKey: "DisplayName")
                            alertMessage(in: self, title: "", message: "Thank you for your registration", callback: { (action) in
                                self.navigationController?.popToRootViewController(animated: true)
                            })
                        }
                    })
                }
            } else {
                alertMessage(in: self, title: "", message: "Password does not match")
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
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

}
