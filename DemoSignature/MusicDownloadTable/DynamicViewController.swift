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
    
    
    var cacheHeaderViews: [UIView] = []
   
    let uploadHelper = StreamsHandler()
    
    
    lazy var dynamicViewModel: DynamicViewModel = {
       return DynamicViewModel(bindingOn: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        searchBar.delegate = self
        uploadHelper.delegate = self
        
        // prepare userDefaults data
        if let recordSearched = UserDefaults.standard.object(forKey: dynamicViewModel.saveMusicsKey) as? [String : [[String : Any]]] {
            var sectionCount: Int = 0
            
            recordSearched.forEach { key, value in
                //
                var rowCount: Int = 0
                
                let eachMusics: [MusicHandler] = value.map { value in
                    
                    var music = MusicHandler.convertToModel(dic: value)!
                    music.index = rowCount
                    music.indexPath = IndexPath(item: rowCount, section: sectionCount)
                    
                    rowCount += 1
                    return music
                }
                
                dynamicViewModel.searchedMusics[key] = eachMusics
                
                dynamicViewModel.searchMusics.append(eachMusics)
//                searchMusics.append(value.map { MusicHandler.convertToModel(dic: $0)!})
                
                dynamicViewModel.whichClose.append(true)
                dynamicViewModel.sectionTitle.append(key)
                sectionCount += 1
            }
            tableView.reloadData()
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    func prepareHeaderView(on section: Int) -> UIView {
        
        if section <= cacheHeaderViews.count - 1 {
            return cacheHeaderViews[section]
        }
        
        let title = dynamicViewModel.titleWith(section: section)
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
        
        let details = dynamicViewModel.searchMusics[sender.tag]//searchMusics[sender.tag]
        var rowsIndexPath: [IndexPath] = []
        for i in 0 ..< details.count {
            rowsIndexPath.append(IndexPath(item: i, section: sender.tag))
        }
        
        if dynamicViewModel.whichClose[sender.tag] {
            dynamicViewModel.whichClose[sender.tag] = false
            tableView.insertRows(at: rowsIndexPath, with: .fade)
            sender.setTitle("收起", for: .normal)
//            tableView.scrollToRow(at: IndexPath(row: (details.count - 1), section: sender.tag), at: .bottom, animated: true)
        } else {
            dynamicViewModel.whichClose[sender.tag] = true
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
    
    func localFilePath(for fileUrl: URL) -> URL {
        return documentsPath.appendingPathComponent(fileUrl.lastPathComponent)
    }
    
    // play music
    func playDownload(_ track: MusicHandler) {
 
        let playerViewController = AVPlayerViewController()
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        playerViewController.exitsFullScreenWhenPlaybackEnds = true
        present(playerViewController, animated: true, completion: nil)
//        let url = localFilePath(for: track.url)

        var startAppend = false
        var docMusicPath = documentsPath
        
        for component in track.url.pathComponents {
            if component == dynamicViewModel.musicsPath {
                startAppend = true
            }
            
            if startAppend {
                docMusicPath.appendPathComponent(component)
            }
        }

        let player = AVPlayer(url: docMusicPath)
        playerViewController.player = player
        player.play()
    }
    
    func prepareUploadPath(_ track: MusicHandler) -> URL {
        var startAppend = false
        var docMusicPath = documentsPath
        
        for component in track.url.pathComponents {
            if component == dynamicViewModel.musicsPath {
                startAppend = true
            }
            
            if startAppend {
                docMusicPath.appendPathComponent(component)
            }
        }
        
        return docMusicPath
    }

}

extension DynamicViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        
        guard let text = searchBar.text, !text.isEmpty else { return }
        dynamicViewModel.onSearchSongsWith(name: text)
        
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
        return dynamicViewModel.numberOfSectionWithModels()
//        return searchedMusics.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dynamicViewModel.numberOfRowsWithModels(section: section)
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
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.borderWidth = 1.5
        let musicHandler = dynamicViewModel.musicHandler(at: indexPath)
        let download = dynamicViewModel.activeDownload(at: musicHandler.url)
        
        cell.configureCell(music: musicHandler, downloaded: musicHandler.downloaded, download: download)
   
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let music = dynamicViewModel.musicHandler(at: indexPath)
        if music.downloaded {
            let showString = "musicPath: \(music.url)"
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
        let download = dynamicViewModel.activeDownload(at: sourceURL)
        
        dynamicViewModel.setActiveDownload(value: nil, at: sourceURL)
        
        var artistFolder: String = ""
        if let model = download?.model as? MusicHandler {
            artistFolder = model.artist.replacingOccurrences(of: " ", with: "_")
        }
        let destinationURL = CustomFileManager.appendingPath(file: sourceURL, needDirectories: "\(dynamicViewModel.musicsPath)/\(artistFolder)")
        
        printLog(logs: [destinationURL.absoluteString], title: "DestinationURL")
        
        CustomFileManager.saveFiles(fromUrl: location, to: destinationURL) { [weak self] (destination, ok, error) in
            if let _ = error { return }
            
            guard let indexPath = download?.model.indexPath else { return }
            
            // update to searchMusics
            self?.dynamicViewModel.setSearchMusicsState(downloaded: true, destinationURL: destinationURL, at: indexPath)

        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let url = downloadTask.originalRequest?.url,
            let download = dynamicViewModel.activeDownload(at: url) else { return }
        
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
        let music = dynamicViewModel.musicHandler(at: indexPath)//searchMusics[indexPath.section][indexPath.row]
    
        // musicRequest action for download/pause/resume....
        switch state {
        case .download:
            dynamicViewModel.musicRequest.request(type: .downloadMusic(handler: music, delegateTarget: self)) { (result) in
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
            dynamicViewModel.musicRequest.cancelDownload(music)
        
        case .resume:
            dynamicViewModel.musicRequest.resumeDownload(music)
        
        case .pause:
            dynamicViewModel.musicRequest.pauseDownload(music)
        
        case .upload:
            uploadHelper.upload(with: music)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}

extension DynamicViewController: StreamHandlerDelegate {
    
    func needHeaders(on model: DownloadModelProtocol) -> [String : String] {
        let music = dynamicViewModel.musicHandler(at: model.indexPath)
        
        let dic: [String : String] = [
            "fileName" : music.name,
            "path" : music.artist
        ]
        
        return dic
    }
    
    func sending(currentSize: Double, percent: Double, to destination: URL, with model: DownloadModelProtocol?) {
        
        guard let model = model, let cell = tableView.cellForRow(at: model.indexPath) as? DetailCell else { return }
        
        var unit: String = ""
        var dividedSize: Double = 0
        
        if Double(currentSize) / Double(1e9) >= 1.0 {
            dividedSize = currentSize / Double(1e9)
            unit = "Gbyte"
        } else if Double(currentSize) / Double(1e6) >= 1.0 {
            dividedSize = currentSize / Double(1e6)
            unit = "Mbyte"
        } else {
            dividedSize = currentSize / Double(1e3)
            unit = "Kbyte"
        }
        
        let sizePrint = String(format: "%.2f", dividedSize) + unit
        let percentStr = String(format: "%.2f", percent)
        
        
        DispatchQueue.main.async() {
//            print("Will update display: \(sizePrint), \(percentStr)%")
            cell.updateUploadDisplay(size: sizePrint, progress: percent, percent: percentStr, to: destination.absoluteString)
        }
    }
    
    
}

// MARK: - Binding actions
extension DynamicViewController: DynamicViewModelDelegate {
    func onReloadTableView(indexPath: IndexPath?) {
        
        DispatchQueue.main.async {
            if let indexPath = indexPath {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    func onSearchEnded(texts: String) {
        
    }
    
    func onTappedSectionOf(indexPath: IndexPath) {
        
    }
    
    func onSearching() {
        
    }
    
    func onSearchFail(error: NetworkError) {
        convienceAlert(alert: "Error", alertMessage: error.localizedDescription, actions: ["確認"], completion: nil, actionCompletion: nil)
        
        
    }
    
    

}
