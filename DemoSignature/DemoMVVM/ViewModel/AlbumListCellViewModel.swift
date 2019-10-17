//
//  AlbumListCellViewModel.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/16.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation
import UIKit

class AlbumListCellViewModel {
    
    var albumImage: Observable<UIImage>
    var descriptionText: Observable<String>
    var musicHandler: MusicHandler
    
    init(image: Observable<UIImage>, description: Observable<String>, musicHandler: MusicHandler) {
        self.albumImage = image
        self.descriptionText = description
        self.musicHandler = musicHandler
    }
    
    func clearOnReuse() {
        albumImage.binding(valueChanged: nil)
        descriptionText.binding(valueChanged: nil)
    }
    
}
