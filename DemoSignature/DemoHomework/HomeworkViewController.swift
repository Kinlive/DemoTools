//
//  HomeworkViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/25.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

private let footerViewHeight: CGFloat = 100

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
    
    private var inviteFooterView: UIView!
    
    private var isCollapseInvites: Bool = true
    private var previousYoffset: CGFloat = 0
    // for searchBaseView move to scrollView frame layout guide use
    private var searchBarMinY: CGFloat = 0
    
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
        handleScrollViewContents(with: 1)
        // on first entry give correct frame
        searchBarMinY = inviteTableView.frame.maxY
        
    }
    
    private func initViews() {
        /* 在scrollView上放入tableView時需要先將其scroll enable關閉 */
        inviteTableView.isScrollEnabled = false
        transferTableView.isScrollEnabled = false
        listScrollView.delegate = self
        listScrollView.bounces = false
        //inviteTableView.bounces = true
//        transferTableView.bounces = false
        
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
    
    
    func handleScrollViewContents(with inviteCellsCount: CGFloat = 10) {
        
        // handel invite table
        let cellHeight: CGFloat = 60

        // inviteTableView的高度，隨著model的counts
        let adjustHeight = cellHeight * inviteCellsCount + footerViewHeight
        // 手動更新其高度
        inviteHeightConstraint.constant = adjustHeight
    
        /* case 1
         因此例子用途為滾動到searchBar時要能置頂於上方，且能讓transferTableView繼續滾動，
         因此先取得 transferTableView扣除 search欄位高度後於畫面全部呈現的高度，以作為scrollView contentSize.height參考。
        let transfersHeight = listScrollView.frame.height - searchBaseView.frame.height
        */
        
        /* case 2
        若是毋須將search置頂，則同inviteTableView計算model數量的高度直接賦予給
         scrollView.contentSize.height即可。
         */
        let transfersHeight = cellHeight * 20
        
        // It's suggest that do not setup contentSize in the viewDidLoad override function.
        listScrollView.contentSize = CGSize(
        width: listScrollView.frame.width,
        height: adjustHeight + transfersHeight + searchBaseView.frame.height)
        
        // 給予高度時若stackView一定要有spacing時也要將其算入，以及scrollView底下subviews的top/bottom constant.
        /*
         因baseView的constraints top&bottom約束在scrollView的 top&bottom，所以其高度跟隨scrollView.contentSize.height。
         另外需要注意的是 baseView 的bottom constraint在 storyboard上是對齊scrollView.Content Layout guide的bottom。
         */
        baseViewHeightConstraint.constant = listScrollView.contentSize.height
        
    }
    
    
    private func setupFooterView() -> UIView {
        if inviteFooterView == nil {
            inviteFooterView = UIView(frame: .zero)
            let btn = UIButton(frame: .zero)
            inviteFooterView.addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.centerYAnchor.constraint(equalToSystemSpacingBelow: inviteFooterView.centerYAnchor, multiplier: 1).isActive = true
            btn.centerXAnchor.constraint(equalTo: inviteFooterView.centerXAnchor).isActive = true
            btn.widthAnchor.constraint(equalToConstant: 200).isActive = true
            btn.heightAnchor.constraint(equalToConstant: footerViewHeight).isActive = true
            btn.backgroundColor = .red
            btn.setTitle("點即展開/收起", for: .normal)
            btn.addTarget(self, action: #selector(whenCollapseButtonTapped), for: .touchUpInside)
            btn.layer.cornerRadius = footerViewHeight * 0.5
            btn.layer.masksToBounds = true
            btn.layer.borderWidth = 2
            btn.layer.borderColor = UIColor.white.cgColor
            btn.layer.shadowRadius = 3
            btn.layer.shadowColor = UIColor.red.cgColor
            btn.layer.shadowOffset = .init(width: 1, height: 1)
        }
        
        return inviteFooterView
    }
    
    @objc
    private func whenCollapseButtonTapped() {
        isCollapseInvites = !isCollapseInvites
        
        var indexPaths: [IndexPath] = []
        for i in 1 ..< 10 {
            indexPaths.append(IndexPath(item: i, section: 0))
        }
        
        // adjust scrollViews contentSize and baseViews height
        handleScrollViewContents(with: isCollapseInvites ? 1 : 10)
        
        inviteTableView.beginUpdates()
        if isCollapseInvites {
            inviteTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            inviteTableView.insertRows(at: indexPaths, with: .fade)
        }
        inviteTableView.endUpdates()
        
        // others parameters handle
        // because tableView insert/delete by some time that here delay setting for get correct tableView's frame.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.searchBarMinY = self.inviteTableView.frame.maxY
        }
        
    }
    
    private func baseSearchView(lockTop: Bool) {
              
        let frameLayout = listScrollView.frameLayoutGuide
        
        if lockTop {
            baseStackView.removeArrangedSubview(searchBaseView)
            searchBaseView.removeFromSuperview()
            listScrollView.addSubview(searchBaseView)
            searchBaseView.translatesAutoresizingMaskIntoConstraints = false
            searchBaseView.topAnchor.constraint(equalTo: frameLayout.topAnchor).isActive = true
            searchBaseView.centerXAnchor.constraint(equalTo: frameLayout.centerXAnchor).isActive = true
            searchBaseView.widthAnchor.constraint(equalTo: frameLayout.widthAnchor).isActive = true
            searchBaseView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            searchBaseView.backgroundColor = UIColor.orange
            
        } else {
            searchBaseView.removeFromSuperview()
            searchBaseView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            baseStackView.insertArrangedSubview(searchBaseView, at: 1)
            searchBaseView.backgroundColor = .white
        }
    }
    
}

extension HomeworkViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let yOffset = scrollView.contentOffset.y
        //let searchBaseViewMinY = searchBaseView.frame.origin.y
        
        /*if scrollView === self.listScrollView {
            // 當base的scrollView位移高度超過搜尋的上緣時，切換scroll權給下方的tableView使其可滾動。
            // 特別注意的點， 若是僅設置 > searchBaseViewMinY，有可能下方判斷回滾的永遠無法觸發 <= 0而造成無法切換滾動權給 base scrollView
            if yOffset >= searchBaseViewMinY {
                transferTableView.isScrollEnabled = true
                listScrollView.isScrollEnabled = false
                
            }
        }
        
        if scrollView === self.transferTableView {
            // 當下方的tableView 做回滾動至位移為0時即，即是滾至上緣起點，若要繼續往上滾動則將滾動權設為base的scrollView
            if yOffset <= 0 {
                self.listScrollView.isScrollEnabled = true
                transferTableView.isScrollEnabled = false
            
            }
        }*/
        
        /* case 2 以此作法 滾動時將searchBar移至上方，體驗較為順暢 */
        let yDiff = yOffset - previousYoffset
        let isScrollingUp = yDiff < 0
        let isScrollingDown = yDiff > 0
    
        if isScrollingDown, yOffset >= searchBarMinY {
            baseSearchView(lockTop: true)
            
        } else if isScrollingUp, yOffset < searchBarMinY - 2 {
            baseSearchView(lockTop: false)
        }
        
        previousYoffset = yOffset
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
            rows = isCollapseInvites ? 1 : 10
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard tableView === inviteTableView else { return nil }
        
        return setupFooterView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard tableView === inviteTableView else { return 0 }
        return footerViewHeight
    }
}


extension HomeworkViewController: HomeworkViewModelDelegate {
    func binding(to input: HomeworkViewModel.Input) {
        input.friendsCounts.binding { (count) in
            self.friendsCountLabel.text = "好友列表 \(String(describing: count))"
        }
        
    }
}
