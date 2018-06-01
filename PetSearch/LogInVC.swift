//
//  LogInVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import Firebase

class LogInVC: UIViewController {

    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var txtEmail: RemoveCursor!
    @IBOutlet weak var txtPassword: RemoveCursor!
    
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> LogInVC {
        let controller = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInVC
        return controller
    }
    
    @IBAction func didLogin(_ sender: UIButton) {
        if let email = txtEmail.text, !email.isEmpty, let password = txtPassword.text, !password.isEmpty {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    alertMessage(in: self, title: "", message: error.localizedDescription)
                    return
                } else {
                    alertMessage(in: self, title: "", message: "Signin successful", callback: { (action) in
                        Firestore.firestore().collection(User.TableName).whereField("Uid", isEqualTo: user!.uid).getDocuments(completion: { (snapshot, error) in
                            guard let documents = snapshot?.documents else { return }
                            for document in documents {
                                let user = User(dictionary: document.data())
                                UserDefaults.standard.set(user?.Username, forKey: "DisplayName")
                            }
                        })
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                }
            }
        } else {
            alertMessage(in: self, title: "", message: "Please input your username or password")
        }
    }
    
    @IBAction func doSignUp(_ sender: UIButton) {
        performSegue(withIdentifier: "showRegisterView", sender: sender)
    }

}
