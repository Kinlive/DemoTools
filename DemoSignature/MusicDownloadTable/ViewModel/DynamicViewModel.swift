//
//  DynamicViewModel.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/15.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation
import UIKit


protocol DynamicViewModelDelegate: class {
    func onReloadTableView(indexPath: IndexPath?)
    func onSearchEnded(texts: String)
    func onTappedSectionOf(indexPath: IndexPath)
    func onSearching()
    func onSearchFail(error: NetworkError)
}

class DynamicViewModel {
    
    // const variables
    let musicsPath: String = "musics"
    let saveMusicsKey = "SaveSearchedMusic"
    
    
    weak var delegate: DynamicViewModelDelegate?
    // ""transfer to delegate functions.
    // define will bind actions.
    /*var onReloadTableView: (() -> Void)?
    var onSearchEnded: ((String) -> Void)?
    var onTappedSection: ((IndexPath) -> Void)?
    var onSearching: (() -> Void)?
    */
    
    // music data use
    var searchMusics: [[MusicHandler]] = []
    let uploadHelper = StreamsHandler()
    
    
    // MARK: - Normal properties
    var isSeaching: Bool = false {
        didSet {
            delegate?.onSearching()
        }
    }
    
    // models
    var sectionTitle: [String] = [] {
        didSet {
            
        }
    }
    
    var whichClose: [Bool] = []
    var searchedMusics: [String : [MusicHandler]] = [:]
    
    var detailCellViewModels: [DetailCellViewModel] = []
    
    // service
    let musicRequest: RequestCommunicator<DownloadMusic>
    
    // init methods
    init(bindingOn delegate: DynamicViewModelDelegate, service: RequestCommunicator<DownloadMusic> = RequestCommunicator<DownloadMusic>()) {
        self.delegate = delegate
        self.musicRequest = service
        
    }
    
    // MARK: - Public methods.
    func onSearchSongsWith(name: String) {
        isSeaching = true
        musicRequest.request(type: .searchMusic(media: "music", entity: "song", term: name)) { [weak self] (result) in
            
            self?.isSeaching = false
            switch result {
            case .success(let response):
                self?.convertToMusicHandler(from: response, searchTitle: name)
                
            case .failure(let error):
                self?.delegate?.onSearchFail(error: error)
            }
        }
    }
    
    func numberOfRowsWithModels(section: Int) -> Int {
        return whichClose[section] ? 0 : searchMusics[section].count
    }
    
    func numberOfSectionWithModels() -> Int {
        return searchMusics.count
    }
    
    func titleWith(section: Int) -> String {
        return sectionTitle[section]
    }
    
    func musicHandler(at indexPath: IndexPath) -> MusicHandler {
        return searchMusics[indexPath.section][indexPath.row]
    }
    
    func setSearchMusicsState(downloaded: Bool, destinationURL: URL, at indexPath: IndexPath) {
        searchMusics[indexPath.section][indexPath.row].url = destinationURL
        
        searchedMusics[sectionTitle[indexPath.section]]?[indexPath.row].downloaded = true
    
        searchedMusics[sectionTitle[indexPath.section]]?[indexPath.row].url = destinationURL
        
        saveSearchedMusic()
        delegate?.onReloadTableView(indexPath: indexPath)
    }
  
    func activeDownload(at url: URL) -> Download<DownloadModelProtocol>? {
        return musicRequest.activeDownloads[url]
    }
    
    func setActiveDownload(value: Download<DownloadModelProtocol>?, at url: URL) {
        musicRequest.activeDownloads[url] = value
    }
    
    private func saveSearchedMusic() {
        var dataDic: [String : [[String : Any]]] = [:]
        searchedMusics.forEach { key, value in
            dataDic[key] = value.map { $0.convertToDic() ?? [:] }
            
        }
        UserDefaults.standard.set(dataDic, forKey: saveMusicsKey)
    }
    
}


extension DynamicViewModel {
    func convertToMusicHandler(from response: CommunicatorResponse, searchTitle: String) {
        
        if let musics = MusicHandler.updateSearchResults(response.data, section: self.searchMusics.count).self {
            
            // FIXME: - save with text and musics.
            // ....
            self.whichClose.append(true)
            self.sectionTitle.append(searchTitle)
            self.searchMusics.append(musics)
            
            self.searchedMusics[searchTitle] = musics
            self.saveSearchedMusic()
            
            delegate?.onSearchEnded(texts: searchTitle)
            delegate?.onReloadTableView(indexPath: nil)
           
        }
        
    }
}
