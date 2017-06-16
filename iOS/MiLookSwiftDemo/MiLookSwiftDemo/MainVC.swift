//
//  ViewController.swift
//  MiLookSwiftDemo
//
//  Created by 侯 银博 on 2016/11/15.
//  Copyright © 2016 Shanghai Yingsui Inc. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MiLookSDK
import HandyJSON
import QuartzCore
import SnapKit
import Photos
import ASHorizontalScrollView
import RecordButton
import InfiniteCollectionView
import PermissionScope
import AssetsLibrary

class MainVC:UIViewController,MiLookSDKDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let pscope = PermissionScope()
    
    var milooksdk:MiLookSDK!
    
    let cameraModel:CameraModel = CameraModel()
    
    let decorationModel:DecorationModel = DecorationModel()
    
    var box:UIView?
    
    var recordImg: UIImageView! = nil
    
    var scoreTimer = Timer()
    
    var recordButton : RecordButton!
    var progressTimer : Timer!
    var progress : CGFloat! = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    let albumbutton: UIButton = UIButton(type: UIButtonType.custom)
    let switchbutton: UIButton = UIButton(type: UIButtonType.custom)
    let flashbutton: UIButton = UIButton(type: UIButtonType.custom)
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.headerReferenceSize = CGSize.zero
        layout.footerReferenceSize = CGSize.zero
        layout.sectionInset = UIEdgeInsets.zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.isScrollEnabled = true
        return cv
    }()
    
    public var albumName: String? = "Milo"
    
    private func createAlbum() {
        guard albumName != nil else {
            print("Album name is not set")
            return
        }
        
        let library = ALAssetsLibrary()
        library.addAssetsGroupAlbum(withName: albumName, resultBlock: { (group) -> Void in
            print("Album added: \(self.albumName!)")
        }, failureBlock: { (error) -> Void in
            print("Error adding album \(String(describing: error))")
        })
    }

   
    override func viewDidLoad() {
        super.viewDidLoad()
        pscope.viewControllerForAlerts = self
        // Set up permissions
        pscope.addPermission(CameraPermission(),
                             message: "We want to use Camera")
        pscope.addPermission(MicrophonePermission(),
                             message: "We want to use Microphone")
        pscope.addPermission(PhotosPermission(),
                             message: "We want to save your memories")
        
        // Show dialog with callbacks
        pscope.show({ finished, results in
            print("got results \(results)")
        }, cancelled: { (results) -> Void in
            print("thing was cancelled")
        })
        
        pscope.onDisabledOrDenied = { results in
            print("Request was denied or disabled with results \(results)")
        }

        UIApplication.shared.setStatusBarHidden(true, with: .none)

        self.view.backgroundColor = UIColor.white
        
        let navigationBar = UINavigationBar()
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 45)
        navigationBar.backgroundColor = UIColor.white
        let navigationItem = UINavigationItem()
        
        //相册按钮
       
        albumbutton.setImage(UIImage(named: "top_btn_my01.png"), for: .normal)
        albumbutton.setImage(UIImage(named: "top_btn_my02.png"), for: .highlighted)

        albumbutton.isEnabled = true
        albumbutton.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        albumbutton.addTarget(self, action: #selector(openAlbum), for: .touchDown)
    
        let leftBarButton = UIBarButtonItem(customView: albumbutton)
        navigationItem.leftBarButtonItem = leftBarButton
        
        //切换摄像头按钮
    
        switchbutton.setImage(UIImage(named: "top_btn_camera01.png"), for: .normal)
        switchbutton.isEnabled = true
        switchbutton.frame = CGRect(x: 0, y: 0, width: 36, height: 30)
        switchbutton.addTarget(self, action:  #selector(switchCam), for: .touchDown)
        let rightBarButton = UIBarButtonItem(customView: switchbutton)
        
        //闪光灯按钮
        
        flashbutton.setImage(UIImage(named: "top_btn_noflash01.png"), for: UIControlState())
        
        flashbutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        flashbutton.isHidden = true
        flashbutton.addTarget(self, action: #selector(flashSwitch), for: .touchDown)
        let rightBarButton2 = UIBarButtonItem(customView: flashbutton)
        
        
        navigationItem.setRightBarButtonItems([rightBarButton,rightBarButton2], animated: true)
        
 
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        navigationBar.items = [navigationItem]
        
        self.view.addSubview(navigationBar)
        
    
        milooksdk = MiLookSDK.share() as! MiLookSDK
        if milooksdk.initSDK("", withRootPath: Bundle.main.bundlePath + "/resource/", withModelPath: "milo_data.bin", withMaxFace: 1) {
            box = milooksdk.startPreview(CGRect(x: 0, y: navigationBar.bounds.height, width:self.view.bounds.width, height: (self.view.bounds.height-220)))
            
            self.view.addSubview(box!)
            box?.frame = CGRect(x: 0, y: navigationBar.bounds.height, width:self.view.bounds.width, height: (self.view.bounds.height-220))
        
            cameraModel.cameraID = 1
            cameraModel.flash = false
            cameraModel.previewSize = "640x480"
            cameraModel.fps = 30
            cameraModel.orientation = "portrait"
            cameraModel.sound = true
            milooksdk.startCamera(cameraModel.toJSONString())
        }
        
        view.addSubview(collectionView)
        collectionView.frame = CGRect(x: 0,y: (self.view.bounds.height-170),width: self.view.bounds.width, height: 80)
        collectionView.register(ImageCollectionViewCell.nib, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        
        // set up recorder button
        recordButton = RecordButton(frame: CGRect(x: 0,y: self.view.bounds.height-80,width: 70,height: 70))
        recordButton.buttonColor = UIColor.red
        recordButton.progressColor = UIColor.red
        recordButton.closeWhenFinished = false
        //recordButton.addTarget(self, action: #selector(self.record), for: .touchDown)
        //recordButton.addTarget(self, action: #selector(self.stop), for: UIControlEvents.touchUpInside)
        recordButton.center.x = self.view.center.x
        
        recordButton.isHidden = true
       
        view.addSubview(recordButton)
        
        recordImg = UIImageView(frame: CGRect(x: 0,y: self.view.bounds.height-80,width: 70,height: 70))
        recordImg.image = UIImage(named: "main_rec_btn_nor.png")
        recordImg.center.x = self.view.center.x
        recordImg.isHidden = false
        recordImg.isUserInteractionEnabled = true
        recordImg.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapAction(_:))))
        view.addSubview(recordImg)
        
    }
    
    //关闭道具/0
    func resetDecoration(){
        decorationModel.points = false
        decorationModel.maxFace = 1
        decorationModel.faceDeform = FaceDeformModel()
        decorationModel.faceDeform.slim = 0
        decorationModel.faceDeform.bigEye = 0
        decorationModel.faceDeform.jaw = 0
        decorationModel.beautify = BeautifyModel()
        decorationModel.beautify.level = 0
        self.decorationModel.comb.removeAll()
        self.decorationModel.videoFilter = VideoFilterModel()
        milooksdk.setDecorationClear()
    }
    
    //关闭道具/0
    func setdecoration0(){
        decorationModel.points = false
        decorationModel.maxFace = 1
        decorationModel.faceDeform = FaceDeformModel()
        decorationModel.faceDeform.slim = 0
        decorationModel.faceDeform.bigEye = 0
        decorationModel.faceDeform.jaw = 0
        decorationModel.beautify = BeautifyModel()
        decorationModel.beautify.level = 1
        self.decorationModel.comb.removeAll()
        self.decorationModel.videoFilter = VideoFilterModel()
        //print(self.decorationModel.toJSONString() ?? " ")

        milooksdk.setDecoration(self.decorationModel.toJSONString())
    }
    
    //道具1
    func setdecoration1(){
        
        self.decorationModel.comb = Array<CombModel>()
        var acc:CombModel = CombModel()
        acc.type = "foreground6"
        acc.folder = "foreground6.xml"
        self.decorationModel.comb.append(acc)
        
        var acc1:CombModel = CombModel()
        acc1.type = "Mask1"
        acc1.folder = "Mask1.xml"
        self.decorationModel.comb.append(acc1)
        
        var acc2:CombModel = CombModel()
        acc2.type = "Face_Fire.xml"
        acc2.folder = "Face_Fire.xml"
        self.decorationModel.comb.append(acc2)
        milooksdk.setDecoration(self.decorationModel.toJSONString())
        
    }
    
    //道具2
    func setdecoration2(){
        self.decorationModel.comb = Array<CombModel>()
        var acc:CombModel = CombModel()
        acc.type = "05_004025.mask"
        acc.folder = "05_004025.mask.xml"
        self.decorationModel.comb.append(acc)
        
        var acc1:CombModel = CombModel()
        acc1.type = "3d_horn"
        acc1.folder = "3d_horn.xml"
        self.decorationModel.comb.append(acc1)
        
//        var acc2:CombModel = CombModel()
//        acc2.type = "foreground5"
//        acc2.folder = "foreground5.xml"
//        self.decorationModel.comb.append(acc2)
        
        milooksdk.setDecoration(self.decorationModel.toJSONString())
        
    }
    
    //道具3
    func setdecoration3(){
        self.decorationModel.comb = Array<CombModel>()
        var acc:CombModel = CombModel()
        acc.type = "05_004012.mask"
        acc.folder = "05_004012.mask.xml"
        self.decorationModel.comb.append(acc)
        
        var acc1:CombModel = CombModel()
        acc1.type = "3d_glasses"
        acc1.folder = "3d_glasses.xml"
        self.decorationModel.comb.append(acc1)
        milooksdk.setDecoration(self.decorationModel.toJSONString())
    }
    
    //道具4
    func setdecoration4(){
        self.decorationModel.comb = Array<CombModel>()
        var acc:CombModel = CombModel()
        acc.type = "3d_mummy"
        acc.folder = "3d_mummy.xml"
        self.decorationModel.comb.append(acc)
        milooksdk.setDecoration(self.decorationModel.toJSONString())
    }
    
    //道具5
    func setdecoration5(){
        self.decorationModel.comb = Array<CombModel>()
        var acc:CombModel = CombModel()
        acc.type = "3d_viking"
        acc.folder = "3d_viking.xml"
        self.decorationModel.comb.append(acc)
        milooksdk.setDecoration(self.decorationModel.toJSONString())
    }
    
    //道具6
    func setdecoration6(){
        self.decorationModel.faceDeform = FaceDeformModel()
        self.decorationModel.faceDeform.slim = 1
        self.decorationModel.faceDeform.bigEye = 1
        self.decorationModel.faceDeform.jaw = 1
        self.decorationModel.beautify = BeautifyModel()
        self.decorationModel.beautify.level = 1
        
        self.decorationModel.comb = Array<CombModel>()
        var acc:CombModel = CombModel()
        acc.type = "bear"
        acc.folder = "bear0.xml"
        self.decorationModel.comb.append(acc)
        
        var acc1:CombModel = CombModel()
        acc1.type = "bear_nose"
        acc1.folder = "bear_nose.xml"
        self.decorationModel.comb.append(acc1)
        
        var acc2:CombModel = CombModel()
        acc2.type = "bear1"
        acc2.folder = "bear1.xml"
        self.decorationModel.comb.append(acc2)

        
        self.milooksdk.setDecoration(self.decorationModel.toJSONString())
        //print(self.decorationModel.toJSONString() ?? " ")
        milooksdk.setDecoration(self.decorationModel.toJSONString())
        
        
    }
    
    //道具7
    func setdecoration7(){
        self.decorationModel.faceDeform = FaceDeformModel()
        self.decorationModel.faceDeform.slim = 1
        self.decorationModel.faceDeform.bigEye = 1
        self.decorationModel.faceDeform.jaw = 1
        self.decorationModel.beautify = BeautifyModel()
        self.decorationModel.beautify.level = 1
        
        self.decorationModel.comb = Array<CombModel>()
        var acc:CombModel = CombModel()
        acc.type = "dog"
        acc.folder = "Dog_V1.xml"
        self.decorationModel.comb.append(acc)
        
        var acc1:CombModel = CombModel()
        acc1.type = "dog_nose"
        acc1.folder = "Dog_V2.xml"
        self.decorationModel.comb.append(acc1)
        
        self.milooksdk.setDecoration(self.decorationModel.toJSONString())
        //print(self.decorationModel.toJSONString() ?? " ")
        milooksdk.setDecoration(self.decorationModel.toJSONString())
        
        
    }
    
    //道具8
    func setdecoration8(){
        self.decorationModel.faceDeform = FaceDeformModel()
        self.decorationModel.faceDeform.slim = 0
        self.decorationModel.faceDeform.bigEye = 0
        self.decorationModel.faceDeform.jaw = 0
        self.decorationModel.beautify = BeautifyModel()
        self.decorationModel.beautify.level = 1
        
        
        self.decorationModel.videoFilter = VideoFilterModel()
        self.decorationModel.videoFilter.type = "LightFilter"
        self.decorationModel.videoFilter.folder = "LightFilter.png"
        
        self.milooksdk.setDecoration(self.decorationModel.toJSONString())
        
        milooksdk.setDecoration(self.decorationModel.toJSONString())
    }
    
    //道具9
    func setdecoration9(){
        self.decorationModel.comb = Array<CombModel>()
        var acc:CombModel = CombModel()
        acc.type = "army_goggle"
        acc.folder = "army_goggle.xml"
        self.decorationModel.comb.append(acc)
        milooksdk.setDecoration(self.decorationModel.toJSONString())
    }
    
    //道具10
    func setdecoration10(){
        self.decorationModel.comb = Array<CombModel>()
        var acc:CombModel = CombModel()
        acc.type = "angry_bird"
        acc.folder = "angry_bird.xml"
        self.decorationModel.comb.append(acc)
        //print(self.decorationModel.toJSONString() ?? " ")
        milooksdk.setDecoration(self.decorationModel.toJSONString())
        
       
    }
    
    
    func updateProgress() {
        let maxDuration = CGFloat(20) // Max duration of the recordButton
        
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        if progress >= 1 {
            progressTimer.invalidate()
            if(milooksdk.cameraID == 0){
                flashbutton.isHidden = false
            }
            switchbutton.isHidden = false
            albumbutton.isHidden = false
            
            capturing = false
            videoInput?.markAsFinished()
            audioInput?.markAsFinished()
            assetWriter?.finishWriting(completionHandler: {[unowned self] () -> Void in
                self.videourl = (self.assetWriter?.outputURL)!
                print(self.videourl ?? "")
                if(self.assetWriter?.error != nil){
                    print(self.assetWriter?.error ?? "")
                }else{
                    let videoViewController = VideoViewController(videoURL: self.videourl!)
                    self.present(videoViewController, animated: true, completion: nil)
                }
                
            })
            
            milooksdk.delegate = nil
            recordImg.isHidden = false
            
            progress = 0
            recordButton.setProgress(progress)
            recordButton.isHidden = true
            capturing = false;
            
        }
    }
    
    func stop() {
        self.progressTimer.invalidate()
        if(milooksdk.cameraID == 0){
            flashbutton.isHidden = false
        }
        switchbutton.isHidden = false
        albumbutton.isHidden = false
        
        recordImg.isHidden = false
        progress = 0
        recordButton.setProgress(progress)
        recordButton.isHidden = true
        capturing = false;
    }
    
    @objc private func tapAction(_ tap: UITapGestureRecognizer) {
        if(!capturing){
        capturing = true;
        recordImg.isHidden = true
        recordButton.isHidden = false
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
        flashbutton.isHidden = true
        switchbutton.isHidden = true
        albumbutton.isHidden = true
        self.recordVideo()
        }
    }
    
    var videourl:URL?
    
    open var didSelectAssets: ((Array<PHAsset?>) -> ())?

    //打开相册
    func openAlbum() {
        let openAlbumView = OpenAlbumsVC()
        self.present(openAlbumView, animated: true, completion: nil)
    }
    
    //切换摄像头
    func switchCam() {
        milooksdk.switchCamera()
        if(milooksdk.cameraID == 0){
            flashbutton.isEnabled = true
            flashbutton.isHidden = false
        }else{
            flashbutton.isEnabled = false
            flashbutton.isHidden = true
        }
        if(milooksdk.flashStatus){
            flashbutton.setImage(UIImage(named: "top_btn_flash01.png"), for: UIControlState())
        }else{
            flashbutton.setImage(UIImage(named: "top_btn_noflash01.png"), for: UIControlState())
        }
    }
    
    //闪光灯
    func flashSwitch() {
        if(milooksdk.flashStatus){
            milooksdk.turnOffFlash()
            flashbutton.setImage(UIImage(named: "top_btn_noflash01.png"), for: UIControlState())
        }else{
            milooksdk.turnOnFlash()
            flashbutton.setImage(UIImage(named: "top_btn_flash01.png"), for: UIControlState())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var assetWriter: AVAssetWriter?
    fileprivate var videoInput: AVAssetWriterInput?
    fileprivate var audioInput: AVAssetWriterInput!
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?

    var framesWritten: Int64 = 0
    var capturing = false

    static let defaultFPS:Float64 = 30
    static let defaultVideoSettings:[NSObject: AnyObject] = [
        kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA) as AnyObject
    ]
    
    fileprivate var outputUrl:URL?
    
    func recordVideo(){
        self.outputUrl = URL(fileURLWithPath: String(format: "%@%lld.mov", NSTemporaryDirectory(), mach_absolute_time()));
        let outputSettings: [String:AnyObject] = [  AVVideoWidthKey     : 480 as AnyObject,
                                                    AVVideoHeightKey    : 640 as AnyObject,
                                                    AVVideoCodecKey     : AVVideoCodecH264 as AnyObject]
        videoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: outputSettings)
        let pixelBufferAttributes : [String:AnyObject] = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)]
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput!, sourcePixelBufferAttributes: pixelBufferAttributes)
        do {
            assetWriter = try AVAssetWriter(outputURL: self.outputUrl! as URL, fileType: AVFileTypeMPEG4)
        } catch (let error as NSError) {
            print(error.localizedDescription)
        }
        
        if (assetWriter?.canAdd(videoInput!))! {
            assetWriter?.add(videoInput!)
        }
        
        let audioOutputSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey:2
        ] as [String : Any]
        

        audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioOutputSettings)
        audioInput!.expectsMediaDataInRealTime = true
        
        if (assetWriter?.canAdd(audioInput!))! {
            assetWriter?.add(audioInput!)
        }

        var rotationDegree:CGFloat?;
        
        switch UIDevice.current.orientation
        {
        case UIDeviceOrientation.portraitUpsideDown:
            rotationDegree = -180.0;
            break;
        case UIDeviceOrientation.landscapeLeft:
            rotationDegree = -90.0;
            break;
        case UIDeviceOrientation.landscapeRight:
            rotationDegree = 90.0;
            break;
        case UIDeviceOrientation.portrait:
            fallthrough;
        case UIDeviceOrientation.unknown:
            fallthrough;
        case UIDeviceOrientation.faceDown:
            fallthrough;
        case UIDeviceOrientation.faceUp:
            fallthrough;
        default:
            rotationDegree = 0;
        }
        //TODO: verify that the rotations radians have been obtained correctly
        let rotationRadians:CGFloat = (CGFloat(M_PI) * rotationDegree!) / 180;
        self.videoInput!.transform = CGAffineTransform(rotationAngle: rotationRadians);
        videoInput?.expectsMediaDataInRealTime = true

        DispatchQueue.onceTracker.removeAll();
        milooksdk.delegate = self
       
        capturing = true
        
    }
  
    fileprivate var audioFormatDescription: CMFormatDescription!
    
    //视频
    @objc public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!, devicePosition: AVCaptureDevicePosition, ofMediaType mediaType: String!,videoPixelBuffer pixelBuffer: CVPixelBuffer!, withPresentationTime timestamp: CMTime){
        if(capturing ){
            DispatchQueue.once(token: "recorder", block: {
                if (assetWriter?.startWriting())! {
                    assetWriter?.startSession(atSourceTime: timestamp)
                    print(assetWriter?.status ?? "")
                }
            })
            if(mediaType == AVMediaTypeVideo){
                if (videoInput?.isReadyForMoreMediaData)! {
                    pixelBufferAdaptor?.append(pixelBuffer, withPresentationTime: timestamp)
                }
            }else if (mediaType == AVMediaTypeAudio){
                if (audioInput?.isReadyForMoreMediaData)! {
                    audioInput.append(sampleBuffer!)
                }
            }
            
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 11
    }
    
    var selectedIndex = 0
    
    var selectedColor: CGColor = UIColor(red: 92.0/255.0, green: 186.0/255.0, blue: 220.0/255.0, alpha: 1.0).cgColor
        
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900)) {
            self.setdecoration0()
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        cell.configure(indexPath: indexPath)
        cell.layer.borderWidth = 1.8
        
        let tintColor = selectedIndex == indexPath.item ? selectedColor : UIColor.white.cgColor
        cell.layer.borderColor = tintColor
        cell.layer.cornerRadius = 5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedIndex != indexPath.item else { return }
        
        let oldIndexPath = IndexPath(item: selectedIndex, section: 0)
        selectedIndex = indexPath.item
        
        collectionView.reloadItems(at: [oldIndexPath, indexPath])
        
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
      
        let cell = collectionView.cellForItem(at: indexPath)!
        UIView.animate(withDuration: 0.1, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { finish in
            UIView.animate(withDuration: 0.05, animations: {
                cell.transform = CGAffineTransform.identity
            })
        })
        
        if(indexPath.item == 0){
            setdecoration0()
        }else if(indexPath.item == 1){
            setdecoration1()
        }else if(indexPath.item == 2){
            setdecoration2()
        }else if(indexPath.item == 3){
            setdecoration3()
        }else if(indexPath.item == 4){
            setdecoration4()
        }else if(indexPath.item == 5){
            setdecoration5()
        }else if(indexPath.item == 6){
            setdecoration6()
        }else if(indexPath.item == 7){
            setdecoration7()
        }else if(indexPath.item == 8){
            setdecoration8()
        }else if(indexPath.item == 9){
            setdecoration9()
        }else if(indexPath.item == 10){
            setdecoration10()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        resetDecoration()
    }
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

}

extension URL {
    static func tempPathForFile(_ name: String) -> URL {
        let outputPath = NSTemporaryDirectory() + name
        if FileManager.default.fileExists(atPath: outputPath) {
            do {
                try FileManager.default.removeItem(atPath: outputPath)
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return URL(fileURLWithPath: outputPath)
    }
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

