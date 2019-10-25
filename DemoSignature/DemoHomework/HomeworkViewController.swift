//
//  HomeworkViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/25.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class HomeworkViewController: UIViewController {

    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var listScrollView: UIScrollView!
    
    @IBOutlet weak var baseStackView: UIStackView!
    // 邀請好友
    @IBOutlet weak var inviteHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inviteTableView: UITableView!
    // 轉帳
    @IBOutlet weak var transferTableView: UITableView!
    
    @IBOutlet weak var searchBaseView: UIView!
    
    @IBOutlet weak var friendsSearchBar: UISearchBar!
    
    @IBOutlet weak var friendsCountLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
    }
    
    
    private func initViews() {
        inviteTableView.delegate = self
        inviteTableView.dataSource = self
        inviteTableView.separatorStyle = .none
        
        transferTableView.delegate = self
        transferTableView.dataSource = self
        transferTableView.separatorStyle = .none
    }

    // TODO: - 1. adjust height constraints timming.
    // then increase/decrease the scrollView's contentSize.
    
    // TODO: - 2. handle inviteTable's collapse.
    
    // TODO: - 3. handle move searchBar to top when touched.
    
    /* on cellModel */
    // TODO: - 1. handle animation when accept/inaccept friends invite action.
    // TODO: - 2. remove inviteItem when action and move front with next one.
    
    
}

extension HomeworkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        
        if tableView === inviteTableView {
            rows = 1
        } else if tableView === transferTableView {
            rows = 2
        }
        
        return rows
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView === inviteTableView {
            
        } else if tableView === transferTableView {
            
        }
        
        return UITableViewCell()
    }
}
