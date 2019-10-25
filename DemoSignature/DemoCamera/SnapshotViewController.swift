//
//  SnapshotViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/9.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit
import AVFoundation

class SnapshotViewController: UIViewController {

    @IBOutlet weak var snapshotImageView: UIImageView!
    
    @IBOutlet weak var cameraBaseView: UIView!
    
    
    var imagePicker: UIImagePickerController!
    var overlayView: UIView!
    
    let sqlHelper = SQLiteHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func creatTable(_ sender: UIButton) {
//        sqlHelper.createTable()
        sqlHelper.createTable(tableName: "DemoTable", columns: [
            .int(name: "id", asPrimaryKey: true, notNull: true, autoIncrement: true),
            .text(name: "userName", notNull: true),
            .text(name: "phoneNumber", notNull: false),
            .real(name: "distance", notNull: false)
        ]) { result in
            switch result {
            case .success:
                print("Create table successful")
            case .failure(let error): //(let error):
                if case .Step(let message) = error {
                    print("Create table failure: \(message)")
                }
                
                if case .OpenDatabase(let message) = error {
                    print("OpenDatabase table failure: \(message)")
                }
            }
        }
    }
    
    var insertsCount: Int = 1
    
    @IBAction func write(_ sender: UIButton) {
//        sqlHelper.insert()
//        let action = SQLiteAction.insert(tableName: "DemoTable", columnValue: [
//                .text(column: "userName", value: "Kin\(insertsCount)"),
//                .text(column: "phoneNumber", value: "091912345\(insertsCount)"),
//                .real(column: "distance", value: Double(100 * insertsCount))
//            ])
//
//        sqlHelper.insert(action: action) { result in
//                switch result {
//                case .success:
//                    printLog(logs: [action.statementString], title: "Insert success")
//                case .failure(let error):
//                    printLog(logs: [error.message], title: "Insert failure")
//                }
//        }
//
        insertsCount += 1
        
        ///
        let teststring = SQLiteAction.select(columns: nil, fromTable: "DemoTable", wheres: [
            // WHERE id = 1
//            .wheres(column: "id", condition: .equal, beCompared: "1"),
            // AND userName LIKE '%Bo%'
            .wheres(column: "userName", condition: .like(as: "in"), beCompared: nil),
            .wheres(column: nil, condition: .limit, beCompared: "5"),
            .wheres(column: "phoneNumber", condition: .like(as: "09"), beCompared: nil),
            .wheres(column: nil, condition: .orderBy(column: "id", arrange: .desc), beCompared: nil),
            .wheres(column: "id", condition: .greatOrEqual, beCompared: "0")
            ]).statementString
        
        printLog(logs: [teststring], title: "TestSelect")
//        SQLiteOperators.orderBy(column: "==", arrange: .desc)
        ///
    }
    
    @IBAction func insertArray(_ sender: UIButton) {
        sqlHelper.forArraysInsert(arrays: ["Andy", "Bob", "Cindy", "David", "Eric", "Gaso", "Hellen"])
        
    }
    
    @IBAction func query(_ sender: UIButton) {
        sqlHelper.query()
    }
    
    @IBAction func update(_ sender: UIButton) {
        sqlHelper.update()
        sqlHelper.query()
    }
    @IBAction func queryAll(_ sender: UIButton) {
        sqlHelper.queryAll()
    }
    
    @IBAction func deleteRow(_ sender: UIButton) {
        sqlHelper.delete()
    }
    
    @IBAction func toMVVMPracticePage(_ sender: Any) {
        let main = UIStoryboard(storyboard: .Main)
        
        let mvvmVC: PracticeMVVMViewController = main.instantiateViewController()
        mvvmVC.modalPresentationStyle = .fullScreen
        present(mvvmVC, animated: true, completion: nil)
    }
    
    
    @IBAction func onCameraClicked(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        // check device authorization
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            // already authrized
            prepareCamera()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { (isAuth) in
                guard isAuth else {
                    self.convienceAlert(alert: "相機沒有授權", alertMessage: "請至設定->App->開啟相機。", actions: ["確認", "取消"], completion: nil) { (action) in
                        switch action.title {
                        case "確認": self.openSetting()
                        default: break
                        }
                    }
                    return
                }
                self.prepareCamera()
            }
        }
    }
    
    var currentOverlayFrame: CGRect = .zero
    private func customOverlayView(frame: CGRect) -> UIView {
        let overlayFrame = CGRect(
            x: frame.width * 0.3 * 0.5,
            y: frame.height * 0.4 * 0.5,
            width: frame.width * 0.7,
            height: frame.height * 0.5)
        
        overlayView = UIView(frame: frame)
        overlayView.alpha = 0.6
        overlayView.backgroundColor = .black
        
        let overlayer = CAShapeLayer()
        let path = CGMutablePath()
        let radius: CGFloat = (frame.width - 60) * 0.5
        
        currentOverlayFrame = overlayFrame
        
        path.addRect(overlayFrame)
//        path.addArc(center: overlayView.center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.width, height: overlayView.frame.height))
        
        overlayer.backgroundColor = UIColor.black.cgColor
        overlayer.path = path
        overlayer.fillRule = .evenOdd
        
        overlayView.layer.mask = overlayer
        overlayView.clipsToBounds = true
        
        return overlayView
        
    }
    
    @objc
    func whenCaptureEnd(sender: UIButton) {
        overlayView.removeFromSuperview()
    }
    
    /// Camera configure
    private func prepareCamera() {
        
        imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.cameraDevice = .rear
//        imagePicker.showsCameraControls = false
        imagePicker.delegate = self
        
        let session = AVCaptureSession()
        
        
        DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true, completion: {
                let frame = CGRect(origin: .zero, size: CGSize(width: self.imagePicker.view.frame.width,
                                                               height: self.imagePicker.view.frame.height - 180))
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: AVCaptureSession())
                self.imagePicker.cameraOverlayView = self.customOverlayView(frame: frame)
            })
        }
    }
    
}
extension SnapshotViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
//        picker.view.removeFromSuperview()
//        picker.removeFromParent()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        print("Picker info: \(info)")
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            convienceAlert(alert: "沒有相片!", alertMessage: nil, actions: [], completion: nil, actionCompletion: nil)
            return }
        
        print("Image size: \(image.size)")
        let imageWidthScale = overlayView.frame.size.width / currentOverlayFrame.width
        let imageHeightScale = overlayView.frame.size.height / currentOverlayFrame.height
        let imageOverlayFrame = CGRect(
            x: currentOverlayFrame.origin.x * imageWidthScale,
            y: currentOverlayFrame.origin.y * imageHeightScale,
            width: currentOverlayFrame.width * imageWidthScale,
            height: currentOverlayFrame.height * imageHeightScale)
        
        let newImage = image.subImage(withRect: imageOverlayFrame)

        DispatchQueue.main.async {
            self.snapshotImageView.image = newImage
        }
        
        
        
    }
}


