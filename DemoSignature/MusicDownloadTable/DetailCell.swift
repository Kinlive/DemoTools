//
//  DetailCell.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/18.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

// MARK: - DetailCell define ===================================================
protocol DetailCellDelegate: class {
    
    func musicDownloadStateChange(_ cell: DetailCell, state: MusicDownloadState)
}

enum MusicDownloadState {
    case download
    case pause
    case resume
    case cancel
}

class DetailCell: UITableViewCell {
    
    @IBOutlet weak var numbeLabel: UILabel!
    @IBOutlet weak var artisLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: DetailCellDelegate?
    
    @IBAction func download(_ sender: UIButton) {
        delegate?.musicDownloadStateChange(self, state: .download)
    }
    
    @IBAction func pause(_ sender: UIButton) {
        
        if pauseButton.titleLabel?.text == "Pause" {
            delegate?.musicDownloadStateChange(self, state: .pause)
        } else {
            delegate?.musicDownloadStateChange(self, state: .resume)
        }
        
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        delegate?.musicDownloadStateChange(self, state: .cancel)
    }
    
    func configureCell(music: MusicHandler, downloaded: Bool, download: Download<DownloadModelProtocol>?) {
        numbeLabel.text = music.name
        artisLabel.text = music.artist
        
        var showDownloadControls = false
        
        if let download = download {
            showDownloadControls = true
            let title = download.isDownloading ? "Pause" : "Resume"
            pauseButton.setTitle(title, for: .normal)
            
            progressLabel.text = download.isDownloading ? "Downloading..." : "Paused"
        }
        
        pauseButton.isHidden = !showDownloadControls
        cancelButton.isHidden = !showDownloadControls
        progressView.isHidden = !showDownloadControls
        progressLabel.isHidden = !showDownloadControls
        
        selectionStyle = downloaded ? .gray : .none
        
        //        downloadButton.isHidden = downloaded || showDownloadControls
        let downloadColor: UIColor = downloaded ? .green : .blue
        let downloadTitle: String = downloaded ? "Downloaded" : "Download"
        downloadButton.setTitleColor(downloadColor, for: .normal)
        downloadButton.setTitle(downloadTitle, for: .normal)
        downloadButton.isEnabled = !downloaded
        
    }
    
    func updateDisplay(progress: Float, totalSize: String) {
        progressView.progress = progress
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
    
}


