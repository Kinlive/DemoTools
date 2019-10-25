//
//  PracticeMVVMViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/15.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class PracticeMVVMViewController: UIViewController {

    @IBOutlet weak var musicSearchBar: UISearchBar!
    @IBOutlet weak var albumListCollectionView: UICollectionView!
    
    lazy var viewModel: AlbumListViewModel = {
        return AlbumListViewModel(delegate: self)
    }()
    lazy var layout: CustomLayout_v2 = {
        let newLayout = CustomLayout_v2()
        newLayout.scrollDirection = .vertical
        return newLayout
    }()
    
    let searchText = Observable<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
    }
    
    func initViews() {
        albumListCollectionView.delegate = self
        albumListCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        albumListCollectionView.collectionViewLayout = layout
        
        albumListCollectionView.dataSource = self
        musicSearchBar.delegate = self
    }
    
}


// MARKL: - UICollectionView delegate
extension PracticeMVVMViewController: UICollectionViewDataSource, UICollectionViewDelegate {//}, UICollectionViewDelegateFlowLayout {
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.width - 2
        let height = collectionView.bounds.height * 0.3
        let size = CGSize(width: screenWidth, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }*/
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.albumListCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: AlbumListCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.backgroundColor = .darkGray
        let cellViewModel = viewModel.output.albumListCellViewModels[indexPath.row]
        cell.setup(viewModel: cellViewModel)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellViewModel = viewModel.output.albumListCellViewModels[indexPath.row]
        DispatchQueue.main.async {
            self.convienceAlert(
                       alert: "\(cellViewModel.musicHandler.name): \(cellViewModel.musicHandler.indexPath)",
                alertMessage: "\(String(describing: cellViewModel.descriptionText.value))",
                     actions: ["確認"],
                  completion: nil,
            actionCompletion: nil)
        }
        
    }
}


// MARK: - UISearchbar delegate
extension PracticeMVVMViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText.onNext(searchBar.text)
        searchBar.endEditing(true)
    }
}

// MARK: - AlbumListViewModel delegate
extension PracticeMVVMViewController: AlbumListViewModelDelegate {
    func binding() -> AlbumListViewModel.Input {
        
        // prepare bind observable
        let musicSearchEnd = Observable<Void>().binding { [weak self] _ in
            DispatchQueue.main.async {
                self?.albumListCollectionView.reloadData()
            }
        }
        
        let searchFail = Observable<NetworkError>().binding { [weak self] (error) in
            DispatchQueue.main.async {
                self?.convienceAlert(alert: "Search error", alertMessage: error?.localizedDescription, actions: ["確認"], completion: nil, actionCompletion: nil)
            }
        }
        
        return AlbumListViewModel.Input(musicSearchEnd: musicSearchEnd,
                                        searchFail: searchFail,
                                        searchText: searchText)
    }
}
