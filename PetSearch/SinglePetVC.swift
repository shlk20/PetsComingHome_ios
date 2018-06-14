//
//  SinglePetVC.swift
//  PetSearch
//
//  Created by Denis Eltcov on 5/9/18.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import Firebase

class SinglePetVC: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var pet: Pet?
    var petReference: DocumentReference?  // listen realtime updates of comment table from firebase
    
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var txtKind: UILabel!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtBreed: UILabel!
    @IBOutlet weak var txtColor: UILabel!
    @IBOutlet weak var txtStatus: UILabel!
    @IBOutlet weak var txtLocation: UILabel!
    @IBOutlet weak var txtGender: UILabel!
    @IBOutlet weak var txtDesexed: UILabel!
    @IBOutlet weak var txtAge: UILabel!
    @IBOutlet weak var txtChip: UILabel!
    @IBOutlet weak var txtMissing: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var inputComment: UITextField! {
        didSet {
            inputComment.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
        }
    }
    @IBOutlet weak var lblCommentsCount: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var commentCollection: LocalCollection<Comment>!
    
    let imageCache = NSCache<AnyObject, UIImage>()
    
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> SinglePetVC {
        let controller = storyboard.instantiateViewController(withIdentifier: "SinglePetVC") as! SinglePetVC
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pet Info"
        sendButton.isEnabled = false
        
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        

        
        let query = petReference!.collection(Comment.TableName).order(by: "Date")
        commentCollection = LocalCollection(query: query) { [unowned self] (comments) in
            if self.commentCollection.count == 0 {
                return
            }
            var indexPaths: [IndexPath] = []
            
            for comment in comments.filter({ $0.type == .added }) {
                let index = self.commentCollection.index(of: comment.document)!
                let indexPath = IndexPath(row: index, section: 0)
                indexPaths.append(indexPath)
            }
            
            self.tableView.insertRows(at: indexPaths, with: .automatic)
            self.lblCommentsCount.text = "(\(self.commentCollection.count))"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        var contentRect = CGRect.zero
        
        for view in self.contentView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        self.contentView.frame = contentRect
    }
    
    @IBAction func didSendButton(_ sender: Any) {
        guard let _ = Auth.auth().currentUser?.uid else {
            alertMessage(in: self, title: "", message: "Please login in first") { (action) in
                let controller = LogInVC.fromStoryboard()
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return
        }
        
        let sv = self.displaySpinner(onView: self.view)
        let date = Date().timestamp
        let username = UserDefaults.standard.string(forKey: "DisplayName")
        let email = UserDefaults.standard.string(forKey: "Email")
        let comment = Comment(UserDisplayName: username!, UserEmail: email!, Text: inputComment.text!, Date: date)
        
        Firestore.firestore().collection(Pet.TableName).document(pet!.PetId).collection(Comment.TableName).addDocument(data: comment.dictionary) { (error) in
            self.removeSpinner(spinner: sv)
            if let error = error {
                alertMessage(in: self, title: "", message: "Add comment failed. \(error.localizedDescription)")
            } else {
                self.inputComment.text = ""
                self.inputComment.resignFirstResponder()
                alertMessage(in: self, title: "", message: "Add comment successfull")
            }
        }
    }
    
    deinit {
        commentCollection.stopListening()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        let comment = commentCollection[indexPath.row]
        cell.popluate(comment: comment, publisher: comment.UserDisplayName)
        return cell
    }
    
    func textFieldIsEmpty() -> Bool {
        guard let text = inputComment.text else { return true }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    @objc func textFieldTextDidChange(_ sender: Any) {
        sendButton.isEnabled = !textFieldIsEmpty()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commentCollection.listen()
        
        guard let pet = pet else { return }
        
        if let imageFromCache = imageCache.object(forKey: pet.Photo as AnyObject) {
            self.petImage.image = imageFromCache
        } else {
            let imageRef = Storage.storage().reference().child(pet.Photo)
            imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                //self.petImage.setToCircle()
                self.imageCache.setObject(image!, forKey: pet.Photo as AnyObject)
                self.petImage.image = image
            }
        }
        
        txtKind.text = pet.Kind
        txtKind.sizeToFit()
        txtName.text = pet.Name
        txtName.sizeToFit()
        txtBreed.text = pet.Breed
        txtBreed.sizeToFit()
        txtColor.text = pet.Color
        txtColor.sizeToFit()
        txtStatus.text = pet.Status
        txtStatus.sizeToFit()
        txtLocation.text = pet.Region
        txtLocation.sizeToFit()
        txtGender.text = pet.Gender
        txtGender.sizeToFit()
        txtDesexed.text = pet.Desexed
        txtDesexed.sizeToFit()
        txtAge.text = pet.Age.description
        txtAge.sizeToFit()
        txtChip.text = pet.MicrochipNumber
        txtChip.sizeToFit()
        let date = Date(timeIntervalSince1970: TimeInterval(pet.MissingSince)/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: date)
        txtMissing.text = strDate
        txtMissing.sizeToFit()
        txtDescription.text = pet.Description
    }
}


class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var messageBody: UILabel!
    
    func popluate(comment: Comment, publisher: String) {
        lblSender.text = comment.UserDisplayName
        messageBody.text = comment.Text
    }
}
