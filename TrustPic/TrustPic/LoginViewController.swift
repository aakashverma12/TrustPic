//
//  LoginViewController.swift
//  TrustPic
//
//  Created by Aakash verma on 21/04/19.
//  Copyright © 2019 norsky. All rights reserved.
//

import UIKit
import SwiftVideoBackground
import Just

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var backView: UIView!
    @IBOutlet weak var trustSub: enUILabel!
    @IBOutlet weak var trustTitle: UIView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    var loggedinUser:Int = 0;
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.username.delegate = self;
        self.password.delegate = self;
        //Check if user already logged in
        loggedinUser = UserDefaults.standard.integer(forKey: "userId");
        if ((loggedinUser != -1) && (loggedinUser != 0))
        {
            continueBtn.isHidden = false;
        }
        
        //background video playback
        try? VideoBackground.shared.play(view: backView, videoName: "VideoBackX", videoType: "mp4", darkness: 0.05)
        
        //Style for the login buttons
        username.attributedPlaceholder = NSAttributedString(string:"Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        password.attributedPlaceholder = NSAttributedString(string:"Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        username.layer.borderColor = UIColor.white.cgColor;
        password.layer.borderColor = UIColor.white.cgColor;
        username.layer.borderWidth = 1.0;
        password.layer.borderWidth = 1.0;
        username.layer.cornerRadius = 8.0;
        password.layer.cornerRadius = 8.0;
        loginBtn.layer.borderWidth = 1.0;
        loginBtn.layer.cornerRadius = 8.0;
        loginBtn.layer.borderColor = UIColor.white.cgColor;
        
        //animations
        UIView.animate(withDuration: 1, delay: 2, options: [.curveEaseOut], animations: {
            self.trustSub.alpha = 1;
        }, completion: nil)
        
        UIView.animate(withDuration: 2, delay: 0, options: [.curveEaseOut], animations: {
            self.trustTitle.alpha = 1;
            self.trustTitle.center.y -= 50;
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 4, options: [.curveEaseInOut], animations: {
            self.trustTitle.center.y -= 100;
            self.trustSub.center.y -= 100;
            self.username.center.y -= 50;
            self.password.center.y -= 50;
            self.username.alpha = 1;
            self.password.alpha = 1;
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 5, options: [.curveEaseOut], animations: {
            self.loginBtn.alpha = 1;
            self.continueBtn.alpha = 1;
        }, completion: nil)
        
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
    
    // Login function
    @IBAction func loginControl(_ sender: UIButton) {
        if ((username.text == nil ) || (password.text == nil))
        {
            errAlert(instring: "All Fields are Mandatory");
        } else {
            //Check for login
            let p = Just.post("http://bansalsonia.com/aakashv.me/trustpic/login.php", data: ["username": username.text ?? "", "password": password.text ?? ""]);
            if p.ok {
                if (p.text != "0")
                {
                    // Login success
                    let userId:Int = Int(p.text ?? "0") ?? 0;
                    // Save in user defaults
                    UserDefaults.standard.set(userId,forKey: "userId");
                    UserDefaults.standard.set(self.username.text ?? "",forKey: "username");
                    performSegue(withIdentifier: "loginSegue", sender: nil);
                } else {
                    // Ask to register
                    // create the alert
                    let alert = UIAlertController(title: "Error", message: "The email or password is incorrect.", preferredStyle: UIAlertController.Style.alert)
                    
                    // add the actions (buttons)
                    alert.addAction(UIAlertAction(title: "Try again", style: UIAlertAction.Style.default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Register", style: UIAlertAction.Style.default, handler: { action in
                        // Register the user, Send OTP
                        //0. Send the request for OTP
                        var otpval:String = "";
                        let otp = Just.post("http://bansalsonia.com/aakashv.me/trustpic/sendotp.php", data: ["email": self.username.text ?? ""]);
                        if otp.ok {
                            otpval = otp.text ?? "";
                        }
                        //1. Create the alert controller.
                        let alert = UIAlertController(title: "Register", message: "A OTP has been sent to your email, please enter it here", preferredStyle: .alert)
                        
                        //2. Add the text field. You can configure it however you need.
                        alert.addTextField { (textField) in
                            textField.text = ""
                        }
                        
                        // 3. Grab the value from the text field, and print it when the user clicks OK.
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                            if (otpval == textField?.text ?? "")
                            {
                                // Show success box
                                let alert = UIAlertController(title: "Success", message: "Welcome to TrustPic", preferredStyle: UIAlertController.Style.alert)
                                let c = Just.post("http://bansalsonia.com/aakashv.me/trustpic/createuser.php", data: ["username": self.username.text ?? "", "password": self.password.text ?? ""])
                                if c.ok {
                                    let userId:Int = Int(c.text ?? "0") ?? 0;
                                    // Save in user defaults
                                    UserDefaults.standard.set(userId,forKey: "userId");
                                    UserDefaults.standard.set(self.username.text ?? "",forKey: "username");
                                    self.performSegue(withIdentifier: "loginSegue", sender: nil);
                                }
                                // add an action (button)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                
                                // show the alert
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                self.errAlert(instring: "Wrong OTP");
                            };
                        }))
                        
                        // 4. Present the alert.
                        self.present(alert, animated: true, completion: nil)
                    }))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    
                }
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
    
}
