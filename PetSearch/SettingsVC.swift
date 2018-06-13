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
    @IBOutlet weak var swShowLostPets: UISwitch!
    @IBOutlet weak var swShowFoundPets: UISwitch!
    
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
        
        if (UserDefaults.standard.object(forKey: "showLostPetsAllowed") != nil)
        {
            if (UserDefaults.standard.object(forKey: "showLostPetsAllowed") as! Bool)
            {
              self.swShowLostPets.setOn(true, animated: false)
            }
            else
            {
                self.swShowLostPets.setOn(false, animated: false)
            }
        }
        else
        {
            self.swShowLostPets.setOn(true, animated: false)
        }
        
        if (UserDefaults.standard.object(forKey: "showFoundPetsAllowed") != nil)
        {
            if (UserDefaults.standard.object(forKey: "showFoundPetsAllowed") as! Bool)
            {
                self.swShowFoundPets.setOn(true, animated: false)
            }
            else
            {
                self.swShowFoundPets.setOn(false, animated: false)
            }
        }
        else
        {
            self.swShowFoundPets.setOn(true, animated: false)
        }
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(txtRadius.text, forKey: "radius")
        UserDefaults.standard.synchronize()
    }

    @IBAction func didSwitchedNotifications(_ sender: UISwitch) {
        guard let identifier = sender.restorationIdentifier else {
            return
        }
        if (sender.isOn)
        {
            UserDefaults.standard.set(true, forKey: identifier)
            UserDefaults.standard.synchronize()
        }
        else
        {
            UserDefaults.standard.set(false, forKey: identifier)
            UserDefaults.standard.synchronize()
        }
    }

}
