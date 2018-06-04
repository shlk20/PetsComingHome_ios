//
//  LogInVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LogInVC: UIViewController, GIDSignInUIDelegate {

    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var txtEmail: RemoveCursor!
    @IBOutlet weak var txtPassword: RemoveCursor!
    var btnGoogleSignIn: GIDSignInButton!
    
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> LogInVC {
        let controller = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInVC
        return controller
    }
    
    @IBAction func didLogin(_ sender: UIButton) {
        if let email = txtEmail.text, !email.isEmpty, let password = txtPassword.text, !password.isEmpty {
            let sv = self.displaySpinner(onView: self.view)
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    alertMessage(in: self, title: "", message: error.localizedDescription)
                    return
                } else {
                    alertMessage(in: self, title: "", message: "Signin successful", callback: { (action) in
                        Firestore.firestore().collection(User.TableName).whereField("Uid", isEqualTo: user!.uid).getDocuments(completion: { (snapshot, error) in
                            guard let documents = snapshot?.documents else { return }
                            self.removeSpinner(spinner: sv)
                            for document in documents {
                                let user = User(dictionary: document.data())
                                UserDefaults.standard.set(user?.Username, forKey: "DisplayName")
                                UserDefaults.standard.set(1, forKey: "SigninType") // email 
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // put google signin button to the view
        btnGoogleSignIn = GIDSignInButton()
        btnGoogleSignIn.style = .standard
        btnGoogleSignIn.colorScheme = .dark
        btnGoogleSignIn.center = view.center
        view.addSubview(btnGoogleSignIn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LogInVC.receiveToggleAuthUINotification(_:)), name: NSNotification.Name(rawValue: "ToggleAuthUINotification"), object: nil)
    }
    
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.name.rawValue == "ToggleAuthUINotification" {
            let sv = self.displaySpinner(onView: self.view)
            
            guard let userInfo = notification.userInfo as? [String:Bool] else { return }
            if notification.userInfo != nil, userInfo["status"]! {
                
                guard let user = notification.object as? GIDGoogleUser, let authentication = user.authentication else { return }
                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
                Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
        
                    if let currentUser = authResult?.user {
                        print("auth successful. \(currentUser.uid)")
                        Firestore.firestore().collection(User.TableName).whereField("Uid", isEqualTo: currentUser.uid).getDocuments(completion: { (snapshot, error) in
                            guard let documents = snapshot?.documents else { return }
                            self.removeSpinner(spinner: sv)
                            if documents.count == 0 { // if there is a new user
                                let controller = RegisterVC.fromStoryboard()
                                controller.googleAccount = authResult
                                self.navigationController?.pushViewController(controller, animated: true)
                                return
                            }
                            for document in documents {
                                let user = User(dictionary: document.data())
                                UserDefaults.standard.set(user?.Username, forKey: "DisplayName")
                                UserDefaults.standard.set(2, forKey: "SigninType") // google account
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        })
                    }
                }
            } else {
                alertMessage(in: self, title: "", message: "Fail to sign in with Google")
            }
        }
    }

}
