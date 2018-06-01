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

class PetListTVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet var petListView: UITableView!
    @IBOutlet var filterStatusView: UIStackView!
    @IBOutlet var filterBarHeight: NSLayoutConstraint!
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var btnLoginOrLogout: UIButton!
    private var isSignin = false {
        didSet {
            if isSignin {
                btnLoginOrLogout.setTitle("Sign out", for: UIControlState.normal)
            } else {
                btnLoginOrLogout.setTitle("Sign in", for: UIControlState.normal)
            }
        }
    }
    
    @IBAction func didTapSignButton(_ sender: Any) {
        if isSignin {
            // log out
            do {
                try Auth.auth().signOut()
                isSignin = false
            } catch let signOutError as NSError {
                alertMessage(in: self, title: "", message: "Error signing out: \(signOutError)")
            }
        } else {
            performSegue(withIdentifier: "showLoginView", sender: sender)
        }
    }
    
    @IBOutlet weak var sideMenu: UIView!
    private var sideMenuStatus = false { // false means the side menu is hidden
        didSet {
            if sideMenuStatus {
                sideMenuConstraint.constant = 0
            } else {
                sideMenuConstraint.constant = -200
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
    
    @IBAction func toggleSideMenu(_ sender: Any) {
        sideMenuStatus = !sideMenuStatus
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        petListView.delegate = self
        petListView.dataSource = self
        query = baseQuery()
        
        filterStatusView.isHidden = true
        filterBarHeight.constant = 0
        
        blurView.layer.cornerRadius = 15
        sideMenu.layer.shadowColor = UIColor.black.cgColor
        sideMenu.layer.shadowOffset = CGSize(width: 5, height: 0)
        
        sideMenuConstraint.constant = -200
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeQuery()
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = auth.currentUser?.uid {
                self.isSignin = true
            } else {
                self.isSignin = false
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sideMenuStatus = false
        stopObserving()
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        let controller = SinglePetVC.fromStoryboard()
        controller.pet = pets[indexPath.row]
        controller.petReference = documents[indexPath.row].reference
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func didTapFilter(_ sender: Any) {
        performSegue(withIdentifier: "showFilter", sender: sender)
    }
    
    @IBAction func didTapClearFilter(_ sender: Any) {
        self.query = baseQuery()
        observeQuery()
        filterStatusView.isHidden = true
        filterBarHeight.constant = 0
    }
    
    // It use for receiving data from the filter view controller
    @IBAction func didUseFilter(_ sender: UIStoryboardSegue) {
        guard let filterVC = sender.source as? FilterVC else { return }
        
        var filtered = baseQuery()
        var isFiltered = false
        
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
        
        if let status = filterVC.txtStatus.text, !status.isEmpty {
            filtered = filtered.whereField("Status", isEqualTo: status)
            isFiltered = true
        }
        
        if let missingSince = filterVC.txtSince.text, !missingSince.isEmpty {
            filtered = filtered.whereField("MissingSince", isEqualTo: missingSince)
            isFiltered = true
        }
        
        filterStatusView.isHidden = !isFiltered
        if isFiltered {
            filterBarHeight.constant = 44
        } else {
            filterBarHeight.constant = 0
        }
        self.query = filtered
        observeQuery()
    }
}


