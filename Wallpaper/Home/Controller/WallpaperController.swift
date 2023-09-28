//
//  WallpaperController.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/18.
//

import UIKit
import HandyJSON
import SwiftyUserDefaults
import SwiftyJSON
import Kingfisher
import Lantern
import ParallaxHeader

class WallpaperController: UICollectionViewController {

    var wallpapers = [WallpaperItem]()
    
    var style: UIStatusBarStyle = .default {
        didSet {
            if style != oldValue {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    
    var currentIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setupAndStartScaleAnimation()
        self.view.backgroundColor = .white
        collectionView.backgroundColor = .white
        self.navigationItem.title = "最美壁纸"
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        self.collectionView.keyboardDismissMode = .onDrag
        //self.collectionView.contentInsetAdjustmentBehavior = .never
        self.collectionView.register(UINib(nibName: "WallpaperCell", bundle: nil), forCellWithReuseIdentifier: "WallpaperCell")
        self.getWallpapers()
    }
    
    @IBAction func refreshAction(_ sender: UIBarButtonItem) {
        self.sendRequest()
    }
    
    func getWallpapers() {
        let obj = Defaults.wallpapers
        if obj.count > 0, let model = JSONDeserializer<WallpaperModel>.deserializeFrom(json: obj) {
            self.wallpapers = model.data
            self.collectionView.reloadData()
        }
    }
        
    func sendRequest() {
        let api = Api.randomWallpaper + "?_=\(Date().milliStamp)"
        RequestTool.request(url: api, httpMethod: .get) { success in
            if let model = JSONDeserializer<WallpaperModel>.deserializeFrom(json: success.description) {
                if model.status == 200, model.data.count > 0 {
                    self.collectionView.performBatchUpdates {
                        self.wallpapers.insert(contentsOf: model.data, at: 0)
                        self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                    } completion: { _ in
                        self.collectionView.reloadData()
                    }
                    let data = WallpaperModel()
                    data.data = self.wallpapers
                    //可以本地存储自定义模型数组，但是简单点就存储一个JSON字符串即可
                    Defaults.wallpapers = data.toJSONString() ?? ""
                }
            }
        }
    }
    
    func setupAndStartScaleAnimation() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values =  [1.0, 1.2]
        animation.duration = 7
        animation.repeatCount = .infinity
        animation.calculationMode = .cubic
        animation.autoreverses = true
        animation.isRemovedOnCompletion = false
        self.collectionView.layer.add(animation, forKey: "zooming")
    }
    
}

extension WallpaperController: UICollectionViewDelegateFlowLayout {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WallpaperCell", for: indexPath) as? WallpaperCell {
            cell.item = wallpapers[indexPath.item]
            cell.downBtn.addTarget(self, action: #selector(downImage(indexPath:)), for: .touchUpInside)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-2*2)/3.0
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: currentIndexPath) as? WallpaperCell else { return nil }
        return .init(view: cell)
    }
    
    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: currentIndexPath) as? WallpaperCell else { return nil }
        return .init(view: cell)
    }
    
    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        self.currentIndexPath = indexPath

        return .init(identifier: indexPath as NSCopying) {
            return nil
        } actionProvider: { _ in
            let select = UIAction(
                title: "下载原图",
                image: UIImage(systemName: "square.and.arrow.down")
            ) { [weak self] _ in
                guard let self = self else { return }
                self.downImage(indexPath: indexPath)
            }

            let menu = UIMenu.init(children: [select])
            return menu
        }

    }
    
    @objc func downImage(indexPath: IndexPath) {
        if let src = wallpapers[indexPath.item].src, src.rawSrc.count > 0, let url = URL(string: src.rawSrc) {
            ImageDownloadTool.downloadNetworkImage(with: url, options: [.backgroundDecode], completionHandler:  { image in
                guard let img = image else { return }
                PhotoSaveTool.savePhotoWithImage(img)
            })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.openLantern(with: collectionView, indexPath: indexPath)
    }
    
    //专业做大图预览，优点在于可push，可无限加载
    func openLantern(with collectionView: UICollectionView, indexPath: IndexPath) {
        let lantern = Lantern()
        lantern.numberOfItems = {[weak self] in
            self?.wallpapers.count ?? 0
        }
        lantern.reloadCellAtIndex = { context in
            let lanternCell = context.cell as? LanternImageCell
            let indexPath = IndexPath(item: context.index, section: indexPath.section)
            let collectionCell = collectionView.cellForItem(at: indexPath) as? WallpaperCell
            let placeholder = collectionCell?.icon.image
            lanternCell?.imageView.setImage(fromURL: self.wallpapers[indexPath.item].src?.smallSrc, placeholder: placeholder, completionHandler: { _ in
                lanternCell?.setNeedsLayout()
            })
            
            //collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
        // 更丝滑的Zoom动画
        lantern.transitionAnimator = LanternSmoothZoomAnimator(transitionViewAndFrame: { (index, destinationView) -> LanternSmoothZoomAnimator.TransitionViewAndFrame? in
            let path = IndexPath(item: index, section: indexPath.section)
            guard let cell = collectionView.cellForItem(at: path) as? WallpaperCell else {
                return nil
            }
            let image = cell.icon.image
            let transitionView = UIImageView(image: image)
            transitionView.contentMode = cell.icon.contentMode
            transitionView.clipsToBounds = true
            let thumbnailFrame = cell.icon.convert(cell.icon.bounds, to: destinationView)
            return (transitionView, thumbnailFrame)
        })
        lantern.pageIndicator = LanternNumberPageIndicator()
        lantern.pageIndex = indexPath.item
        lantern.show(method: .present(fromVC: nil, embed: nil))
    }
}














