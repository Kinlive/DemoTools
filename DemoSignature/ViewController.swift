//
//  ViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/8.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signatureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        signatureView.delegate = self
        
    }
    
    
    /// example for signature
    @IBAction func onSignClearClicked(_ sender: UIButton) {
//        signatureView.clear()
    }
    
    @IBAction func onSignClicked(_ sender: UIButton) {
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        guard let signVC = main.instantiateViewController(withIdentifier: "SignatureViewController") as? SignatureViewController else { return }
        
        OrientationManager.rotateDevice(to: .landscapeLeft)
//        // 解鎖landscape
//        OrientationManager.landscapeSupport = true
//        // 很重要的強制設備轉向
//        let orientationValue = UIInterfaceOrientation.landscapeLeft.rawValue
//        UIDevice.current.setValue(orientationValue, forKey: "orientation")
//        UIViewController.attemptRotationToDeviceOrientation()
        
        signVC.delegate = self
        signVC.view.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        addChild(signVC)
        view.addSubview(signVC.view)
        signVC.didMove(toParent: self)
        
        UIView.animate(withDuration: 0.4) {
            signVC.view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    

}

//extension ViewController: SignatureViewDelegate {
//    func whenSigning(on rect: CGRect) {
//
//    }
//
//    func signatureViewDidEditImage(_ signatureView: SignatureView) {
//
//    }
//
//
//
//}

extension ViewController: SignatureViewControllerDelegate {
    func whenSignatureEnded(_ signImage: UIImage) {
        let mergeImage = signImage.mergeImageToSmall(with: UIImage(named: "placeholder")!)//.mergeImage(with: UIImage(named: "placeholder")!)
        self.signatureImageView.image = mergeImage
    }
}
