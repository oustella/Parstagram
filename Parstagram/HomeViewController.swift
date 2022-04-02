//
//  HomeViewController.swift
//  Parstagram
//
//  Created by OSL on 3/19/22.
//

import UIKit
import AlamofireImage
import Parse
import MessageInputBar

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var posts = [PFObject]()
    let myRefreshControl = UIRefreshControl()
    var postCount: Int!
    let incrementLoad = 1
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var selectedPost: PFObject!
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }

    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    @objc func keyboardWillHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder() // evaluate 'canBecomeFirstResponder'
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postCount = incrementLoad
        queryParse(postCount: postCount)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        myRefreshControl.addTarget(self, action: #selector(queryParse), for: .valueChanged)
        tableView.insertSubview(myRefreshControl, at: 0)
        
        // hide the comment bar when done
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        commentBar.delegate = self
        commentBar.inputTextView.placeholder = "Add a comment... "
        commentBar.sendButton.title = "Post"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Calling viewDidAppear")
        queryParse(postCount: postCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = post["comment"] as? [PFObject] ?? []
//        print(comments)
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.postImage.af.setImage(withURL: url)
            
            return cell
            
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            let comment = comments[indexPath.row - 1]
            print(comment)
            let user = comment["author"] as! PFUser
            cell.commentAuthor.text = user.username as! String
            cell.commentTextLabel.text = comment["text"] as! String
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MakeCommentTableViewCell")!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comment"] as? [PFObject]) ?? []
        return comments.count + 2  // one for post one for make comment
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section + 1 == posts.count {
            postCount = postCount + incrementLoad
            queryParse(postCount: postCount)
        }
    }
    
    @objc func queryParse(postCount: Int) -> Void {
        let query = PFQuery(className: "Post")
        query.includeKeys(["author", "comment", "comment.author"])
        query.limit = postCount
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                print("Retrieving posts...")
                self.posts = posts!
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else { return }
        delegate.window?.rootViewController = loginViewController
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        selectedPost = post
        let comments = post["comment"] as? [PFObject] ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // add a comment
        let comment = PFObject(className: "Comment")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()

        selectedPost.add(comment, forKey: "comment")
        selectedPost.saveInBackground { success, error in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
        tableView.reloadData()
        
        // clear out the comment text and dimiss the comment bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
//    func messageInputBar(_ inputBar: MessageInputBar, didChangeIntrinsicContentTo size: CGSize) {
//        <#code#>
//    }
//
//    func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) {
//        <#code#>
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
