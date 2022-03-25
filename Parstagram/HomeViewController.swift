//
//  HomeViewController.swift
//  Parstagram
//
//  Created by OSL on 3/19/22.
//

import UIKit
import AlamofireImage
import Parse

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var posts = [PFObject]()
    let myRefreshControl = UIRefreshControl()
    var postCount: Int!
    let incrementLoad = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postCount = incrementLoad
        queryParse(postCount: postCount)
        tableView.delegate = self
        tableView.dataSource = self
        myRefreshControl.addTarget(self, action: #selector(queryParse), for: .valueChanged)
        tableView.insertSubview(myRefreshControl, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Calling viewDidAppear")
        queryParse(postCount: postCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.postImage.af.setImage(withURL: url)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            postCount = postCount + incrementLoad
            queryParse(postCount: postCount)
        }
    }
    
    @objc func queryParse(postCount: Int) -> Void {
//        postCount = incrementLoad
        let query = PFQuery(className: "Post")
        query.includeKey("author")
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

//    @objc func queryMoreParse() {
//        postCount = postCount + incrementLoad
//        let query = PFQuery(className: "Post")
//        query.includeKey("author")
//        query.limit = postCount
//        query.order(byDescending: "createdAt")
//        query.findObjectsInBackground { (posts, error) in
//            if posts != nil {
//                print("retrieve more posts!")
//                self.posts = posts!
//                self.tableView.reloadData()
//            }
//        }
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
