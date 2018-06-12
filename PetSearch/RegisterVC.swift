//
//  RegisterVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class RegisterVC: UIViewController {

    private var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    var googleAccount: AuthDataResult?
    
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> RegisterVC {
        let controller = storyboard.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        return controller
    }
    
    @IBAction func didRegister(_ sender: UIButton) {
        if let email = txtEmail.text, let password = txtPassword.text, let confirmPassword = txtConfirmPassword.text, let name = txtName.text, let phone = txtPhoneNumber.text {
            if password == confirmPassword {
                if (self.googleAccount != nil) {
                    Auth.auth().currentUser?.updatePassword(to: password, completion: { (error) in
                        if let error = error {
                            alertMessage(in: self, title: "", message: "Register failed. \(error.localizedDescription)")
                            return
                        } else {
                            let user = User(Uid: self.googleAccount!.user.uid, Email: email, Username: name, Phone: phone)
                            
                            self.saveUser(user)
                        }
                    })
                } else {
                    Auth.auth().createUserAndRetrieveData(withEmail: email, password: password) { (result, error) in
                        guard let _ = result?.user.email, let uid = result?.user.uid, error == nil else {
                            alertMessage(in: self, title: "", message: error!.localizedDescription)
                            return
                        }
                        
                        let user = User(Uid: uid, Email: email, Username: name, Phone: phone)
                        
                        self.saveUser(user)
                    }
                }
            } else {
                alertMessage(in: self, title: "", message: "Password does not match")
            }
        }
    }
    
    private func saveUser(_ user: User) {
        Firestore.firestore().collection(User.TableName).document(user.Uid).setData(user.dictionary, completion: { (error) in
            if let error = error {
                alertMessage(in: self, title: "", message: "Register failed. \(error.localizedDescription)")
            } else {
                UserDefaults.standard.set(user.Uid, forKey: "UserId")
                UserDefaults.standard.set(user.Username, forKey: "DisplayName")
                alertMessage(in: self, title: "", message: "Thank you for your registration", callback: { (action) in
                    self.navigationController?.popToRootViewController(animated: true)
                })
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.googleAccount != nil) {
            UserDefaults.standard.set(2, forKey: "SigninType")
        } else {
            UserDefaults.standard.set(1, forKey: "SigninType")
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPetVC.dismissKeyword))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if let googleAccount = googleAccount {
            txtName.text = googleAccount.user.displayName
            txtEmail.text = googleAccount.user.email
            txtEmail.isEnabled = false
        }
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
