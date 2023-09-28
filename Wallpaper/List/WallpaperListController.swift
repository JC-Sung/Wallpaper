//
//  WallpaperListController.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/20.
//

import Foundation
import UIKit
import HandyJSON
import SwiftyUserDefaults
import SwiftyJSON
import Kingfisher
import Lantern
import JXSegmentedView
import CRRefresh

class WallpaperListController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageCountrl: UIButton!
    //以下均可自由组合
    
    //壁纸源
    var source: String = "" //Unsplash
    //壁纸分类
    var tag: String = "" //nature
    //壁纸颜色分类
    var color: String = "" //de8930
    //壁纸类型
    var client: String = "pc"
    //排序
    //0 默认，_id收录时间，like热度
    var order: String = "like"
    
    //起始页码
    var page: Int = 0
    
    var total: Int = 0

    var isHeader: Bool = true
    
    var isBing: Bool = false
    
    var wallpapers = [WallpaperItem]()
    var currentIndexPath: IndexPath!
    
    var currentImg: Int = 0
    
    private var downLoadButton = UIButton()
    
    private func addDownLoadButton() {
        let dismissButton = UIButton(type: .custom)
        dismissButton.isHidden = false
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        dismissButton.setTitleColor(UIColor.white, for: .normal)
        dismissButton.setTitle("", for: .normal)
        dismissButton.setImage(UIImage(named: "menue_save"), for: .normal)
        dismissButton.addTarget(self, action: #selector(saveImgggAction), for: .touchUpInside)
        dismissButton.sizeToFit()
        dismissButton.frame = CGRect.init(x: (UIScreen.main.bounds.size.width-40)*0.5, y: UIScreen.main.bounds.size.height-40-bottomHeight(), width: 40, height: 40)
        self.downLoadButton = dismissButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageCountrl.layer.cornerRadius = 14
        self.pageCountrl.layer.masksToBounds = true
        self.pageCountrl.isHidden = true
        self.pageCountrl.transform = .init(translationX: 0, y: bottomHeight()+32)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionView.keyboardDismissMode = .onDrag
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.collectionView.register(UINib(nibName: "WallpaperCell", bundle: nil), forCellWithReuseIdentifier: "WallpaperCell")
        
        self.isBing = self.tag == "Bing"
        
        if self.isBing {
            collectionView.cr.addHeadRefresh(animator: SlackLoadingAnimator()) { [weak self] in
                self?.getBing()
            }
            setupAndStartScaleAnimation()
        } else {
            
            let layout = WaterfallLayout()
            layout.delegate = self
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            layout.minimumLineSpacing = 16
            layout.minimumInteritemSpacing = 16
            layout.headerHeight = 0
            collectionView.collectionViewLayout = layout
            
            collectionView.cr.addHeadRefresh(animator: SlackLoadingAnimator()) { [weak self] in
                self?.reload()
            }
            
            let footer = NormalFooterAnimator()
            footer.loadingMoreDescription = "上拉加载更多"
            footer.noMoreDataDescription = "已加载全部"
            footer.loadingDescription = "加载中..."
            
            collectionView.cr.addFootRefresh(animator: footer) { [weak self] in
                self?.loadMore()
            }
            //reload()
        }
        
        collectionView.cr.beginHeaderRefresh()
    }
    
    func bottomHeight() -> CGFloat {
        var hasLiuHai: Bool = false
        let window = UIApplication.shared.windows.first
        hasLiuHai = window?.safeAreaInsets.bottom ?? 0 > 0
        return hasLiuHai ? 34.0 : 0.0
    }
    
    deinit {
        collectionView.cr.removeHeader()
        if !self.isBing {
            collectionView.cr.removeFooter()
        }
    }
    
    @objc func reload() {
        self.page = 0
        self.isHeader = true
        self.sendRequest()
    }
    
    @objc func loadMore() {
        self.page += 1
        self.isHeader = false
        self.sendRequest()
    }
    
    @objc func appendMoreData(lantern: Lantern) {
        self.page += 1
        self.isHeader = false
        self.sendRequest {
            lantern.reloadData()
        }
    }
    
    func sendRequest(successBlock: (() -> Void)? = nil) {
        
        var urlString: String = ""
        urlString += "?client=" + client
        urlString += "&source=" + source
        urlString += "&page=" + "\(page)"
        urlString += "&color=" + color
        urlString += "&tag=" + tag
        urlString += "&order=" + order
        
        let api = Api.wallpaperList + urlString
        
        RequestTool.request(url: api, httpMethod: .get) { success in
            if let model = JSONDeserializer<WallpaperListModel>.deserializeFrom(json: success.description) {
                if model.code == 0 {
                    
                    if self.page == 0 {
                        self.wallpapers.removeAll()
                    }
                    
                    self.wallpapers.append(contentsOf: model.data.list)
                    
                    self.total = model.data.count
                    
                    if self.isHeader {
                        self.collectionView.cr.endHeaderRefresh()
                        self.collectionView.cr.resetNoMore()
                    } else {
                        self.collectionView.cr.endLoadingMore()
                        if self.wallpapers.count == model.data.count {
                            self.collectionView.cr.noticeNoMoreData()
                        }
                    }
                    self.collectionView.reloadData()
                    if let suc = successBlock {
                        suc()
                    }
                }
            }
        } error: { _ in
            self.collectionView.cr.endHeaderRefresh()
            self.collectionView.cr.endLoadingMore()
            self.collectionView.cr.resetNoMore()
        }
    }
    
    func getBing() {
        RequestTool.request(url: Api.Bing, httpMethod: .get) { success in
            if let model = JSONDeserializer<WallpaperBingModel>.deserializeFrom(json: success.description) {
                if model.code == 0 {
                    self.wallpapers.removeAll()
                    self.wallpapers.append(model.data)
                    self.collectionView.reloadData()
                }
            }
        } complete: {
            self.collectionView.cr.endHeaderRefresh()
        }
    }
    
    func setupAndStartScaleAnimation() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values =  [1.0, 1.2]
        animation.duration = 20
        animation.repeatCount = .infinity
        animation.calculationMode = .cubic
        animation.autoreverses = true
        animation.isRemovedOnCompletion = false
        self.collectionView.layer.add(animation, forKey: "zooming")
    }
    
}

extension WallpaperListController: WaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-16*3)/2.0
        let imageSize = wallpapers[indexPath.item].imageSize
        let scale = imageSize.height * 1.0 /  imageSize.width
        return CGSize(width: width, height: width * scale)
    }

    func collectionViewLayout(for section: Int) -> WaterfallLayout.Layout {
        .waterfall(column: 2, distributionMethod: .balanced)
    }

}


extension WallpaperListController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.isBing {
            return
        }
        if scrollView.contentOffset.y > scrollView.frame.height {
            self.pageCountrl.isHidden = false
        } else {
            self.pageCountrl.isHidden = true
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.pageCountrl.transform = .identity
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            UIView.animate(withDuration: 0.25, delay: 0) {
                self.pageCountrl.transform = .init(translationX: 0, y: self.bottomHeight()+32)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.pageCountrl.transform = .init(translationX: 0, y: self.bottomHeight()+32)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageCountrl.setTitle("第\(indexPath.item+1)张，共\(self.total)", for: .normal)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WallpaperCell", for: indexPath) as? WallpaperCell {
            cell.listItem = wallpapers[indexPath.item]
            if !self.isBing {
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
            }
            cell.downBtn.addTarget(self, action: #selector(downImage(indexPath:)), for: .touchUpInside)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if self.isBing { return .zero }
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.isBing { return collectionView.frame.size}
        let width = (collectionView.frame.width-16*3)/2.0
        let imageSize = wallpapers[indexPath.item].imageSize
        let scale = imageSize.height * 1.0 /  imageSize.width
        return CGSize(width: width, height: width * scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if self.isBing { return 0 }
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if self.isBing { return 0 }
        return 16
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: currentIndexPath) as? WallpaperCell else { return nil }
        return .init(view: cell)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: currentIndexPath) as? WallpaperCell else { return nil }
        return .init(view: cell)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
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
            
            let like = UIAction(title: "喜欢 \(self.wallpapers[indexPath.item].like)") { _ in
                
            }
            like.attributes = .disabled
            
            let rate = UIAction(title: "评分 \(self.wallpapers[indexPath.item].rate)") { _ in
                
            }
            rate.attributes = .disabled
            
            let menu = UIMenu.init(children: [select,like,rate])
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.openLantern(with: collectionView, indexPath: indexPath)
    }
    
    //专业做大图预览，优点在于可push，可无限加载
    func openLantern(with collectionView: UICollectionView, indexPath: IndexPath) {
        self.addDownLoadButton()
        let lantern = Lantern()
        
        //不会随着cell滑动
        lantern.browserView.addSubview(self.downLoadButton)
        
        lantern.numberOfItems = {[weak self] in
            self?.wallpapers.count ?? 0
        }
        lantern.cellClassAtIndex = { _ in
            RawImageCell.self
        }
        lantern.reloadCellAtIndex = { context in
            guard let lanternCell = context.cell as? RawImageCell else {
                return
            }
            let indexPath = IndexPath(item: context.index, section: indexPath.section)
            let collectionCell = collectionView.cellForItem(at: indexPath) as? WallpaperCell
            let placeholder = collectionCell?.icon.image
            //smallSrc其实是空的，无效的，填充数据
            lanternCell.reloadData(placeholder: placeholder, rawURLString: self.wallpapers[indexPath.item].src?.rawSrc)
            
            lanternCell.rawButton.alpha = 0
            lanternCell.rawButton.isUserInteractionEnabled = false
            lanternCell.panGestureEndAction = {[weak self](cell, isEnd) in
                (cell as! RawImageCell).rawButton.isHidden = isEnd
                self?.downLoadButton.isHidden = isEnd
            }
            lanternCell.panGestureChangeAction = {[weak self](cell, scale) in
                (cell as! RawImageCell).rawButton.isHidden = scale < 0.99
                self?.downLoadButton.isHidden = scale < 0.99
            }
            
            // 添加长按事件
            lanternCell.longPressedAction = { cell, _ in
                //self.longPress(cell: cell)
            }
        }
        
//        lantern.transitionAnimator = LanternZoomAnimator(previousView: { index -> UIView? in
//            let path = IndexPath(item: index, section: indexPath.section)
//            let cell = collectionView.cellForItem(at: path) as? WallpaperCell
//            return cell?.icon
//        })
        
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
        
        
        // 使用自定义的转场动画
//        lantern.transitionAnimator = CustomAnimatedTranstioning(previousView: { index -> UIView? in
//            let path = IndexPath(item: index, section: indexPath.section)
//            let cell = collectionView.cellForItem(at: path) as? WallpaperCell
//            return cell?.icon
//        })
        
        lantern.didChangedPageIndex = { index in
            self.currentImg = index
            let indexP = IndexPath(item: index, section: indexPath.section)
            let layout = collectionView.layoutAttributesForItem(at: indexP)
            collectionView.scrollRectToVisible(layout!.frame, animated: false)
            
            // 已到最后一张
            if index == self.wallpapers.count - 1 {
                lantern.lastNumberOfItems = index
                self.loadMore()
                self.appendMoreData(lantern: lantern)
            }
        }
        
        lantern.pageIndicator = LanternNumberPageIndicator()
        lantern.pageIndex = indexPath.item
        lantern.show(method: .present(fromVC: nil, embed: nil))
        
        // 让lantern嵌入当前的导航控制器里
        //lantern.show(method: .push(inNC: nil)) //push的会使scrollRectToVisible无效
    }
    
    private func longPress(cell: LanternImageCell) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "查看更多", style: .destructive, handler: { _ in
            let detail = WallpaperController.fromStoryboard(.main)
            cell.lantern?.navigationController?.pushViewController(detail, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        cell.lantern?.present(alert, animated: true, completion: nil)
    }
    
    @objc func saveImgggAction() {
        if let src = wallpapers[self.currentImg].src, src.rawSrc.count > 0, let url = URL(string: src.rawSrc) {
            ImageDownloadTool.downloadNetworkImage(with: url, options: [.backgroundDecode], completionHandler:  { image in
                guard let img = image else { return }
                PhotoSaveTool.savePhotoWithImage(img)
            })
        }
    }
    
}


extension WallpaperListController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }

    func listDidAppear() {
//        if refreshControl?.isRefreshing == true {
//            refreshControl?.beginRefreshing()
//        }
    }

    func listDidDisappear() {

    }
}
