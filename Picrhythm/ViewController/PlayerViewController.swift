import UIKit
import AVKit
import Foundation
import MediaPlayer

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songInfo: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    
    
    // 音乐播放器 view
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var firstDownloadBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var toStartBtn: UIButton!
    @IBOutlet weak var rewindBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var randomChooseBtn: UIButton!
    
    // 加载提示
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var activityText: UILabel!
    
    @IBOutlet weak var songProcess: UIProgressView!
    
    // 隐藏播放组件
    func hideComponents() {
        songLabel.isHidden = true
        startBtn.isHidden = true
        pauseBtn.isHidden = true
        toStartBtn.isHidden = true
        rewindBtn.isHidden = true
        forwardBtn.isHidden = true
        randomChooseBtn.isHidden = true
        songProcess.isHidden = true
        
        activityView.isHidden = false
        activityView.startAnimating()
        activityText.isHidden = false
        activityText.text = "加载中......"
    }
    // 显示播放组件
    func showComponents() {
        songLabel.isHidden = false
        startBtn.isHidden = false
        pauseBtn.isHidden = true
        toStartBtn.isHidden = false
        rewindBtn.isHidden = false
        forwardBtn.isHidden = false
        randomChooseBtn.isHidden = false
        songProcess.isHidden = false
        
        activityView.stopAnimating()
        activityView.isHidden = true
        activityText.isHidden = true
    }
    
    // 文件路径
    // Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
      return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    // 网络服务
    let queryService = QueryService()        // 查询
    let downloadService = DownloadService()  // 下载
    var searchTerm: String = ""              // 搜索字符串
    var searchResults: [Track] = []          // 搜索结果
    var photo:Photo?
    
    // 音乐服务
    let playerService = PlayerService()
    
    // 设置代理
    lazy var downloadsSession: URLSession = {
      let configuration = URLSessionConfiguration.background(withIdentifier:
        "picrhythm")
      return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    
    // ++++++  TEST  ++++++
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // ++++++ 接口 ++++++
        setImage(uiImage: photo?.image) // 设置图片
        setLabel(label: photo?.tag ?? "empty label") // 设置标签
        
        songLabel.isHidden = true  // 下载完歌曲才显示标签
        clearSongInfo()            // 清除歌曲信息
        hideComponents()           // 隐藏播放组件
        firstDownloadBtn.isHidden = true
        
        // 根据标签搜索歌曲
        activityText.text = "搜索歌曲中..."
        if let labelText = songLabel.text {
            print("searching: \(labelText)")
            search(searchTerm: labelText)
        } else {
            setLabel(label: "未找到标签")
            search(searchTerm: "happy")
        }
        //search(searchTerm: "happy")
        
//        while self.searchResults.count == 0 {
//            // TODO: 搜索不到结果，换一个搜索词
//            search(searchTerm: "happy")
//        }
        
        if downloadService.downloadsSession != downloadsSession {
            downloadService.downloadsSession = downloadsSession
        }
    }
    
    
    // 下载第一首音乐
    @IBAction func download(_ sender: UIButton) {
        // 测试下载音乐 ++++++++++++++++++++++++++++++++++++++++
        activityText.text = "下载歌曲中..."
        firstDownloadBtn.isHidden = true
        // 下载 playerService 的当前下标音乐，即 0
        downloadService.startDownload(searchResults[playerService.currentIndex])
    }
    
    // 随机切换一首音乐
    @IBAction func changeMusic(_ sender: Any) {
        
        // 停止当前歌曲
        if playerService.isPlaying {
            playerService.pauseMusic()
            playerService.isPlaying = false
            startBtn.isHidden = false
            pauseBtn.isHidden = true
            playerService.rewindMusic(by: Float64.infinity)
        }
        // 产生新下标
        var newIndex = Int.randomInt(lower:0, upper:15)
        while playerService.currentIndex == newIndex {
            newIndex = Int.randomInt(lower:0, upper:15)
        }
        playerService.currentIndex = newIndex
        
        // 如果该下标的歌曲已经下载完成
        if searchResults[newIndex].downloaded {
            
            // ++++++ 重要：为 playerService 设置当前路径 ++++++
            playerService.setCurrentMusicFilePath(currentMusicFilePath: searchResults[newIndex].destinationURL!)
            // 初始化音乐播放器
            playerService.initPlayer(videoView: videoView, progressView: songProcess)
            // 显示播放组件
            // showComponents()
            // 设置音乐信息
            setSongInfo(name: searchResults[newIndex].name, artist: searchResults[newIndex].artist)
            
        } else {
            
            clearSongInfo()  // 清除歌曲信息
            hideComponents() // 隐藏播放组件
            activityText.text = "下载歌曲中..."
            downloadService.startDownload(searchResults[playerService.currentIndex])
        }
    }
    
    
    // 开始/暂停音乐
    @IBAction func startBtnTouched(_ sender: UIButton) {
        if playerService.isPlaying {
            playerService.pauseMusic()
            playerService.isPlaying = false
            startBtn.isHidden = false
            pauseBtn.isHidden = true
        } else {
            playerService.playMusic()
            playerService.isPlaying = true
            startBtn.isHidden = true
            pauseBtn.isHidden = false
        }
    }
    
    // 快退 5 秒
    @IBAction func rewindBtnTouched(_ sender: UIButton) {
        playerService.rewindMusic(by: 5)
    }
    
    // 快进 5 秒
    @IBAction func forwardBtnTouched(_ sender: UIButton) {
        playerService.forwardMusic(by: 5)
    }
    
    
    // 回到开头
    @IBAction func toStartBtnTouched(_ sender: UIButton) {
        playerService.rewindMusic(by: Float64.infinity)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem){
        let isPresentingInPlayer = presentingViewController is UINavigationController
        
        if isPresentingInPlayer {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The PlayerViewController is not inside a navigation controller.")
        }
        
        // 停止音乐，清理资源
        playerService.pauseMusic()
        searchResults = []
    }
    
    // 搜索并设置搜索结果
    func search(searchTerm: String = "happy") {
        self.searchTerm = searchTerm
        
        //let semaphore = DispatchSemaphore(value: 0)
        queryService.getSearchResults(searchTerm: searchTerm) { [weak self]
            results, errorMessage in
            if let results = results {
                self?.searchResults = results
                self?.finishSearching()
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
            //semaphore.signal()
        }
        //semaphore.wait()
    }
    // 搜索完成之后
    func finishSearching() {
        
        activityText.text = "搜索完成,共\(searchResults.count)个结果"
        firstDownloadBtn.isHidden = false
    }
    
    // 根据路径设置图片(png)
    func setImage(filepath: String?) {
        if filepath == nil {
            return
        }
        let filePath = Bundle.main.path(forResource: filepath, ofType: "png")
        let imageToSet = UIImage(contentsOfFile: filePath!)
        image.image = imageToSet
    }
    
    // 根据UIImage设置图片
    func setImage(uiImage: UIImage?) {
        if uiImage == nil {
            return
        }
        image.image = uiImage
    }
    
    // 设置歌曲信息
    func setSongInfo(name: String, artist: String) {
        songName.text = name
        songInfo.text = "作者:  \(artist)"
    }
    
    // 设置标签
    func setLabel(label: String) {
        songLabel.text = label
    }
    
    // 清除歌曲显示信息
    func clearSongInfo() {
        songName.text = ""
        songInfo.text = ""
    }
    
    // 清除标签
    func clearLabel() {
        songLabel.text = ""
    }
    
    /// ++++++  内部方法  ++++++
    
    // 根据 url 返回 track
    private func getTrackBySourceURL(musicURL: URL) -> Track? {
        for oneTrack in searchResults {
            if oneTrack.previewURL == musicURL {
                return oneTrack
            }
        }
        return nil
    }
    // 根据 sourceURL 找到 track 并设置 destinationURL
    private func setDestinationURLByPreviewURL(previewURL: URL, destiURL: URL) -> Bool {
        for oneTrack in searchResults {
            if oneTrack.previewURL == previewURL {
                oneTrack.destinationURL = destiURL
                return true
            }
        }
        return false
    }
    // 根据 index 找到 track 并设置 destinationURL
    private func setDestinationURLByIndex(index: Int, destiURL: URL) -> Bool {
        for oneTrack in searchResults {
            if oneTrack.index == index {
                oneTrack.destinationURL = destiURL
                return true
            }
        }
        return false
    }
}

// 下载完成之后的收尾工作
extension PlayerViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        // 获取url(track里的)
        guard let sourceURL = downloadTask.originalRequest?.url else {
          return
        }
        
        // 下载完成，取消对 download 的引用，回收
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        
        let destinationURL = localFilePath(for: sourceURL)
        print("destinationURL:  ")
        print(destinationURL)
        
        // 将临时文件拷贝到永久储存文件
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            // 设置该 track 的 downloaded
            download?.track.downloaded = true
            download?.track.destinationURL = destinationURL
            
            // ++++++ 重要：为 playerService 设置当前路径 ++++++
            playerService.setCurrentMusicFilePath(currentMusicFilePath: destinationURL)
            // 初始化音乐播放器
            playerService.initPlayer(videoView: videoView, progressView: songProcess)
            // 显示播放组件
            showComponents()
            // 设置音乐信息
            if let temp: Track = getTrackBySourceURL(musicURL: sourceURL) {
                setSongInfo(name: temp.name, artist: temp.artist)
                // 设置该 track 的 destinationURL
                //if !setDestinationURLByPreviewURL(previewURL: sourceURL, destiURL: destinationURL) {
                    //print("Fatal Error: 原始 track 找不到")
                //}
            } else {
                setSongInfo(name: "未找到音乐信息", artist: "music info not found")
            }
            
        } catch let error {
          print("File copy error: \(error)")
        }
    }
}

// 获取随机数
public extension Int {
    static func randomInt(lower: Int = 0, upper: Int = Int(UInt32.max)) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
}
