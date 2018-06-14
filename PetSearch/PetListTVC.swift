//
//  PetListTVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import CoreLocation
import UserNotifications

class PetListTVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var sideMenuSwipeGestureRecogniser: UISwipeGestureRecognizer!
    
    @IBOutlet var petListView: UITableView!
    @IBOutlet var filterStatusView: UIStackView!
    @IBOutlet var filterBarHeight: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var btnLoginOrLogout: UIButton!
    private let locationManager = CLLocationManager()
    var restrictByLatMin: Double = 0.0
    var restrictByLatMax: Double = 0.0
    var restrictByLonMin: Double = 0.0
    var restrictByLonMax: Double = 0.0
    var currentLatitude: Double = 0.0
    var currentLongitude: Double = 0.0
    
    var isFiltered = false
    var ownPetsList = false {
        didSet {
            if ownPetsList, let uid = UserDefaults.standard.string(forKey: "UserId") {
                var baseQuery = self.baseQuery()
                baseQuery = baseQuery.whereField("Uid", isEqualTo: uid)
                self.query = baseQuery
            } else {
                self.query = baseQuery()
            }
            observeQuery()
        }
    }
    
    private var isSignin = false {
        didSet {
            if isSignin {
                btnLoginOrLogout.setTitle("Sign out", for: UIControlState.normal)
            } else {
                btnLoginOrLogout.setTitle("Sign in", for: UIControlState.normal)
            }
        }
    }
    
    @IBOutlet weak var sideMenu: UIView!
    private var sideMenuStatus = false { // false means the side menu is hidden
        didSet {
            if sideMenuStatus {
                print("Open the side menu. \(self.sideMenu.center.x)")
                if self.sideMenu.center.x == -100.0 {
                    self.view.addGestureRecognizer(sideMenuSwipeGestureRecogniser)
                    UIView.animate(withDuration: 0.5) {
                        //self.sideMenuConstraint.constant += 100
                        self.sideMenu.center.x += self.sideMenu.bounds.width
                    }
                    //self.navigationController?.navigationBar.layer.isHidden = true
                }
            } else {
                print("Close the side menu. \(self.sideMenu.center.x)")
                if self.sideMenu.center.x == 100.0 {
                    self.view.removeGestureRecognizer(sideMenuSwipeGestureRecogniser)
                    UIView.animate(withDuration: 0.5) {
                        self.sideMenu.center.x -= self.sideMenu.bounds.width
                    }
                    //self.navigationController?.navigationBar.layer.isHidden = false
                }
            }
        }
    }

    private var pets: [Pet] = []
    private var documents: [DocumentSnapshot] = []
    
    private var listener: ListenerRegistration?
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
    
    fileprivate func observeQuery() {
        guard let query = query else { return }
        stopObserving()
        
        if restrictByLatMax != 0.0, restrictByLonMax != 0.0, !ownPetsList {
            // do range filter
            let queryFilter = query.whereField("Longitude", isLessThanOrEqualTo: restrictByLonMax).whereField("Longitude", isGreaterThanOrEqualTo: restrictByLonMin)
            listener = queryFilter.addSnapshotListener { (snapshot, error) in
                var petsFIlter: [Pet] = []
                var documentsFilter: [DocumentSnapshot] = []
                guard let snapshot = snapshot else {
                    return
                }
                let _ = snapshot.documents.map { (document) -> Bool in
                    guard let model = Pet(dictionary: document.data()) else { return false }
                    
                    if model.Latitude >= self.restrictByLatMin, model.Latitude <= self.restrictByLatMax {
                        petsFIlter.append(model)
                        documentsFilter.append(document)
                    }
                    
                    return true
                }
                
                self.pets = petsFIlter
                self.documents = documentsFilter
                
                self.petListView.reloadData()
            }
            
        } else {
            listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Cannot fetch results: \(error!)")
                    return
                }
                
                let models = snapshot.documents.map { (document) -> Pet in
                    if let model = Pet(dictionary: document.data()) {
                        return model
                    } else {
                        fatalError("Unable to initialize type \(Pet.self) with dictionary \(document.data())")
                    }
                }
                
                self.pets = models
                self.documents = snapshot.documents
                
                self.petListView.reloadData()
            }
        }
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery() -> Query {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db.collection(Pet.TableName).limit(to: 20)
    }
    
    @IBAction func addPet(_ sender: UIButton) {
        if isSignin {
            performSegue(withIdentifier: "AddPet", sender: sender)
        } else {
            alertMessage(in: self, title: "", message: "Please sign in first") { (action) in
                self.performSegue(withIdentifier: "showLoginView", sender: sender)
            }
        }
    }
    
    @IBAction func didTapShowMapButton(_ sender: Any) {
        let controller = MapVC.fromStoryboard()
        controller.title = "Poor little things around you"
        controller.documents = self.documents // sending data to the mapVC
        controller.mapMode = .petAroundYou
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func didTapSignButton(_ sender: Any) {
        if isSignin {
            // sign out
            do {
                try Auth.auth().signOut()
                if UserDefaults.standard.integer(forKey: "SigninType") == 2 {
                    GIDSignIn.sharedInstance().disconnect()
                    GIDSignIn.sharedInstance().signOut()
                }
                UserDefaults.standard.removeObject(forKey: "UserId")
                UserDefaults.standard.removeObject(forKey: "DisplayName")
                UserDefaults.standard.removeObject(forKey: "SigninType")
                sideMenuStatus = false
                isSignin = false
            } catch let signOutError as NSError {
                alertMessage(in: self, title: "", message: "Error signing out: \(signOutError)")
            }
        } else {
            // sign in
            performSegue(withIdentifier: "showLoginView", sender: sender)
        }
    }
    
    @IBAction func didTapSettings(_ sender: Any) {
        performSegue(withIdentifier: "showSettings", sender: sender)
    }
    
    @IBAction func didTapPetsList(_ sender: Any) {
        ownPetsList = false
        sideMenuStatus = false
    }
    
    @IBAction func didTapMyPets(_ sender: Any) {
        if isSignin {
            ownPetsList = true
            sideMenuStatus = false
        } else {
            alertMessage(in: self, title: "", message: "Please sign in first") { (action) in
                self.performSegue(withIdentifier: "showLoginView", sender: sender)
            }
        }
    }
    
    @IBAction func toggleSideMenu(_ sender: Any) {
        sideMenuStatus = !sideMenuStatus
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        petListView.delegate = self
        petListView.dataSource = self
        
        filterStatusView.isHidden = true
        filterBarHeight.constant = 0
        
        blurView.layer.cornerRadius = 15
        sideMenu.layer.shadowColor = UIColor.black.cgColor
        sideMenu.layer.shadowOffset = CGSize(width: 5, height: 0)
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        
        sideMenuSwipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(hideSideBar))
        sideMenuSwipeGestureRecogniser.direction = .left
    }
    
    @objc func hideSideBar() {
        sideMenuStatus = !sideMenuStatus
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = auth.currentUser?.uid {
                self.isSignin = true
            } else {
                self.isSignin = false
            }
        }
        
        if !ownPetsList {
            if !isFiltered {
                pushCoordinates(lat: currentLatitude, lon: currentLongitude)
            }
            var baseQuery = self.baseQuery()
            if (UserDefaults.standard.object(forKey: "showLostPetsAllowed") != nil)
            {
                if !UserDefaults.standard.bool(forKey: "showLostPetsAllowed") {
                    baseQuery = baseQuery.whereField("Status", isEqualTo: "Found")
                    baseQuery = baseQuery.whereField("Status", isEqualTo: "Missed")
                }
            }
            if (UserDefaults.standard.object(forKey: "showFoundPetsAllowed") != nil)
            {
                if !UserDefaults.standard.bool(forKey: "showFoundPetsAllowed") {
                    baseQuery = baseQuery.whereField("Status", isEqualTo: "Lost")
                    baseQuery = baseQuery.whereField("Status", isEqualTo: "Missed")
                }
            }
            query = baseQuery
        }
        
        observeQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.layer.zPosition = 0
        Auth.auth().removeStateDidChangeListener(handle!)
        stopObserving()
        if sideMenuStatus {
            sideMenuStatus = !sideMenuStatus
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PetCell", for: indexPath) as! PetTableViewCell
        let pet = pets[indexPath.row]
        cell.popluate(pet: pet)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !sideMenuStatus {
            let controller = SinglePetVC.fromStoryboard()
            controller.pet = pets[indexPath.row]
            controller.petReference = documents[indexPath.row].reference
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if ownPetsList {
            let dismissedMarker = UITableViewRowAction(style: .normal, title: "Dismissed") { (action, index) in
                let petReference = self.documents[indexPath.row].reference
                petReference.updateData(["Status": "Dismissed"])
                alertMessage(in: self, title: "", message: "Sorry about that")
            }
            
            return [dismissedMarker]
        }
        
        return []
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if ownPetsList {
            return UITableViewCellEditingStyle.delete
        }
        return UITableViewCellEditingStyle.none
    }

    @IBAction func didTapFilter(_ sender: Any) {
        performSegue(withIdentifier: "showFilter", sender: sender)
    }
    
    @IBAction func didTapClearFilter(_ sender: Any) {
        pushCoordinates(lat: currentLatitude, lon: currentLongitude)
        self.query = baseQuery()
        //observeQuery()
        filterStatusView.isHidden = true
        filterBarHeight.constant = 0
        isFiltered = false
    }
    
    // It use for receiving data from the filter view controller
    @IBAction func didUseFilter(_ sender: UIStoryboardSegue) {
        guard let filterVC = sender.source as? FilterVC else { return }
        
        var filtered = baseQuery()
        
        if let name = filterVC.txtName.text, !name.isEmpty {
            filtered = filtered.whereField("Name", isEqualTo: name)
            isFiltered = true
        }
        
        if let breed = filterVC.txtBreed.text, !breed.isEmpty {
            filtered = filtered.whereField("Breed", isEqualTo: breed)
            isFiltered = true
        }
        
        if let color = filterVC.txtColor.text, !color.isEmpty {
            filtered = filtered.whereField("Color", isEqualTo: color)
            isFiltered = true
        }
        
        if let age = filterVC.txtAge.text, !age.isEmpty {
            filtered = filtered.whereField("Age", isEqualTo: age)
            isFiltered = true
        }
        
        if let microchipNumber = filterVC.txtMC.text, !microchipNumber.isEmpty {
            filtered = filtered.whereField("MicrochipNumber", isEqualTo: microchipNumber)
            isFiltered = true
        }
        
        if let size = filterVC.txtSize.text, !size.isEmpty {
            filtered = filtered.whereField("Size", isEqualTo: size)
            isFiltered = true
        }
        
        if let kind = filterVC.txtKind.text, !kind.isEmpty {
            filtered = filtered.whereField("Kind", isEqualTo: kind)
            isFiltered = true
        }
        
        if let gender = filterVC.txtGender.text, !gender.isEmpty {
            filtered = filtered.whereField("Gender", isEqualTo: gender)
            isFiltered = true
        }
        
        if let desexed = filterVC.txtDesexed.text, !desexed.isEmpty {
            filtered = filtered.whereField("Desexed", isEqualTo: desexed)
            isFiltered = true
        }
        
        if let missingSince = filterVC.txtSince.text, !missingSince.isEmpty {
            filtered = filtered.whereField("MissingSince", isEqualTo: missingSince)
            isFiltered = true
        }
        
        if let longitude = filterVC.longitude, let latitude = filterVC.latitude {
            pushCoordinates(lat: latitude, lon: longitude)
            isFiltered = true
        }
        
        filterStatusView.isHidden = !isFiltered
        if isFiltered {
            filterBarHeight.constant = 44
        } else {
            filterBarHeight.constant = 0
        }
        self.query = filtered
        //observeQuery()
    }
    
    
    func deg2rad(rad:Double) -> Double {
        return rad * Double.pi / 180
    }
    
    func pushCoordinates(lat:Double , lon:Double){
        //Search radius
        var radius: Double
        
        if (UserDefaults.standard.object(forKey: "radius") != nil)
        {
            radius = UserDefaults.standard.double(forKey: "radius")
        }
        else
        {
            radius = Double(RADIUS)
        }
        
        restrictByLatMin = lat - (radius / 111)
        restrictByLatMax = lat + (radius / 111)
        
        restrictByLonMin = lon - radius / fabs(cos(deg2rad(rad: lat)) * 111)
        restrictByLonMax = lon + radius / fabs(cos(deg2rad(rad: lat)) * 111)
        
    }
}

extension PetListTVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = locations.last else { return }
        pushCoordinates(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        currentLatitude = location.coordinate.latitude
        currentLongitude = location.coordinate.longitude
        observeQuery()
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
    }
}
