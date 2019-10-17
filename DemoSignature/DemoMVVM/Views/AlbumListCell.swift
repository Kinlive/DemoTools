//
//  AlbumListCell.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/16.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class AlbumListCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var myViewModel: AlbumListCellViewModel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        myViewModel?.clearOnReuse()
        
    }
    
    func setup(viewModel: AlbumListCellViewModel) {
        //myViewModel?.clearOnReuse()
        
        myViewModel = viewModel
        imageView.image = myViewModel?.albumImage.value
        
        descriptionLabel.text = myViewModel?.descriptionText.value
        
        myViewModel?.albumImage.binding { [weak self] (newImage) in
            DispatchQueue.main.async {
                self?.imageView.image = newImage
            }
        }
        
    }
    
}
