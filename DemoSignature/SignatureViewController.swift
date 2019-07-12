//
//  SignatureViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/9.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

protocol SignatureViewControllerDelegate: class {
    func whenSignatureEnded(_ signImage: UIImage)
}

class SignatureViewController: UIViewController {
    
    @IBOutlet weak var signatureView: SignatureView!
    @IBOutlet weak var rectLabel: UILabel!
    
    weak var delegate: SignatureViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signatureView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        OrientationManager.rotateDevice(to: .portrait)
//        OrientationManager.landscapeSupport = false
//        let orientationValue = UIInterfaceOrientation.portrait.rawValue
//        UIDevice.current.setValue(orientationValue, forKey: "orientation")
//        UIViewController.attemptRotationToDeviceOrientation()
    }

    
    @IBAction func onClearBoardClicked(_ sender: UIButton) {
        signatureView.clear()
    }
    
    @IBAction func onConfirnClicked(_ sender: UIButton) {
        
        guard signatureView.signatureExists, let image = self.signatureView.signatureImage() else { return }
        
        self.delegate?.whenSignatureEnded(image)
       
        self.view.removeFromSuperview()
        self.removeFromParent()
        
    }
    

}

extension SignatureViewController: SignatureViewDelegate {
    func whenSigning(on rect: CGRect) {
        let string = String(format: "(x: %.2f, y: %.2f, width: %.2f, height: %.2f)", rect.origin.x, rect.origin.y, rect.width, rect.height)
        DispatchQueue.main.async {
            self.rectLabel.text = string
        }
        
    }
    
    func signatureViewDidEditImage(_ signatureView: SignatureView) {
        
    }
    
    
}
