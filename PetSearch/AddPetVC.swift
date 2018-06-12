//
//  AddPetVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class AddPetVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let locationManager = CLLocationManager()
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var _uid: String!
    private var selectedImage: UIImage?
    private var needAdjustView = false

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtBreed: UITextField!
    @IBOutlet weak var txtColor: UITextField!
    @IBOutlet weak var txtAge: UITextField!
    @IBOutlet weak var txtMcNumber: UITextField!
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
    var location: (CLLocation, String)?
    @IBOutlet weak var btnMap: StylesB!
    
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
    
    @IBAction func didTapSelectLocation(_ sender: Any) {
        let controller = MapVC.fromStoryboard()
        controller.title = "Select your location"
        controller.mapMode = .chooseLocation
        controller.delegateController = self
        self.navigationController?.pushViewController(controller, animated: true)
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
        let status = txtStatus?.text ?? ""
        
        var sinceTimestamp = UInt64(0)
        if let since = txtSince?.text {
            print(since)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd'/'MM'/'yyyy"
            sinceTimestamp = UInt64(dateFormatter.date(from: since)!.timestamp)
        }
        
            
        var imageData = Data()
        imageData = UIImageJPEGRepresentation(image, 0.1)! as Data  //compress the image and makes it to be the Data type
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let imageId = UUID.init().uuidString
        
        let _ = Storage.storage().reference().child("images").child(imageId).putData(imageData, metadata: metaData) {
            (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            if metadata.size > 0 {
                let pet = Pet(PetId: petId, Uid: self._uid, Name: name, Breed: breed, Color: color, Age: Int(age)!, MicrochipNumber: mcNumber, Photo: "images/" + imageId, Size: size, Kind: kind, Gender: gender, Desexed: desexed, Status: status, MissingSince: sinceTimestamp, Description: "", Latitude: self.location!.0.coordinate.latitude, Longitude: self.location!.0.coordinate.longitude, Region: self.location!.1)
                
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
        
        txtName.delegate = self
        txtBreed.delegate = self
        txtColor.delegate = self
        txtAge.delegate = self
        txtMcNumber.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPetVC.dismissKeyword))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
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
            self.txtMcNumber.becomeFirstResponder()
        }
        return true
    }
}

extension AddPetVC: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        GMSGeocoder().reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)) { (result, error) in
            if let address = result?.firstResult() {
                let subLocality = address.subLocality ?? (address.locality ?? "")
                let locality = address.locality ?? ""
                self.location = (locations.last!, subLocality + ", " + locality)
            }
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
