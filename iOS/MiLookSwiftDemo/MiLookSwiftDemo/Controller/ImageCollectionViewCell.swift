//
//  ImageCollectionViewCell.swift
//  MiLookSwiftDemo
//
//  Created by 侯 银博 on 2016/11/15.
//  Copyright © 2016 Shanghai Yingsui Inc. All rights reserved.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    static let identifier = "ImageCollectionViewCell"
    static let nib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
    func configure(indexPath: IndexPath) {
        if(indexPath.item == 0){
            imageView.image = UIImage(named: "filter_nofilter")
        }else if(indexPath.item == 1){
            imageView.image = UIImage(named: "1")
        }else if(indexPath.item == 2){
            imageView.image = UIImage(named: "2")
        }else if(indexPath.item == 3){
            imageView.image = UIImage(named: "3")
        }else if(indexPath.item == 4){
            imageView.image = UIImage(named: "4")
        }else if(indexPath.item == 5){
            imageView.image = UIImage(named: "5")
        }else if(indexPath.item == 6){
            imageView.image = UIImage(named: "6")
        }else if(indexPath.item == 7){
            imageView.image = UIImage(named: "7")
        }else if(indexPath.item == 8){
            imageView.image = UIImage(named: "filter_beautify_level02")
        }else if(indexPath.item == 9){
            imageView.image = UIImage(named: "9")
        }else if(indexPath.item == 10){
            imageView.image = UIImage(named: "10")
        }else{
            imageView.image = UIImage(named: "filter_beautify_level02")
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
