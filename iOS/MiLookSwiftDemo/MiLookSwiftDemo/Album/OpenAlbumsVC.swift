//
//  OpenAlbumsVC.swift
//  MiLookSwiftDemo
//
//  Created by 侯 银博 on 2017/4/25.
//  Copyright © 2017年 houyinbo. All rights reserved.
//

import UIKit
import Foundation
import Photos

class OpenAlbumsVC:UIViewController,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,PHPhotoLibraryChangeObserver{
    
    enum AlbumType: Int {
        case allPhotos
        case favorites
        case panoramas
        case videos
        case timeLapse
        case recentlyDeleted
        case userAlbum
        
        static let titles = ["All Photos", "Favorites", "Panoramas", "Videos", "Time Lapse", "Recently Deleted", "User Album"]
    }
    
    struct RootListItem {
        var title: String!
        var albumType: AlbumType
        var image: UIImage!
        var collection: PHAssetCollection?
    }
    
    fileprivate var items: Array<RootListItem>!
    
    fileprivate let thumbnailSize = CGSize(width: 64, height: 64)
    fileprivate let reuseIdentifier = "RootListAssetsCell"
    
    fileprivate var assetGridThumbnailSize: CGSize = CGSize(width: 0, height: 0)
    fileprivate let typeIconSize = CGSize(width: 20, height: 20)
    fileprivate let checkMarkSize = CGSize(width: 28, height: 28)
    fileprivate let iconOffset: CGFloat = 3
    fileprivate let collectionViewEdgeInset: CGFloat = 2
    fileprivate let assetsInRow: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 4 : 8
    
    let cachingImageManager = PHCachingImageManager()
    var collection: PHAssetCollection?
   
    fileprivate var assets: [PHAsset]! {
        willSet {
            cachingImageManager.stopCachingImagesForAllAssets()
        }
        
        didSet {
            cachingImageManager.startCachingImages(for: self.assets, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFill, options: nil)
        }
    }
    
    var collectionView: UICollectionView!
    let navigationBar = UINavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 45)
        navigationBar.backgroundColor = UIColor.white
        let navigationItem = UINavigationItem()
        
        //Back按钮
        let backbutton: UIButton = UIButton(type: UIButtonType.custom)
        backbutton.setImage(UIImage(named: "top_icon_back"), for: .normal)
        backbutton.isEnabled = true
        backbutton.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        backbutton.addTarget(self, action: #selector(backhome), for: .touchDown)
        
        let leftBarButton = UIBarButtonItem(customView: backbutton)
        navigationItem.leftBarButtonItem = leftBarButton
        
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        navigationBar.items = [navigationItem]
        
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        
        self.view.addSubview(navigationBar)
        
        // Data
        items = Array()
        
        // Notifications
        PHPhotoLibrary.shared().register(self)
        
        // Load photo library
        loadData()

    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func loadData() {
        
        DispatchQueue.global(qos: .default).async {
            
            self.items.removeAll(keepingCapacity: false)
            
            let allPhotosItem = RootListItem(title: AlbumType.titles[AlbumType.videos.rawValue], albumType: AlbumType.videos, image: self.lastImageFromCollection(nil), collection: nil)
            let assetsCount = self.assetsCountFromCollection(nil)
            if assetsCount > 0 {
                self.items.append(allPhotosItem)
            }
            
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
            for i: Int in 0 ..< smartAlbums.count {
                let smartAlbum = smartAlbums[i]
                var item: RootListItem? = nil
                
                let assetsCount = self.assetsCountFromCollection(smartAlbum)
                if assetsCount == 0 {
                    continue
                }
                
                switch smartAlbum.assetCollectionSubtype {
                case .smartAlbumFavorites:
                    item = RootListItem(title: AlbumType.titles[AlbumType.favorites.rawValue], albumType: AlbumType.favorites, image: self.lastImageFromCollection(smartAlbum), collection: smartAlbum)
                    break
                case .smartAlbumPanoramas:
                    item = RootListItem(title: AlbumType.titles[AlbumType.panoramas.rawValue], albumType: AlbumType.panoramas, image: self.lastImageFromCollection(smartAlbum), collection: smartAlbum)
                    break
                case .smartAlbumVideos:
                    item = RootListItem(title: AlbumType.titles[AlbumType.videos.rawValue], albumType: AlbumType.videos, image: self.lastImageFromCollection(smartAlbum), collection: smartAlbum)
                    break
                case .smartAlbumTimelapses:
                    item = RootListItem(title: AlbumType.titles[AlbumType.timeLapse.rawValue], albumType: AlbumType.timeLapse, image: self.lastImageFromCollection(smartAlbum), collection: smartAlbum)
                    break
                    
                default:
                    break
                }
                
                if item != nil {
                    self.items.append(item!)
                }
            }
            
            let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            for i: Int in 0 ..< topLevelUserCollections.count {
                if let userCollection = topLevelUserCollections[i] as? PHAssetCollection {
                    let assetsCount = self.assetsCountFromCollection(userCollection)
                    if assetsCount == 0 {
                        continue
                    }
                    let item = RootListItem(title: userCollection.localizedTitle, albumType: AlbumType.userAlbum, image: self.lastImageFromCollection(userCollection), collection: userCollection)
                    self.items.append(item)
                }
            }
            
        }
       
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.headerReferenceSize = CGSize.zero
        layout.footerReferenceSize = CGSize.zero
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.sectionInset = UIEdgeInsets.zero
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.frame = CGRect(x: 0,y: navigationBar.bounds.height,width: self.view.bounds.width, height: (self.view.bounds.height - navigationBar.bounds.height))
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        view.addSubview(collectionView)
        
        let scale = UIScreen.main.scale
        
        let cellSize = CGSize(width: 50, height: 50)

        assetGridThumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        let assetsFetchResult = (collection == nil) ? PHAsset.fetchAssets(with: .video, options: nil) : PHAsset.fetchAssets(in: collection!, options: nil)
        assets = assetsFetchResult.objects(at: IndexSet(integersIn: NSMakeRange(0, assetsFetchResult.count).toRange()!))
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func backhome() {
        self.dismiss(animated: true, completion: nil)
    }
    
    open func photoLibraryDidChange(_ changeInstance: PHChange) {
        loadData()
    }
    
    // MARK: Other
    
    func assetsCountFromCollection(_ collection: PHAssetCollection?) -> Int {
        let fetchResult = (collection == nil) ? PHAsset.fetchAssets(with: .video, options: nil) : PHAsset.fetchAssets(in: collection!, options: nil)
        return fetchResult.count
    }
    
    func lastImageFromCollection(_ collection: PHAssetCollection?) -> UIImage? {
        
        var returnImage: UIImage? = nil
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = (collection == nil) ? PHAsset.fetchAssets(with: .video, options: fetchOptions) : PHAsset.fetchAssets(in: collection!, options: fetchOptions)
        if let lastAsset = fetchResult.lastObject {
            
            let imageRequestOptions = PHImageRequestOptions()
            imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
            imageRequestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
            imageRequestOptions.isSynchronous = true
            
            let retinaScale = UIScreen.main.scale
            let retinaSquare = CGSize(width: thumbnailSize.width * retinaScale, height: thumbnailSize.height * retinaScale)
            
            let cropSideLength = min(lastAsset.pixelWidth, lastAsset.pixelHeight)
            let square = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(cropSideLength), height: CGFloat(cropSideLength))
            let cropRect = square.applying(CGAffineTransform(scaleX: 1.0 / CGFloat(lastAsset.pixelWidth), y: 1.0 / CGFloat(lastAsset.pixelHeight)))
            
            imageRequestOptions.normalizedCropRect = cropRect
            
            PHImageManager.default().requestImage(for: lastAsset, targetSize: retinaSquare, contentMode: PHImageContentMode.aspectFit, options: imageRequestOptions, resultHandler: { (image: UIImage?, info :[AnyHashable: Any]?) -> Void in
                returnImage = image
            })
        }
        
        return returnImage
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.black
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
        var thumbnail: UIImageView!
        var typeIcon: UIImageView!
        var checkMarkView: UIImageView!
        
        if cell.contentView.subviews.count == 0 {
            thumbnail = UIImageView(frame: cell.contentView.frame)
            thumbnail.contentMode = .scaleAspectFill
            thumbnail.clipsToBounds = true
            cell.contentView.addSubview(thumbnail)
            
            typeIcon = UIImageView(frame: CGRect(x: iconOffset, y: cell.contentView.frame.size.height - iconOffset - typeIconSize.height, width: typeIconSize.width, height: typeIconSize.height))
            typeIcon.contentMode = .scaleAspectFill
            typeIcon.clipsToBounds = true
            cell.contentView.addSubview(typeIcon)
            
            checkMarkView = UIImageView(frame: CGRect(x: cell.contentView.frame.size.width - iconOffset - checkMarkSize.width, y: iconOffset, width: checkMarkSize.width, height: checkMarkSize.height))
            checkMarkView.backgroundColor = UIColor.clear
            
            cell.contentView.addSubview(checkMarkView)
        }
        else {
            thumbnail = cell.contentView.subviews[0] as! UIImageView
            typeIcon = cell.contentView.subviews[1] as! UIImageView
            checkMarkView = cell.contentView.subviews[2] as! UIImageView
        }
        
        let asset = assets[(indexPath as NSIndexPath).row]
        
        typeIcon.image = nil
        if asset.mediaType == .video {
            if asset.mediaSubtypes == .videoTimelapse {
                typeIcon.image = UIImage(named: "timelapse-icon.png")
            }
            else {
                typeIcon.image = UIImage(named: "video-icon.png")
            }
        }
        else if asset.mediaType == .image {
            if asset.mediaSubtypes == .photoPanorama {
                typeIcon.image = UIImage(named: "panorama-icon.png")
            }
        }
        
        
        cachingImageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { (image: UIImage?, info :[AnyHashable: Any]?) -> Void in
            if cell.tag == currentTag {
                thumbnail.image = image
            }
        })
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .fastFormat
        PHImageManager.default().requestAVAsset(forVideo: assets[(indexPath as NSIndexPath).row], options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
            
            if let urlAsset = asset as? AVURLAsset {
                let localVideoUrl : URL = urlAsset.url
                print(localVideoUrl)
                let playViewController = PlayViewController(videoURL: localVideoUrl)
                self.present(playViewController, animated: true, completion: nil)
            } else {
                
            }
        })
        
    
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let a = (self.view.frame.size.width - assetsInRow * 1 - 2 * collectionViewEdgeInset) / assetsInRow
        return CGSize(width: a, height: a)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(collectionViewEdgeInset, collectionViewEdgeInset, collectionViewEdgeInset, collectionViewEdgeInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

}
