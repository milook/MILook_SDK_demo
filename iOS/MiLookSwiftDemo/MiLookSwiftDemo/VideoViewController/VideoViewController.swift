// VideoViewController.swift
//  MiLookSwiftDemo
//
//  Created by 侯 银博 on 2016/11/15.
//  Copyright © 2016 Shanghai Yingsui Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import Photos
import Toast_Swift

open class VideoViewController: UIViewController {
    
    // MARK: - Vars

    fileprivate var videoURL: URL!

    fileprivate var asset: AVURLAsset!
    fileprivate var playerItem: AVPlayerItem!
    fileprivate var player: AVPlayer!
    fileprivate var playerLayer: AVPlayerLayer!
    fileprivate var assetGenerator: AVAssetImageGenerator!
    
    fileprivate var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    fileprivate var previousLocationX: CGFloat = 0.0
    
    fileprivate let rewindDimView = UIVisualEffectView()
    fileprivate let rewindContentView = UIView()
    open let rewindTimelineView = TimelineView()
    fileprivate let rewindPreviewShadowLayer = CALayer()
    fileprivate let rewindPreviewImageView = UIImageView()
    fileprivate let rewindCurrentTimeLabel = UILabel()
    
    var imageView: UIImageView?
    
    var saveImg : UIButton!

    /// Indicates the maximum height of rewindPreviewImageView. Default value is 112.
    open var rewindPreviewMaxHeight: CGFloat = 112.0 {
        didSet {
            assetGenerator.maximumSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: rewindPreviewMaxHeight * UIScreen.main.scale)
        }
    }
    
    /// Indicates whether player should start playing on viewDidLoad. Default is true. 
    open var autoplays: Bool = true

    // MARK: - Constructors

    /**
        Returns an initialized VideoViewController object
    
        - Parameter videoURL: Local URL to the video asset 
    */
    public init(videoURL: URL) {
        super.init(nibName: nil, bundle: nil)
        
        self.videoURL = videoURL
        
        asset = AVURLAsset(url: videoURL)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)

        assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.maximumSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: rewindPreviewMaxHeight * UIScreen.main.scale)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -

    override open func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        playerLayer.videoGravity = AVLayerVideoGravityResize
        view.layer.addSublayer(playerLayer)
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(VideoViewController.longPressed(_:)))
        view.addGestureRecognizer(longPressGestureRecognizer)
        view.addSubview(rewindDimView)
        
        rewindContentView.alpha = 0.0
        view.addSubview(rewindContentView)
        
        
        rewindTimelineView.duration = CMTimeGetSeconds(asset.duration)
        rewindTimelineView.currentTimeDidChange = { [weak self] (currentTime) in
            guard let strongSelf = self, let playerItem = strongSelf.playerItem, let assetGenerator = strongSelf.assetGenerator else { return }
            
            let minutesInt = Int(currentTime / 60.0)
            let secondsInt = Int(currentTime) - minutesInt * 60
            strongSelf.rewindCurrentTimeLabel.text = (minutesInt > 9 ? "" : "0") + "\(minutesInt)" + ":" + (secondsInt > 9 ? "" : "0") + "\(secondsInt)"
            
            let requestedTime = CMTime(seconds: currentTime, preferredTimescale: playerItem.currentTime().timescale)
            
            assetGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: requestedTime)]) { [weak self] (_, CGImage, _, _, _) in
                guard let strongSelf = self, let CGImage = CGImage else { return }
                let image = UIImage(cgImage: CGImage, scale: UIScreen.main.scale, orientation: .up)

                DispatchQueue.main.async {
                    strongSelf.rewindPreviewImageView.image = image
                    
                    if strongSelf.rewindPreviewImageView.bounds.size != image.size {
                        strongSelf.viewWillLayoutSubviews()
                    }
                }
            }
        }
        rewindContentView.addSubview(rewindTimelineView)
        
        rewindCurrentTimeLabel.text = " "
        rewindCurrentTimeLabel.font = .systemFont(ofSize: 16.0)
        rewindCurrentTimeLabel.textColor = .white
        rewindCurrentTimeLabel.textAlignment = .center
        rewindCurrentTimeLabel.sizeToFit()
        rewindContentView.addSubview(rewindCurrentTimeLabel)
        
        rewindPreviewShadowLayer.shadowOpacity = 1.0
        rewindPreviewShadowLayer.shadowColor = UIColor(white: 0.1, alpha: 1.0).cgColor
        rewindPreviewShadowLayer.shadowRadius = 15.0
        rewindPreviewShadowLayer.shadowOffset = .zero
        rewindPreviewShadowLayer.masksToBounds = false
        rewindPreviewShadowLayer.actions = ["position": NSNull(), "bounds": NSNull(), "shadowPath": NSNull()]
        rewindContentView.layer.addSublayer(rewindPreviewShadowLayer)

        rewindPreviewImageView.contentMode = .scaleAspectFit
        rewindPreviewImageView.layer.mask = CAShapeLayer()
        rewindContentView.addSubview(rewindPreviewImageView)
        
        saveImg = UIButton(type: UIButtonType.custom)
        saveImg.frame = CGRect(x: 0,y: 0,width: 80,height: 80)
        saveImg.center.x = self.view.center.x
        saveImg.center = CGPoint(x:self.view.center.x, y:self.view.bounds.height-80)
        saveImg.setImage(UIImage(named: "post_btn_finish01.png"), for: .normal)
        saveImg.addTarget(self, action: #selector(saveAlbums), for: .touchDown)
        
        view.addSubview(saveImg)
    }
    
    func backhome() {
        player.pause()
        player = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    let savingQueue = DispatchQueue(label: "com.milook.Gallery.Camera.SavingQueue", qos: .background)
    
    func saveAlbums(){
        var style = ToastStyle()
        style.messageColor = UIColor.white
        style.backgroundColor = UIColor.clear
        style.imageSize.width = 20
        style.imageSize.height = 20
        self.view.makeToast("Saved to Album", duration: 2.0, position: CGPoint(x: self.view.center.x, y: self.view.center.y+120), title: nil, image: UIImage(named: "share_icon_saved.png"), style: style, completion: nil)
        savingQueue.async {
            self.saveTempVideoToPhotoLibrary(self.videoURL!)
        }
    }
    
    func saveTempVideoToPhotoLibrary(_ videoPath: URL) {
        let photosLibr = PHPhotoLibrary.shared()
        let status = PHPhotoLibrary.authorizationStatus()
        
        let saveVideo = { () -> Void in
            var changeRequest: PHAssetChangeRequest?
            var newIdentifier: String? = nil
            photosLibr.performChanges({ () -> Void in
                changeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoPath)
                if let placeholder = changeRequest?.placeholderForCreatedAsset {
                    newIdentifier = placeholder.localIdentifier
                }
            }, completionHandler: { (succes, error) -> Void in
                if succes {
                    if let anIdentif = newIdentifier {
                        let options = PHFetchOptions()
                        if #available(iOS 9.0, *) {
                            options.fetchLimit = 1
                        } else {
                            // Fallback on earlier versions
                        }
                        let result = PHAsset.fetchAssets(withLocalIdentifiers: [anIdentif], options: options)
                        if result.count == 1 {
                            let asset = result.object(at: 0)
                            self.getAssetUrl(asset, completionHandler: { (responseURL) -> Void in
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                            })
                        }
                    }
                }
            })
        }
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                switch status {
                case .denied: break
                case .authorized:
                    saveVideo()
                default: break
                }
            })
        case .authorized:
            saveVideo()
        default: break
        }
    }
    
    func getAssetUrl(_ mPhasset : PHAsset, completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if mPhasset.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            mPhasset.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable: Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL)
            })
        } else if mPhasset.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
                
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl : URL = urlAsset.url
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }

    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if autoplays {
            play()
        }
    }

    // MARK: - Methods
    
    /// Resumes playback
    open func play() {
        player.play()
    }
    
    /// Pauses playback
    open func pause() {
        player.pause()
    }
    
    open func longPressed(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: gesture.view!)
        rewindTimelineView.zoom = (location.y - rewindTimelineView.center.y - 10.0) / 30.0
        
        if gesture.state == .began {
            player.pause()
            rewindTimelineView.initialTime = CMTimeGetSeconds(playerItem.currentTime())
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut], animations: {
                self.rewindDimView.effect = UIBlurEffect(style: .dark)
                self.rewindContentView.alpha = 1.0
                }, completion: nil)
        } else if gesture.state == .changed {
            rewindTimelineView.rewindByDistance(previousLocationX - location.x)
        } else {
            player.play()
            
            let newTime = CMTime(seconds: rewindTimelineView.currentTime, preferredTimescale: playerItem.currentTime().timescale)
            playerItem.seek(to: newTime)
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut], animations: {
                self.rewindDimView.effect = nil
                self.rewindContentView.alpha = 0.0
                }, completion: nil)
        }
        
        if previousLocationX != location.x {
            previousLocationX = location.x
        }
    }

    override open var prefersStatusBarHidden : Bool {
        return true
    }

    // MARK: - Layout

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        let navigationBar = UINavigationBar()
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 45)
        navigationBar.backgroundColor = UIColor.white
        let navigationItem = UINavigationItem()
        
        //Home按钮
        let homebutton: UIButton = UIButton(type: UIButtonType.custom)
        homebutton.setImage(UIImage(named: "top_icon_home01.png"), for: .normal)
        homebutton.isEnabled = true
        homebutton.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        homebutton.addTarget(self, action: #selector(backhome), for: .touchDown)
        
        let rightBarButton = UIBarButtonItem(customView: homebutton)
        navigationItem.rightBarButtonItem = rightBarButton
        
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        navigationBar.items = [navigationItem]
        
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        
        view.addSubview(navigationBar)
        
        playerLayer.frame = CGRect(x:0,y:navigationBar.bounds.height,width:self.view.bounds.width,height:(self.view.bounds.height-200))
        rewindDimView.frame = CGRect(x:0,y:navigationBar.bounds.height,width:self.view.bounds.width,height:(self.view.bounds.height-200))
        rewindContentView.frame = CGRect(x:0,y:navigationBar.bounds.height,width:self.view.bounds.width,height:(self.view.bounds.height-200))
        
        let timelineHeight: CGFloat = 10.0
        let verticalSpacing: CGFloat = 25.0
        
        let rewindPreviewImageViewWidth = rewindPreviewImageView.image?.size.width ?? 0.0
        rewindPreviewImageView.frame = CGRect(x: (rewindContentView.bounds.width - rewindPreviewImageViewWidth) / 2.0, y: (rewindContentView.bounds.height - rewindPreviewMaxHeight - verticalSpacing - rewindCurrentTimeLabel.bounds.height - verticalSpacing - timelineHeight) / 2.0, width: rewindPreviewImageViewWidth, height: rewindPreviewMaxHeight)
        rewindCurrentTimeLabel.frame = CGRect(x: 0.0, y: rewindPreviewImageView.frame.maxY + verticalSpacing, width: rewindTimelineView.bounds.width, height: rewindCurrentTimeLabel.frame.height)
        rewindTimelineView.frame = CGRect(x: 0.0, y: rewindCurrentTimeLabel.frame.maxY + verticalSpacing, width: rewindContentView.bounds.width, height: timelineHeight)
        rewindPreviewShadowLayer.frame = rewindPreviewImageView.frame
        
        let path = UIBezierPath(roundedRect: rewindPreviewImageView.bounds, cornerRadius: 5.0).cgPath
        rewindPreviewShadowLayer.shadowPath = path
        (rewindPreviewImageView.layer.mask as! CAShapeLayer).path = path
    }

}
