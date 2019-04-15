//
//  FirstViewController.swift
//  TrustPic
//
//  Created by Aakash verma on 15/04/19.
//  Copyright © 2019 norsky. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var blackShadow: UIView!
    @IBOutlet weak var trust: UILabel!
    @IBOutlet weak var Pic: UILabel!
    @IBOutlet weak var firstSlider: UISlider!
    @IBOutlet weak var progBack: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePic.layer.cornerRadius = 16.0;
        profilePic.layer.masksToBounds = true;
        blackShadow.layer.shadowColor = UIColor.black.cgColor;
        blackShadow.layer.shadowOffset = CGSize(width: 1, height: 3);
        blackShadow.layer.shadowOpacity = 0.36;
        blackShadow.layer.shadowRadius = 6.0;
        blackShadow.clipsToBounds = false;
        blackShadow.layer.cornerRadius = 16.0;
        firstSlider.setThumbImage(UIImage(), for: .normal);
        firstSlider.layer.shadowColor = UIColor.black.cgColor;
        firstSlider.layer.shadowOffset = CGSize(width: 0, height: 3);
        firstSlider.layer.shadowOpacity = 0.2;
        firstSlider.layer.shadowRadius = 6.0;
        firstSlider.clipsToBounds = false;
        progBack.layer.borderWidth = 1.0;
        let opacity:CGFloat = 0.1;
        progBack.layer.borderColor =    UIColor.black.withAlphaComponent(opacity).cgColor;
        progBack.layer.cornerRadius = 4.0;
        progBack.layer.masksToBounds = true;
        
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

