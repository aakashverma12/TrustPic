//
//  SecondViewController.swift
//  TrustPic
//
//  Created by Aakash verma on 15/04/19.
//  Copyright © 2019 norsky. All rights reserved.
//

import UIKit
import Just

class SecondViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var blackShadow: UIView!
    @IBOutlet weak var newImg: UIImageView!
    var mod:Int = 0;
    var imagePicker = UIImagePickerController();
    var loggedinUser:Int = UserDefaults.standard.integer(forKey: "userId");
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inName.delegate = self;
        self.inDesc.delegate = self;
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        blackShadow.layer.shadowColor = UIColor.black.cgColor;
        blackShadow.layer.shadowOffset = CGSize(width: 1, height: 3);
        blackShadow.layer.shadowOpacity = 0.36;
        blackShadow.layer.shadowRadius = 6.0;
        blackShadow.clipsToBounds = false;
        blackShadow.layer.cornerRadius = 16.0;
        newImg.layer.cornerRadius = 16.0;
        //Keyboard optimizations
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //Keyboard optimizations
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height/2)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //Upload Image
    @IBAction func upLoadImageBtnPressed(_ sender: AnyObject) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage {
            newImg.contentMode = .scaleAspectFill
            newImg.image = pickedImage
            mod = 1
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
    
    @IBOutlet weak var inName: UITextField!
    @IBOutlet weak var inDesc: UITextField!
    
    @IBAction func uploadImg(_ sender: UIButton) {
        if (((inName.text) == "") || ((inDesc.text) == ""))
        {
            errAlert(instring: "All Fields are Mandatory");
        } else if (mod == 0){
            errAlert(instring: "Please select an Image");
        } else {
            // Do the Magic
            self.showSpinner(onView: self.view)
            let magic = Just.post("http://bansalsonia.com/aakashv.me/trustpic/insertpost.php", data: ["inName": inName.text ?? "", "prof": inDesc.text ?? "", "user_id": loggedinUser]);
            if magic.ok {
                let response:String = magic.text ?? "0";
                print(magic.text ?? "0")
                imageUploadRequest(imageView: newImg, param: ["post_id": response])
            }
        }
        
    }
    
    func errAlert(instring : String) {
        let alert = UIAlertController(title: "Error", message: instring, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func imageUploadRequest(imageView: UIImageView, param: [String:String]?) {
        
        let myUrl = NSURL(string: "http://bansalsonia.com/aakashv.me/trustpic/uploadimg.php");
        
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = imageView.image?.jpegData(compressionQuality:0.5)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
        //myActivityIndicator.startAnimating();
        
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest,
         completionHandler: {
            (data, response, error) -> Void in
            if let data = data {
                
                // You can print out response object
                print("******* response = \(String(describing: response))")
                
                print(data.count)
                // you can use data here
                
                // Print out reponse body
                let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print("****** response data = \(responseString!)")
                
                let json =  try!JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                
                print("json value \(String(describing: json))")
                
                
                // create the alert
                let alert = UIAlertController(title: "Yay!", message: "Your Post is live now, wait till users rate it :)", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                
                DispatchQueue.main.async {
                    self.removeSpinner()
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    self.inName.text = "";
                    self.inDesc.text = "";
                }
                //var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &err)
                
            } else if let error = error {
                print(error)
            }
        })
        task.resume()
        
        
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "userpic"
        
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
}// extension for impage uploading

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

var vSpinner : UIView?

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
