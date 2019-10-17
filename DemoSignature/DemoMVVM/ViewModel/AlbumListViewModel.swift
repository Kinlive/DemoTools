//
//  AlbumListViewModel.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/16.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

protocol AlbumListViewModelDelegate: class {
    func binding() -> AlbumListViewModel.Input
}


// MARK: - View model
class AlbumListViewModel {
    
    // define input & output
    struct Input {
        let musicSearchEnd: Observable<Void>
        let searchFail: Observable<NetworkError>
        let searchText: Observable<String>
    }
    
    struct Output {
        var albumListCellViewModels: [AlbumListCellViewModel] = []
    }

    // Request
    private var musicService: RequestCommunicator<DownloadMusic>

    // bind variables
    private let input: Input?
    var output: Output = Output()
    
    // Others properties
    private let imageOperation = OperationQueue()
    
    // MARK: - initialize
    init(delegate: AlbumListViewModelDelegate, service: RequestCommunicator<DownloadMusic> = RequestCommunicator<DownloadMusic>()) {
        
        self.musicService = service
        self.input = delegate.binding()
        
        // wait for fix
        listenChanged()
    }
    
    // MARK: - Private methods.
    private func listenChanged() {
        // on search button tapped
        input?.searchText.binding(valueChanged: { [weak self] (newText) in
            self?.searchRequest(text: newText ?? "")
        })
        
    }
    
    private func searchRequest(text: String) {
        musicService.request(type: .searchMusic(media: "music", entity: "song", term: text)) { [weak self] (result) in
            switch result {
            case .success(let response):
                self?.convertToMusicHandler(from: response)
                
            case .failure(let error):
                self?.input?.searchFail.onNext(error)
            }
        }
    }
    
    private func convertToMusicHandler(from response: CommunicatorResponse) {
        
        if let musics = MusicHandler.updateSearchResults(response.data, section: 0).self {
            convertMusicsToCellViewModel(music: musics)
        }
    }
    
    private func convertMusicsToCellViewModel(music handlers: [MusicHandler]) {
        for handler in handlers {
            
            let image = Observable<UIImage>(UIImage(named: "placeholder"))
            let description = Observable<String>(handler.artist + "- " + handler.name)
            
            imageOperation.addOperation { [weak self] in
                self?.downloadImage(urlStr: handler.imageUrl, completion: { (photo) in
                    image.onNext(photo)
                })
            }
            
            let cellViewModel = AlbumListCellViewModel(image: image, description: description, musicHandler: handler)
            output.albumListCellViewModels.append(cellViewModel)
            
        }
        
        input?.musicSearchEnd.onNext()
    }
    
    // MARK: - download image
    private func downloadImage(urlStr: String, completion: @escaping ((UIImage?) -> Void)) {
        guard let url = URL(string: urlStr) else { completion(nil); return }
        do {
            
            let data = try Data(contentsOf: url)
            if let image = UIImage(data: data) {
                completion(image)
                return
            }
            completion(nil)
            
        } catch let error {
            self.input?.searchFail.onNext(NetworkError(message: error.localizedDescription, response: nil))
            completion(nil)
            
        }
        
    }

}
