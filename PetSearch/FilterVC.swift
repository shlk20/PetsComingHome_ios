//
//  FilterVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit

class FilterVC: UIViewController {

    @IBOutlet weak var txtName: RemoveCursor!
    @IBOutlet weak var txtBreed: UITextField!
    @IBOutlet weak var txtColor: RemoveCursor!
    @IBOutlet weak var txtAge: RemoveCursor!
    @IBOutlet weak var txtMC: RemoveCursor!
    @IBOutlet weak var txtSize: RemoveCursor!
    @IBOutlet weak var txtKind: RemoveCursor!
    @IBOutlet weak var txtGender: RemoveCursor!
    @IBOutlet weak var txtDesexed: RemoveCursor!
    @IBOutlet weak var txtStatus: RemoveCursor!
    @IBOutlet weak var txtSince: RemoveCursor!
    private var needAdjustView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FilterVC.dismissKeyword))
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
}
