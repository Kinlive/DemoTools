//
//  PageViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/10.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit
import ARKit

class TestCell: UITableViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    
    var sceneView: ARSCNView!
}

protocol PageCellDelegate: class {
    func onDirectScrollToBottom(_ moveScale: CGFloat, and text: String)
    func whenTextWillLeft()
    func onDirectScrollToTop(_ moveScale: CGFloat, and text: String)
}

class PageCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    var previousOffsetY: CGFloat = .zero
    
    var data: [String] = [] {
        didSet {
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    weak var delegate: PageCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    /** Summary here
     
    Discussion here:
     
    ```
    // block begin
    a = 1, b = 3.
    c = 4, d = 9.
    // block end
    ```
    Others message add.
    - Parameter datas: pass value
    - Parameter target: value 2
    - Throws: erroer
    - Returns: no returns.
    */
    func testMarkdown(_ datas: String, target: Any) throws {
        
    }
    
    /// Summary here
    ///
    /// Discussion here:
    ///
    ///     // block begin....
    ///     a = 1, b = 3,
    ///     c = 4, d = 9
    ///
    ///     // block end
    ///
    /// Others message here.
    /// - Parameter datas: pass values
    /// - Returns: Nothing.
    func configueSet(with datas: [String]) {
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        self.data = datas
        
    }
    
    // table view delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomSwitchCell", for: indexPath) as? CustomSwitchCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            return cell
        }
    
        guard let cell  = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as? TestCell else { return UITableViewCell() }
        cell.numberLabel.text = "Get \(data[indexPath.row - 1])"


        return cell
        
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
    
    // 測試滑動cell時, 當cell滑出畫面連動top baseview的另一個ui做位移
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.contentOffset.y > tableView.rowHeight else { return }
        
        let row = Int(scrollView.contentOffset.y / tableView.rowHeight)
        let indexPath = IndexPath(row: row, section: 0)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TestCell else { return }
        
        // need params: target, targetparent, scrollview, target's actual height,
        let cellHeight: CGFloat = cell.frame.height
        let targetAny: String = cell.numberLabel.text ?? ""
        let targetPosY: CGFloat = cell.numberLabel.center.y // the center point is from its parent cell.
        let halfHeightOfTarget: CGFloat = cell.numberLabel.font.lineHeight * 0.5
        
        let yRemainderOfTarget: CGFloat = scrollView.contentOffset.y.truncatingRemainder(dividingBy: cellHeight)
        
        // here is the target on center with its superview example.
        let yOfTargetsTop: CGFloat = targetPosY - halfHeightOfTarget
        let yOfTargetsBottom: CGFloat = targetPosY + halfHeightOfTarget
        
//        let yOfTargetsTop = cellHeight * 0.5 - cell.numberLabel.font.lineHeight * 0.5
//        let yOfTargetsBottom = cellHeight * 0.5 + cell.numberLabel.font.lineHeight * 0.5
        
        let limitHeight: CGFloat = yOfTargetsBottom - yOfTargetsTop
        let moving: CGFloat = yOfTargetsBottom - yRemainderOfTarget
        let scale: CGFloat = 1 - moving / limitHeight
        
        if previousOffsetY < scrollView.contentOffset.y { // scroll to bottom.
            delegate?.onDirectScrollToBottom((scale < 1) ? scale : 1, and: targetAny)
        
        } else {
            // scale < 1: target moving, scale >= 1: target leave from current display
            delegate?.onDirectScrollToTop(scale < 1 ? scale : 1, and: targetAny)
        
        }
        
        previousOffsetY = scrollView.contentOffset.y
    }
    
}


class PageViewController: UIViewController {

    @IBOutlet weak var page1Button: UIButton!
    @IBOutlet weak var page2Button: UIButton!
    @IBOutlet weak var moveLineView: UIView!
    
    @IBOutlet weak var topBaseView: UIView!
    @IBOutlet weak var pageCollectionView: UICollectionView!
    
    @IBOutlet weak var moveLabel: UILabel!
    
    
    var previousMoveRate: CGFloat = 0
    var datas = [
        ["1-1", "1-2", "1-3", "1-4", "1-5", "1-6", "1-7", "2-1", "2-2", "2-3", "2-4", "2-5"],
        [ "2-6", "2-7", "3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7", "4-1", "4-2", "4-3", "4-4", "4-5", "4-6", "4-7", "2-6", "2-7", "3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7", "4-1", "4-2", "4-3", "4-4", "4-5", "4-6", "4-7", "2-6", "2-7", "3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7", "4-1", "4-2", "4-3", "4-4", "4-5", "4-6", "4-7"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageCollectionView.delegate = self
        pageCollectionView.dataSource = self
        moveLabel.transform = CGAffineTransform(translationX: 0, y: topBaseView.frame.height * 0.5 + moveLabel.frame.height * 0.5)
        moveLabel.alpha = 0.0
        pageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func onPage1Tapped(_ sender: UIButton) {
        pageCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
   
    }
    @IBAction func onPage2Tapped(_ sender: UIButton) {
        pageCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .right, animated: true)

    }
    
    
}


extension PageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageCell", for: indexPath) as? PageCell else { return PageCell() }
        //        cell.titleLabel.text = "Page\(indexPath.row + 1)";
        cell.delegate = self
        let data = datas[indexPath.row]
        cell.configueSet(with: data)
        return cell
    }
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let moveRate = scrollView.contentOffset.x / pageCollectionView.frame.width
        
        
        var scaleRate: CGFloat = 0
        if moveRate > previousMoveRate { // -->> scroll to right
            if moveRate < 0.5 {
                scaleRate = 1 + moveRate
            } else {
                scaleRate = 1 + (1 - moveRate)
            }
            
        } else {
            if moveRate > 0.5 {
                scaleRate = 1 + (1 - moveRate)
            } else {
                scaleRate = 1 + moveRate
            }
        }
        
        
        
        print("Did scroll contentOffset: \(scrollView.contentOffset.x), moveRate: \(moveRate)")
        DispatchQueue.main.async {
            self.moveLineView.transform = CGAffineTransform(
                translationX: self.page2Button.frame.width * moveRate, y: 0)
                .scaledBy(x: scaleRate, y: 1)
        }
        
        
        previousMoveRate = moveRate
    }
    
}

extension PageViewController: PageCellDelegate {
    func onDirectScrollToTop(_ moveScale: CGFloat, and text: String) {
         moveLabel.text = text
        
        let moveDistance = (topBaseView.frame.height * 0.5 + moveLabel.frame.height) * ( 1 - moveScale)
        DispatchQueue.main.async {
            self.moveLabel.transform = CGAffineTransform(translationX: 0, y: moveDistance)
        }
    }
    
    func onDirectScrollToBottom(_ moveScale: CGFloat, and text: String) {
        let moveDistance = (topBaseView.frame.height * 0.5 + moveLabel.frame.height) * (1 - moveScale)
        
        let labelAlpha: CGFloat = moveScale < 0.3 ? 0.3 : moveScale
        
        moveLabel.text = text
        DispatchQueue.main.async {
            self.moveLabel.transform = CGAffineTransform(translationX: 0, y: moveDistance)
            self.moveLabel.alpha = labelAlpha
        }
    }
    
    func whenTextWillLeft() {
        
    }
}
