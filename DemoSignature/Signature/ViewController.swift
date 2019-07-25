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
    @IBOutlet weak var uploadingLabel: UILabel!
    @IBOutlet weak var startUpload: UIButton!
    
    
    let uploader = StreamsHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        signatureView.delegate = self
        uploader.delegate = self
        startUpload.isHidden = true
        startUpload.alpha = 0.0
        
        // prepare big data
        uploader.testUploadBigData()
    }
    
    
    /// example for signature
    @IBAction func onSignClearClicked(_ sender: UIButton) {
        uploader.upload(with: nil)
       
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

extension ViewController: StreamHandlerDelegate {
    func needHeaders(on model: DownloadModelProtocol) -> [String : String] {
        return [:]
    }
 
    func sending(currentSize: Double, percent: Double, to destination: URL, with model: DownloadModelProtocol?) {
  
        var unit: String = ""
        var dividedSize: Double = 0
        
        if Double(currentSize) / Double(1e9) >= 1.0 {
            dividedSize = currentSize / Double(1e9)
            unit = "Gbyte"
        } else if Double(currentSize) / Double(1e6) >= 1.0 {
            dividedSize = currentSize / Double(1e6)
            unit = "Mbyte"
        } else {
            dividedSize = currentSize / Double(1e3)
            unit = "Kbyte"
        }
        
        let sizePrint = String(format: "%.2f", dividedSize) + unit
        let percentStr = String(format: "%.2f", percent)
        
        DispatchQueue.main.async {
            self.uploadingLabel.text = "currentSize: \(sizePrint) \n completed \(percentStr)%"
        }
    }

    func prepareDataEnd() {

        DispatchQueue.main.async {
            self.startUpload.isHidden = false
            UIView.animate(withDuration: 1.0, animations: {
                self.startUpload.alpha = 1.0
            })
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
