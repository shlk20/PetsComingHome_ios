//
//  SettingsVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 6/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit

//Constants for the settings
let RADIUS : Int = 10


class SettingsVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtRadius: UITextField!
    //@IBOutlet weak var swNotifications: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set values for the fields
        if (UserDefaults.standard.object(forKey: "radius") != nil)
        {
            self.txtRadius.text = UserDefaults.standard.object(forKey: "radius") as? String
        }
        else
        {
            self.txtRadius.text = String(RADIUS)
        }
        
//        if (UserDefaults.standard.object(forKey: "notificationsAllowed") != nil)
//        {
//            if (UserDefaults.standard.object(forKey: "notificationsAllowed") as! Bool)
//            {
//              self.swNotifications.setOn(true, animated: false)
//            }
//            else
//            {
//                self.swNotifications.setOn(false, animated: false)
//            }
//        }
//        else
//        {
//            self.swNotifications.setOn(true, animated: false)
//        }
        
        self.txtRadius.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Restrict text field with only numbers, deletes all other stuff
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    //Saves user settings
    func textFieldDidEndEditing(_ textField: UITextField) {
        UserDefaults.standard.set(txtRadius.text, forKey: "radius")
        UserDefaults.standard.synchronize()
    }
    

    
//    @IBAction func didSwitchedNotifications(_ sender: UISwitch) {
//        if (sender.isOn)
//        {
//            UserDefaults.standard.set(true, forKey: "notificationsAllowed")
//            UserDefaults.standard.synchronize()
//        }
//        else
//        {
//            UserDefaults.standard.set(false, forKey: "notificationsAllowed")
//            UserDefaults.standard.synchronize()
//        }
//    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


/*
 Added StylesNC, StylesB, SettingsVC,
 Changed Main.stroyboard, PetListTVC
 */
