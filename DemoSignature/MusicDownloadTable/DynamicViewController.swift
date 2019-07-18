//
//  DynamicViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/10.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class DynamicViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    var sectionTitle: [String] = []
    
    var whichClose = [true, true, true , true]
    
    var cacheHeaderViews: [UIView] = []
    
    let musicRequest = RequestCommunicator<DownloadMusic>()
    var searchMusics: [[MusicHandler]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        searchBar.delegate = self
        
        // Do any additional setup after loading the view.
    }

    func prepareHeaderView(on section: Int) -> UIView {
        
        if section <= cacheHeaderViews.count - 1 {
            return cacheHeaderViews[section]
        }
        
        let title = sectionTitle[section]
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        headerView.backgroundColor = UIColor(red: 135 / 255.0, green: 180 / 255.0, blue: 200 / 255.0, alpha: 1.0)
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width * 0.5, height: 40))
        titleLabel.text = title
        headerView.addSubview(titleLabel)
        
        let btn = UIButton(frame: CGRect(x: tableView.frame.width - 40, y: 0, width: 40, height: 40))
        btn.setTitle("展開", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.tag = section
        btn.addTarget(self, action: #selector(whenClickedOn(_:)), for: .touchUpInside)
        headerView.addSubview(btn)
        
        cacheHeaderViews.append(headerView)
        return headerView
        
    }
    
    @objc
    func whenClickedOn(_ sender: UIButton) {
        
        let details = searchMusics[sender.tag]
        var rowsIndexPath: [IndexPath] = []
        for i in 0 ..< details.count {
            rowsIndexPath.append(IndexPath(item: i, section: sender.tag))
        }
        
        if whichClose[sender.tag] {
            whichClose[sender.tag] = false
            tableView.reloadSections(IndexSet(arrayLiteral: sender.tag), with: .fade)
            sender.setTitle("收起", for: .normal)
//            tableView.scrollToRow(at: IndexPath(row: (details.count - 1), section: sender.tag), at: .bottom, animated: true)
        } else {
            whichClose[sender.tag] = true
            tableView.deleteRows(at: rowsIndexPath, with: .fade)
            sender.setTitle("展開", for: .normal)
        }
        
        DispatchQueue.main.async {
            self.tableView.layoutIfNeeded()
        }
    }
    
    @objc
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    // For FileManager use
    // Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    // play music
    func playDownload(_ track: MusicHandler) {
 
        let playerViewController = AVPlayerViewController()
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        playerViewController.exitsFullScreenWhenPlaybackEnds = true
        present(playerViewController, animated: true, completion: nil)
        let url = localFilePath(for: track.url)
        let player = AVPlayer(url: url)
        playerViewController.player = player
        player.play()
    }

}

extension DynamicViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        
        guard let text = searchBar.text, !text.isEmpty else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        musicRequest.request(type: .searchMusic(media: "music", entity: "song", term: searchBar.text!)) { (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch result {
            case .success(let value):
                if let musics = MusicHandler.updateSearchResults(value.data, section: self.searchMusics.count).self {
                    self.sectionTitle.append(text)
                    self.searchMusics.append(musics)
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                printLog(logs: [error.localizedDescription], title: "Response error")
            }
        }
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
}

extension DynamicViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchMusics.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return whichClose[section] ? 0 : searchMusics[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return prepareHeaderView(on: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell: DetailCell = tableView.dequeueReusableCell(for: indexPath)
        cell.delegate = self
        
        let musicHandler = searchMusics[indexPath.section][indexPath.row]
        let download = musicRequest.activeDownloads[musicHandler.url]
        
        cell.configureCell(music: musicHandler, downloaded: musicHandler.downloaded, download: download)
   
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let music = searchMusics[indexPath.section][indexPath.row]
        if music.downloaded {
            let showString = "musicPath: \(localFilePath(for: music.url))"
            printLog(logs: [showString], title: "Select music")
            playDownload(music)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - URLSessionDownload delegate =====================================
extension DynamicViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = musicRequest.activeDownloads[sourceURL]
        musicRequest.activeDownloads[sourceURL] = nil
        
        let destinationURL = localFilePath(for: sourceURL)
        printLog(logs: [destinationURL.absoluteString], title: "DestinationURL")
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            
            if let indexPath = download?.model.indexPath {
                // update to searchMusics
                searchMusics[indexPath.section][indexPath.row].downloaded = true
            }
        } catch let error {
            printLog(logs: [error.localizedDescription], title: "Download fail")
        }
        
        // refresh UI for download complete...
        if let indexPath = download?.model.indexPath {
            DispatchQueue.main.async {
                
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let url = downloadTask.originalRequest?.url,
            let download = musicRequest.activeDownloads[url] else { return }
        
        // progress
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        // size
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        
        download.totalSize = totalSize
        
        // refresh UI display when size change....
        let indexPath = download.model.indexPath
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: indexPath) as? DetailCell {
                cell.updateDisplay(progress: download.progress, totalSize: download.totalSize)
            }
        }
        
    }
}


extension DynamicViewController: DetailCellDelegate {
    
    func musicDownloadStateChange(_ cell: DetailCell, state: MusicDownloadState) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let music = searchMusics[indexPath.section][indexPath.row]
    
        // musicRequest action for download/pause/resume....
        switch state {
        case .download:
            musicRequest.request(type: .downloadMusic(handler: music, delegateTarget: self)) { (result) in
                DispatchQueue.main.async {
                    if case let .failure(error) = result {
                        printLog(logs: [error.localizedDescription], title: "Download music failure")
                        cell.numbeLabel.text = "\(error.localizedDescription)"
                        cell.numbeLabel.textColor = .red
                    } else {
                        cell.numbeLabel.textColor = .black
                    }
                }
            }
            
        case .cancel:
            musicRequest.cancelDownload(music)
        
        case .resume:
            musicRequest.resumeDownload(music)
        
        case .pause:
            musicRequest.pauseDownload(music)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}

