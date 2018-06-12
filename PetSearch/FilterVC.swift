//
//  FilterVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import CoreLocation

class FilterVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtBreed: UITextField!
    @IBOutlet weak var txtColor: UITextField!
    @IBOutlet weak var txtAge: UITextField!
    @IBOutlet weak var txtMC: UITextField!
    @IBOutlet weak var txtSize: RemoveCursor! {
        didSet {
            txtSize.inputView = sizePickerView
        }
    }
    @IBOutlet weak var txtKind: RemoveCursor! {
        didSet {
            txtKind.inputView = kindPickerView
        }
    }
    @IBOutlet weak var txtGender: RemoveCursor! {
        didSet {
            txtGender.inputView = genderPickerView
        }
    }
    @IBOutlet weak var txtDesexed: RemoveCursor! {
        didSet {
            txtDesexed.inputView = desexedPickerView
        }
    }
    @IBOutlet weak var txtStatus: RemoveCursor! {
        didSet {
            txtStatus.inputView = statusPickerView
        }
    }
    @IBOutlet weak var txtSince: RemoveCursor! {
        didSet {
            txtSince.inputView = missingDatePickerView
        }
    }
    @IBOutlet weak var btnMap: StylesB!
    
    var longitude: CLLocationDegrees?
    var latitude: CLLocationDegrees?
    
    private var needAdjustView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtName.delegate = self
        txtBreed.delegate = self
        txtColor.delegate = self
        txtAge.delegate = self
        txtMC.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FilterVC.dismissKeyword))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func dismissKeyword() {
        self.view.endEditing(true)
    }
    
    @IBAction func didTapFilterMap(_ sender: Any) {
        let controller = MapVC.fromStoryboard()
        controller.title = "Choose search area"
        controller.mapMode = .filterLocation
        controller.delegateController = self
        self.navigationController?.pushViewController(controller, animated: true)
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
    
    private lazy var sizePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.frame = CGRect(x: 0, y: 0, width: 320, height: 150)
        return pickerView
    }()
    
    private lazy var kindPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.frame = CGRect(x: 0, y: 0, width: 320, height: 150)
        return pickerView
    }()
    
    private lazy var genderPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.frame = CGRect(x: 0, y: 0, width: 320, height: 150)
        return pickerView
    }()
    
    private lazy var desexedPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.frame = CGRect(x: 0, y: 0, width: 320, height: 150)
        return pickerView
    }()
    
    private lazy var statusPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.frame = CGRect(x: 0, y: 0, width: 320, height: 150)
        return pickerView
    }()
    
    private lazy var missingDatePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        datePicker.frame = CGRect(x: 0, y: 0, width: 320, height: 150)
        return datePicker
    }()
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = components.day?.description, let month = components.month?.description, let year = components.year?.description {
            txtSince.text = day + "/" + month + "/" + year
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case sizePickerView:
            return Pet.sizes.count
        case kindPickerView:
            return Pet.kinds.count
        case genderPickerView:
            return Pet.genders.count
        case desexedPickerView:
            return Pet.desexeds.count
        case statusPickerView:
            return Pet.status.count
        case _:
            fatalError("Unhandled picker view: \(pickerView)")
        }
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent: Int) -> String? {
        switch pickerView {
        case sizePickerView:
            return Pet.sizes[row]
        case kindPickerView:
            return Pet.kinds[row]
        case genderPickerView:
            return Pet.genders[row]
        case desexedPickerView:
            return Pet.desexeds[row]
        case statusPickerView:
            return Pet.status[row]
        case _:
            fatalError("Unhandled picker view: \(pickerView)")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case sizePickerView:
            txtSize.text = Pet.sizes[row]
        case kindPickerView:
            txtKind.text = Pet.kinds[row]
        case genderPickerView:
            txtGender.text = Pet.genders[row]
        case desexedPickerView:
            txtDesexed.text = Pet.desexeds[row]
        case statusPickerView:
            txtStatus.text = Pet.status[row]
        case _:
            fatalError("Unhandled picker view: \(pickerView)")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.txtName {
            self.txtBreed.becomeFirstResponder()
        } else if textField == self.txtBreed {
            self.txtColor.becomeFirstResponder()
        } else if textField == self.txtColor {
            self.txtAge.becomeFirstResponder()
        } else if textField == self.txtAge {
            self.txtMC.becomeFirstResponder()
        }
        return true
    }
}
