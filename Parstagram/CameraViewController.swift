//
//  CameraViewController.swift
//  Parstagram
//
//  Created by OSL on 3/21/22.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    
    var homeVC = HomeViewController()
    var imageIsChanged = false // use this to detect whether user has uploaded a new pic
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onImageTap(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageScaled(to: size)
        
        imageView.image = scaledImage
        imageIsChanged = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        
        if self.imageIsChanged {
            let post = PFObject(className: "Post")
            post["caption"] = captionTextField.text
            post["author"] = PFUser.current()
            
            let imageData = imageView.image!.pngData()
            let file = PFFileObject(name: "image.png", data: imageData!)
            post["image"] = file
            
            post.saveInBackground { success, error in
                if success {
                    self.dismiss(animated: true)
                    self.present(self.homeVC, animated: true, completion: nil)
                    print("Success!")
                } else {
                    print(error?.localizedDescription)
                }
            }
        } else {
            displayAlert(withTitle: "Oops", message: "A picture is required.")
        }
    }
    
    func displayAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

