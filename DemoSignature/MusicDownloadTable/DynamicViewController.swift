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
    
    var whichClose: [Bool] = []
    
    var cacheHeaderViews: [UIView] = []
    
    let musicRequest = RequestCommunicator<DownloadMusic>()
    var searchMusics: [[MusicHandler]] = []
    
    let uploadHelper = StreamsHandler()
    
    private let musicsPath: String = "musics"
    private var saveMusicsKey = "SaveSearchedMusic"
    private var searchedMusics: [String : [MusicHandler]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        searchBar.delegate = self
        uploadHelper.delegate = self
        
        // prepare userDefaults data
        if let recordSearched = UserDefaults.standard.object(forKey: saveMusicsKey) as? [String : [[String : Any]]] {
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
                
                searchedMusics[key] = eachMusics
                
                searchMusics.append(eachMusics)
//                searchMusics.append(value.map { MusicHandler.convertToModel(dic: $0)!})
                
                whichClose.append(true)
                sectionTitle.append(key)
                sectionCount += 1
            }
            tableView.reloadData()
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    func saveSearchedMusic() {
        var dataDic: [String : [[String : Any]]] = [:]
        searchedMusics.forEach { key, value in
            dataDic[key] = value.map { $0.convertToDic() ?? [:] }
            
        }
        UserDefaults.standard.set(dataDic, forKey: saveMusicsKey)
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
            tableView.insertRows(at: rowsIndexPath, with: .fade)
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
            if component == musicsPath {
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
            if component == musicsPath {
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
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        musicRequest.request(type: .searchMusic(media: "music", entity: "song", term: searchBar.text!)) { (result) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch result {
            case .success(let value):
                if let musics = MusicHandler.updateSearchResults(value.data, section: self.searchMusics.count).self {
                    
                    // FIXME: - save with text and musics.
                    // ....
                    self.whichClose.append(true)
                    self.sectionTitle.append(text)
                    self.searchMusics.append(musics)
                    
                    self.searchedMusics[text] = musics
                    self.saveSearchedMusic()
                    
                    DispatchQueue.main.async {
                        self.searchBar.text = ""
                         self.tableView.reloadData()
                    }
                   
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
//        return searchedMusics.count
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
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.borderWidth = 1.5
        let musicHandler = searchMusics[indexPath.section][indexPath.row]
        let download = musicRequest.activeDownloads[musicHandler.url]
        
        cell.configureCell(music: musicHandler, downloaded: musicHandler.downloaded, download: download)
   
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let music = searchMusics[indexPath.section][indexPath.row]
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
        let download = musicRequest.activeDownloads[sourceURL]
        musicRequest.activeDownloads[sourceURL] = nil
        
        var artistFolder: String = ""
        if let model = download?.model as? MusicHandler {
            artistFolder = model.artist.replacingOccurrences(of: " ", with: "_")
        }
        let destinationURL = CustomFileManager.appendingPath(file: sourceURL, needDirectories: "\(musicsPath)/\(artistFolder)")
        
        printLog(logs: [destinationURL.absoluteString], title: "DestinationURL")
        
        CustomFileManager.saveFiles(fromUrl: location, to: destinationURL) { (destination, ok, error) in
            if let _ = error { return }
            
            guard let indexPath = download?.model.indexPath else { return }
            
            // update to searchMusics
            searchMusics[indexPath.section][indexPath.row].downloaded = true
            searchMusics[indexPath.section][indexPath.row].url = destinationURL
            
            // key: sectionTitle[indexPath.section] -> (search_text), indexPath.row -> (which music state changed).
            searchedMusics[sectionTitle[indexPath.section]]?[indexPath.row].downloaded = true
            searchedMusics[sectionTitle[indexPath.section]]?[indexPath.row].url = destinationURL
            saveSearchedMusic()
            
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .none)
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
        
        case .upload:
            uploadHelper.upload(with: music)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}

extension DynamicViewController: StreamHandlerDelegate {
    
    func needHeaders(on model: DownloadModelProtocol) -> [String : String] {
        let music = searchMusics[model.indexPath.section][model.indexPath.row]
        
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
