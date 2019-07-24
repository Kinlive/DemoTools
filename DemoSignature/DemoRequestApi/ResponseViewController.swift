//
//  ResponseViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/24.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class ResponseViewController: UIViewController {

  
    @IBOutlet weak var responseTextView: UITextView!
    
    var response: CommunicatorResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preparTransfer()
    }
    
    func preparTransfer() {
        guard let data = response?.data else { return }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            let prettyPrintData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            let prettyPrint = String(data: prettyPrintData, encoding: .utf8)
            
            DispatchQueue.main.async {
                self.responseTextView.text = prettyPrint
            }
        } catch let error {
            printLog(logs: [error.localizedDescription], title: "transferData Error")
        }
        
    
    }
}
