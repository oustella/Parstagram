//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by OSL on 3/31/22.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

//    var imageIsChanged = false
    var currentUser = PFUser.current()!
    @IBOutlet weak var profileImage: UIImageView!
 
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.makeRounded()
        showLatestPic()
        userNameLabel.text = currentUser["username"] as! String
    }
    
    @IBAction func onTapProfileImage(_ sender: Any) {
        print("tap on image")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageAspectScaled(toFill: size)
       
        profileImage.image = scaledImage
//        imageIsChanged = true
        updateProfilePicture()
        dismiss(animated: true)
        
    }
    
    func updateProfilePicture() {
        let profile = PFObject(className: "Profile")
        let imageData = profileImage.image!.pngData()
        let file = PFFileObject(name:"profile.png", data: imageData!)
        profile["image"] = file
        profile["owner"] = currentUser
        profile["bio"] = "Bio text"
        
        currentUser.add(profile, forKey: "profile")
        currentUser.saveInBackground { (success, error) in
            if success {
                print("Success!")
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func showLatestPic() {
        let profiles = currentUser["profile"] as? [PFObject] ?? []
        if !profiles.isEmpty {
            let latestProfile = profiles.last!
            latestProfile.fetchIfNeededInBackground { (profile, error) in
                if error == nil {
                    let imageFile = profile?["image"] as! PFFileObject
                    let urlString = imageFile.url!
                    let url = URL(string: urlString)!
                    self.profileImage.af.setImage(withURL: url)
                } else {
                    print(error?.localizedDescription)
                }
            }
        }
    }


}


extension UIImageView {

    func makeRounded() {

        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
