//
//  CustomSwitchCell.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/11.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class CustomSwitchCell: UITableViewCell {

    @IBOutlet weak var switchBaseView: UIView!
    @IBOutlet weak var moveBallView: UIView!
    @IBOutlet weak var peopleImageView: UIImageView!
    
    enum switchDirection {
        case left
        case right
    }
    
    var currentSwitchDirect: switchDirection = .right
    
    let womenColor = UIColor(red: 255/255.0, green: 82/255.0, blue: 60/255.0, alpha: 0.85)
    let manColor = UIColor(red: 52/255.0, green: 120/255.0, blue: 246/255.0, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        switchUiConfigure()
        setupSwitch()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    func switchUiConfigure() {
        switchBaseView.layer.cornerRadius = switchBaseView.frame.height * 0.5
        switchBaseView.layer.masksToBounds = true
        
        moveBallView.layer.cornerRadius = moveBallView.frame.height * 0.5
        moveBallView.layer.masksToBounds = true
        
        peopleImageView.layer.cornerRadius = peopleImageView.frame.height * 0.5
        peopleImageView.layer.masksToBounds = true
    }

    func setupSwitch() {
        moveBallView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(recognizer:)))
        moveBallView.addGestureRecognizer(tap)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(recognizer:)))
        swipeLeft.direction = .left
        moveBallView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(recognizer:)))
        swipeRight.direction = .right
        
        moveBallView.addGestureRecognizer(swipeRight)
    }
    
    
    @objc
    func didTap(recognizer: UITapGestureRecognizer) {
        switchAction()
    }
    
    @objc
    func didSwipe(recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .left:
            if currentSwitchDirect == .right {
                switchAction()
            }
        case .right:
            if currentSwitchDirect == .left {
                switchAction()
            }
        default:
            break
        }

    }
    
    func switchAction() {
        let padding: CGFloat = 1
        let moveDistance: CGFloat = switchBaseView.frame.width - moveBallView.frame.width - padding * 2
        
        
        
        let imagePadding: CGFloat = 10
        let peopleMoveDistance = switchBaseView.frame.width - peopleImageView.frame.width - imagePadding * 2
        
        switch currentSwitchDirect {
        case .left:
            
            UIView.animate(withDuration: 0.3, animations: {
                self.peopleImageView.alpha = 0.0
                self.moveBallView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.switchBaseView.backgroundColor = self.womenColor
                
                
            }) { (end) in
                self.peopleImageView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.peopleImageView.alpha = 1.0
                self.peopleImageView.image = #imageLiteral(resourceName: "women")
            }
        case .right:
            
            UIView.animate(withDuration: 0.3, animations: {
                self.peopleImageView.alpha = 0.0
                self.moveBallView.transform = CGAffineTransform(translationX: -moveDistance, y: 0)
                self.switchBaseView.backgroundColor = self.manColor
                
            }) { (end) in
                self.peopleImageView.transform = CGAffineTransform(translationX: peopleMoveDistance, y: 0)
                self.peopleImageView.alpha = 1.0
                self.peopleImageView.image = #imageLiteral(resourceName: "man")
                
            }
        }
        
        currentSwitchDirect = currentSwitchDirect == .left ? .right : .left
    }
    
}
