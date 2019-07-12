//
//  DynamicViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/10.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class DynamicViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let sectionTitle: [String] = ["第一行", "第二行", "第三行", "第四行"]
    
    let datas = [
        ["1-1", "1-2", "1-3", "1-4", "1-5", "1-6", "1-7"],
        ["2-1", "2-2", "2-3", "2-4", "2-5", "2-6", "2-7"],
        ["3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7"],
        ["4-1", "4-2", "4-3", "4-4", "4-5", "4-6", "4-7"]
    ]
    
    var whichClose = [true, true, true , true]
    
    var cacheHeaderViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        // Do any additional setup after loading the view.
    }

    func prepareHeaderView(on section: Int) -> UIView {
        
        if section <= cacheHeaderViews.count - 1 {
            return cacheHeaderViews[section]
        }
        
        let title = sectionTitle[section]
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        headerView.backgroundColor = UIColor(red: 135 / 255.0, green: 180 / 255.0, blue: 200 / 255.0, alpha: 0.9)
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width * 0.5, height: 40))
        titleLabel.text = title
        headerView.addSubview(titleLabel)
        
        let btn = UIButton(frame: CGRect(x: tableView.frame.width - 40, y: 0, width: 40, height: 40))
        btn.setTitle("展開", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.tag = section
        btn.addTarget(self, action: #selector(whenClickedOn(_:)), for: .touchUpInside)
        headerView.addSubview(btn)
        
        cacheHeaderViews.append(headerView)
        return headerView
        
    }
    
    @objc
    func whenClickedOn(_ sender: UIButton) {
        
        let details = datas[sender.tag]
        var rowsIndexPath: [IndexPath] = []
        for i in 0 ..< details.count {
            rowsIndexPath.append(IndexPath(item: i, section: sender.tag))
        }
        
        if whichClose[sender.tag] {
            whichClose[sender.tag] = false
            tableView.reloadSections(IndexSet(arrayLiteral: sender.tag), with: .fade)
            sender.setTitle("收起", for: .normal)
            tableView.scrollToRow(at: IndexPath(row: (details.count - 1), section: sender.tag), at: .bottom, animated: true)
        } else {
            whichClose[sender.tag] = true
            tableView.deleteRows(at: rowsIndexPath, with: .fade)
            sender.setTitle("展開", for: .normal)
        }
        
        DispatchQueue.main.async {
            self.tableView.layoutIfNeeded()
        }
    }
    
}

extension DynamicViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return whichClose[section] ? 0 : datas[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return prepareHeaderView(on: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as? DetailCell else { return UITableViewCell() }
        
        cell.numbeLabel.text = datas[indexPath.section][indexPath.row]
        if indexPath.row % 2 != 0 {
            cell.backgroundColor = .gray
        } else {
            cell.backgroundColor = .white
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
}

class DetailCell: UITableViewCell {
    
    
    @IBOutlet weak var numbeLabel: UILabel!
    
    
}
