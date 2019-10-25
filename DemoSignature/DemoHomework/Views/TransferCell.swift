//
//  TransferCell.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/25.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class TransferCell: UITableViewCell {

    @IBOutlet weak var starImageView: UIImageView!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var transferButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var transferButton: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var moreButtonWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}
