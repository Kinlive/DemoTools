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
    
    @IBOutlet weak var baseViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var baseStackView: UIStackView!
    // 邀請好友
    @IBOutlet weak var inviteHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inviteTableView: UITableView!
    // 轉帳
    
    @IBOutlet weak var transferHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var transferTableView: UITableView!
    
    @IBOutlet weak var searchBaseView: UIView!
    
    @IBOutlet weak var friendsSearchBar: UISearchBar!
    
    @IBOutlet weak var friendsCountLabel: UILabel!
    
    lazy var viewModel: HomeworkViewModel = {
       return HomeworkViewModel(delegate: self)
    }()
    
    let searchText: Observable<String> = Observable()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleScrollViewContents()
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        handleScrollViewContents()
//    }
    
    private func initViews() {
        
        inviteTableView.isScrollEnabled = false
        transferTableView.isScrollEnabled = false
        listScrollView.delegate = self
        listScrollView.bounces = false
        //inviteTableView.bounces = true
        
        
        inviteTableView.register(UINib(nibName: InviteCell.storyboardIdentifier, bundle: nil), forCellReuseIdentifier: InviteCell.storyboardIdentifier)
         transferTableView.register(UINib(nibName: TransferCell.storyboardIdentifier, bundle: nil), forCellReuseIdentifier: TransferCell.storyboardIdentifier)
        
        inviteTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        inviteTableView.delegate = self
        inviteTableView.dataSource = self
        inviteTableView.separatorStyle = .none
        inviteTableView.estimatedRowHeight = 30
        inviteTableView.rowHeight = UITableView.automaticDimension
        
        transferTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        transferTableView.delegate = self
        transferTableView.dataSource = self
        transferTableView.separatorStyle = .none
        transferTableView.estimatedRowHeight = 30
        transferTableView.rowHeight = UITableView.automaticDimension
       
    }

    // TODO: - 1. adjust height constraints timming.
    // then increase/decrease the scrollView's contentSize.
    
    // TODO: - 2. handle inviteTable's collapse.
    
    // TODO: - 3. handle move searchBar to top when touched.
    
    /* on cellModel */
    // TODO: - 1. handle animation when accept/inaccept friends invite action.
    // TODO: - 2. remove inviteItem when action and move front with next one.
    
    func handleScrollViewContents() {
        
        // handel invite table
        let cellHeight: CGFloat = 60
        let cellCounts: CGFloat = 10
        
        let adjustHeight = cellHeight * cellCounts
        
        inviteHeightConstraint.constant = adjustHeight
    
        let transferCellsHeight = cellHeight * 20
        //transferHeightConstraint.constant = transferCellsHeight
        
        listScrollView.contentSize = CGSize(
        width: listScrollView.frame.width,
        height: adjustHeight + transferCellsHeight + searchBaseView.frame.height)
        
        baseViewHeightConstraint.constant = listScrollView.contentSize.height
    
    }
    
}

extension HomeworkViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        /*let yOffset = scrollView.contentOffset.y
        let searchBaseViewMinY = searchBaseView.frame.origin.y
        
        if scrollView === self.listScrollView {
            
            if yOffset >= searchBaseViewMinY {
                transferTableView.isScrollEnabled = true
                listScrollView.isScrollEnabled = false
            }
        }
        
        if scrollView === self.transferTableView {
            
            if yOffset < transferTableView.frame.origin.y {
                self.listScrollView.isScrollEnabled = true
                transferTableView.isScrollEnabled = false
            }
            
            printLog(logs: ["Did scroll on transfer tableview"], title: "Test")
        }*/
    }
}

extension HomeworkViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText.onNext(searchBar.text)
    }
}

extension HomeworkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        
        if tableView === inviteTableView {
            rows = 10
        } else if tableView === transferTableView {
            rows = 20
        }
        
        return rows
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView === inviteTableView {
            let cell: InviteCell = tableView.dequeueReusableCell(for: indexPath)
            cell.nameLabel.text = "invite \(indexPath)"
            
            return cell
            
        } else if tableView === transferTableView {
            let cell: TransferCell = tableView.dequeueReusableCell(for: indexPath)
            cell.nameLabel.text = "transfer \(indexPath)"
            return cell
        }
        
        return UITableViewCell()
    }
}


extension HomeworkViewController: HomeworkViewModelDelegate {
    func binding(to input: HomeworkViewModel.Input) {
        input.friendsCounts.binding { (count) in
           self.friendsCountLabel.text = "好友列表 \(count)"
        }
        
    }
}
