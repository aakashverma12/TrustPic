//
//  FirstViewController.swift
//  TrustPic
//
//  Created by Aakash verma on 15/04/19.
//  Copyright © 2019 norsky. All rights reserved.
//

import UIKit
import Just

class FirstViewController: UIViewController {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var blackShadow: UIView!
    @IBOutlet weak var trust: UILabel!
    @IBOutlet weak var Pic: UILabel!
    @IBOutlet var progs: [UIView]!
    @IBOutlet var sliders: [ColorSlider]!
    var imgArr: Array<Any> = [];
    var nameArr: Array<String> = [];
    var profArr: Array<String> = [];
    var i:Int = 0;
    var maxImg:Int = 0;
    var maxProf:Int = 0;
    @IBOutlet weak var topName: UILabel!
    @IBOutlet weak var topProfession: UILabel!
    
    @IBAction func slideHandler(_ sender: ColorSlider) {
        // this function handles the slider color change
        let inval = Int(sender.value);
        if (inval < 3) {
            sender.minimumTrackTintColor = UIColor(red:1.00, green:0.18, blue:0.33, alpha:1.0);
        } else if (inval >= 3 && inval <= 6 ) {
            sender.minimumTrackTintColor = UIColor(red:0.33, green:0.64, blue:0.97, alpha:1.0);
        } else {
            sender.minimumTrackTintColor = UIColor(red:0.29, green:0.91, blue:0.57, alpha:1.0);
        }
    }
    
    @IBAction func nextImage(_ sender: UIButton) {
        //This handles loading of next image
        profilePic.downloaded(from: "http://bansalsonia.com/aakashv.me/trustpic/uploads/\(imgArr[i+1])");
        topName.text = nameArr[i+1];
        topProfession.text = profArr[i+1];
        i = i + 1;
        if (i == (maxImg - 2))
        {
            sender.isEnabled = false;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Let's get the Picposts
        let r = Just.post("http://bansalsonia.com/aakashv.me/trustpic/getimages.php");
        if r.ok {
            let response:String = r.text ?? "none";
            imgArr = response.components(separatedBy: "#");
            print(imgArr);
            profilePic.downloaded(from: "http://bansalsonia.com/aakashv.me/trustpic/uploads/\(imgArr[0])");
            maxImg = imgArr.count;
            nameArr = (imgArr[maxImg - 1] as AnyObject).components(separatedBy: "*");
            maxProf = nameArr.count;
            profArr = (nameArr[maxProf - 1] as AnyObject).components(separatedBy: "$");
            topName.text = nameArr[0];
            topProfession.text = profArr[0];
        }
        
        profilePic.layer.cornerRadius = 16.0;
        profilePic.layer.masksToBounds = true;
        
        blackShadow.layer.shadowColor = UIColor.black.cgColor;
        blackShadow.layer.shadowOffset = CGSize(width: 1, height: 3);
        blackShadow.layer.shadowOpacity = 0.36;
        blackShadow.layer.shadowRadius = 6.0;
        blackShadow.clipsToBounds = false;
        blackShadow.layer.cornerRadius = 16.0;
        for firstSlider in sliders {
            firstSlider.setThumbImage(UIImage(), for: .normal);
            firstSlider.layer.shadowColor = UIColor.black.cgColor;
            firstSlider.layer.shadowOffset = CGSize(width: 0, height: 3);
            firstSlider.layer.shadowOpacity = 0.2;
            firstSlider.layer.shadowRadius = 6.0;
            firstSlider.clipsToBounds = false;
        }
        for progBack in progs {
            progBack.layer.borderWidth = 1.0;
            let opacity:CGFloat = 0.1;
            progBack.layer.borderColor =    UIColor.black.withAlphaComponent(opacity).cgColor;
            progBack.layer.cornerRadius = 4.0;
            progBack.layer.masksToBounds = true;
        }
    }
}

open class enUILabel : UILabel {
    @IBInspectable open var characterSpacing:CGFloat = 1 {
        didSet {
            let attributedString = NSMutableAttributedString(string: self.text!)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: self.characterSpacing, range: NSRange(location: 0, length: attributedString.length))
            self.attributedText = attributedString
        }
    }
}

open class ColorSlider : UISlider {
    @IBInspectable open var trackWidth:CGFloat = 2 {
        didSet {setNeedsDisplay()}
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
