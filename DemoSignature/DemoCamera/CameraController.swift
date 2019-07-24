//
//  CameraController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/9.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import AVFoundation

class CameraController {
    
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        
        func createSession() {
            captureSession = AVCaptureSession()
        }
        
        func configureSessionDevice() throws {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: .video, position: .unspecified)
            let cameras = session.devices.compactMap { $0 }
            
            for camera in cameras {
                
            }
        }
        
        func configureSessionInput() throws {
            
        }
        
        func configureSessionOutput() throws {
            
        }
        
        DispatchQueue.init(label: "prepare").async {
            do {
                
                
                
            } catch let error {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func createSession() throws {
        captureSession = AVCaptureSession()
        
    }
}
