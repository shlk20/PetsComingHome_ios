//
//  CommentsVC.swift
//  PetSearch
//
//  Created by KK on 2018/5/31.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CommentsVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    var petId: String!
    var petReference: DocumentReference?  // listen realtime updates of comment table from firebase
    var commentCollection: LocalCollection<Comment>!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var inputComment: UITextField! {
        didSet {
            inputComment.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
        }
    }
    @IBOutlet weak var lblCommentsCount: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> CommentsVC {
        let controller = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        return controller
    }
    
    @IBAction func didSendButton(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {
            alertMessage(in: self, title: "", message: "Please login in first") { (action) in
                let controller = LogInVC.fromStoryboard()
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return
        }
        
        let sv = self.displaySpinner(onView: self.view)
        let commentId = UUID.init().uuidString
        let date = NSDate().description
        let username = Auth.auth().currentUser!.displayName
        let comment = Comment(CommentId: commentId, ParentCommentId: "-1", Uid: uid, Username: username!, PetId: petId, Text: inputComment.text!, Date: date)

        Firestore.firestore().collection(Pet.TableName).document(petId).collection(Comment.TableName).addDocument(data: comment.dictionary) { (error) in
            self.removeSpinner(spinner: sv)
            if let error = error {
                alertMessage(in: self, title: "", message: "Add comment failed. \(error.localizedDescription)")
            } else {
                alertMessage(in: self, title: "", message: "Add comment successfull")
            }
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.isEnabled = false
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        let query = petReference!.collection(Comment.TableName)
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommentsVC.dismissKeyword))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        commentCollection.stopListening()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commentCollection.listen()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        let comment = commentCollection[indexPath.row]
        cell.popluate(comment: comment)
        return cell
    }
    
    func textFieldIsEmpty() -> Bool {
        guard let text = inputComment.text else { return true }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @objc func textFieldTextDidChange(_ sender: Any) {
        sendButton.isEnabled = !textFieldIsEmpty()
    }
    
    @objc func dismissKeyword() {
        self.view.endEditing(true)
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
}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var messageBody: UITextView!
    
    func popluate(comment: Comment) {
        lblSender.text = comment.Username
        messageBody.text = comment.Text
    }
}
