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
    case upload
}

class DetailCell: UITableViewCell {
    
    @IBOutlet weak var numbeLabel: UILabel!
    @IBOutlet weak var artisLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // upload
    @IBOutlet weak var uploadProgressView: UIProgressView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    
    
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
    
    // upload action
    @IBAction func upload(_ sender: UIButton) {
        delegate?.musicDownloadStateChange(self, state: .upload)
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
        
        // setup upload UIs
        uploadLabel.isHidden = downloadTitle != "Downloaded"
        uploadButton.isHidden = downloadTitle != "Downloaded"
        uploadProgressView.isHidden = downloadTitle != "Downloaded"
        destinationLabel.isHidden = downloadTitle != "Downloaded"
        
    }
    
    func updateDisplay(progress: Float, totalSize: String) {
        progressView.progress = progress
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
    
    func updateUploadDisplay(size: String, progress: Double, percent: String, to destination: String) {
        uploadLabel.text = String(format: "%.1f%% of %@", progress, size)
        uploadProgressView.progress = Float(progress)
        destinationLabel.text = "->\(destination)"
        
        if progress == 100.0 {
            uploadButton.setTitle("Uploaded", for: .normal)
            uploadButton.setTitleColor(.red, for: .normal)
            uploadButton.isEnabled = false
        }
    }
    
}


