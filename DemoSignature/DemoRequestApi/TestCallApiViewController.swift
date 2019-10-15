//
//  TestCallApiViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/15.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class TestCallApiViewController: UIViewController {

    @IBOutlet weak var listTableView: UITableView!

    let buttons: [DemoRequest] = [
        .get,
        .headersWithGet,
        .headersWithPost,
        .json,
        .post,
        .postAnythingHeaders,
        .postAnthingParams(params: ["aaaaaa" : "aaaaValue", "bbbbbb" : "k0ekr23i,f4j34", "ccccccc" : "ejmiomfomgomo3"]),
        .postAnythingUrlEncoded(params: [
            "encodeA" : "1111111",
            "encodeB" : "22222222",
            "encodeC" : "3333333"
            ]),
        .postFormdata(datas: [
            "name" : "Superman",
            "age" : "30",
            "sex" : "male",
            "datas" : [
            UIImage(named: "man")!.pngData()!,
            UIImage(named: "women")!.pngData()!,
            UIImage(named: "placeholder")!.pngData()!
            ]
        ], mimeType: .png)
    ]
    
    let provider = RequestCommunicator<DemoRequest>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.delegate = self
        listTableView.dataSource = self
      
    }
    
    @IBAction func reload(_ sender: UIButton) {
        
    }
    
    
    
    func tryCallApi(with target: DemoRequest) {
        let vc: ResponseViewController = UIStoryboard(storyboard: .Main).instantiateViewController()
        
        
        provider.request(type: target) { (result) in
            switch result {
            case .success(let value):
                printLog(logs: ["\(value)"], title: "Successs")
                vc.response = value
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .failure(let error):
                printLog(logs: ["\(error)"], title: "Failure")
            }
        }
        
    }

}

extension TestCallApiViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttons.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell else { return UITableViewCell() }
        cell.titleLabel.text = buttons[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let requestType = buttons[indexPath.row]
        tryCallApi(with: requestType)
        
    }
}
