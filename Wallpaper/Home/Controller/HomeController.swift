//
//  HomeController.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/19.
//

import Foundation
import UIKit
import SwiftyJSON
import HandyJSON
import Kingfisher
import SwiftyUserDefaults
import SafariServices
import ETNavBarTransparent

let WallpaperLastSetTimeStamp = "WallpaperLastSetTimeStamp"

class HomeController: UIViewController {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var lefttItem: UIBarButtonItem!
    @IBOutlet weak var rightItem: UIBarButtonItem!
    @IBOutlet weak var cacheSize: UILabel!
    
    @IBOutlet weak var webView: HomeCollectionView!
    private var webs = [WebsiteItem]()
    var dragingIndexPath: IndexPath?
    
    var firstLoad: Bool = true
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBarBgAlpha = 0
        self.doneBtn.transform = .init(translationX: 0, y: bottomHeight()+32)
        self.pageControl.transform = .init(scaleX: 0.85, y: 0.85)
        
        cacheConfig()
        setupAndStartScaleAnimation()
        addActions()
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1.5
        
        textField.setLeftPaddingPoints(16)
        //textField.setRightPaddingPoints(16)
        
        let layout = HomeCustomFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: webView.frame.width/4.0, height: webView.frame.height/2.0)
        self.webView.setCollectionViewLayout(layout, animated: false)
        
        homeWallpaper()
        self.webView.register(UINib(nibName: "HomeWebCell", bundle: nil), forCellWithReuseIdentifier: "HomeWebCell")
        self.websReload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.firstLoad {
            self.websReload()
        }
    }
    
    func websReload() {
        self.webs = HomeCollectionWebs.shared.webs
        self.webView.reloadData()
        self.firstLoad = false
    }
    
    func cacheConfig() {
        //无上限，不过期
        KingfisherManager.shared.cache.diskStorage.config.sizeLimit = 0
        KingfisherManager.shared.cache.diskStorage.config.expiration = .never
    }
    
    func homeWallpaper() {
        
        var time: Double  = 24 * 60 * 60
        
        switch Defaults.wallpaperChange {
        case 0:
            time = 1 * 60 * 60
        case 1:
            time = 3 * 60 * 60
        case 2:
            time = 6 * 60 * 60
        case 3:
            time = 24 * 60 * 60
        case 5:
            time = Double.greatestFiniteMagnitude
        default:
            time = 1 * 1 * 60
        }
        
        updateRightItem()
        
        let lastAppearTimeStamp = UserDefaults.standard.double(forKey: WallpaperLastSetTimeStamp)
        let currentTimeStamp = (Date().timeStamp as NSString).doubleValue
        
        if currentTimeStamp - lastAppearTimeStamp > time || Defaults.homeWallpaper.count == 0 {
            sendRequest()
        } else {
            self.icon.setImage(fromURL: Defaults.homeWallpaper, placeholder: UIImage(named: "launch_background"), forceTransition: true, keepCurrentImageWhileLoading: true)
        }
        
    }
    
    func updateRightItem() {
        if #available(iOS 15.0, *) {
            rightItem.action = nil
            var menus = [UIMenuElement]()
            let hour1 = UIAction(title: "每小时") { [weak self] _ in
                Defaults.wallpaperChange = 0
                self?.updateRightItem()
                self?.saveTime()
            }
            let hour2 = UIAction(title: "每3小时") { [weak self] _ in
                Defaults.wallpaperChange = 1
                self?.updateRightItem()
                self?.saveTime()
            }
            let hour3 = UIAction(title: "每6小时") { [weak self] _ in
                Defaults.wallpaperChange = 2
                self?.updateRightItem()
                self?.saveTime()
            }
            let hour4 = UIAction(title: "每天") { [weak self] _ in
                Defaults.wallpaperChange = 3
                self?.updateRightItem()
                self?.saveTime()
            }
            let hour5 = UIAction(title: "立即更换") { [weak self] _ in
                self?.sendRequest()
            }
            
            let hour8 = UIAction(title: "不自动更换") { [weak self] _ in
                Defaults.wallpaperChange = 5
                self?.updateRightItem()
                self?.saveTime()
            }
            
            let hour6 = UIAction(title: "更多精美壁纸") { [weak self] _ in
                self?.moreImages()
            }
            
            let hour7 = UIAction(title: "设置") { [weak self] _ in
                self?.settingAction()
            }
            
            menus.append(contentsOf: [hour1,hour2,hour3,hour4,hour5,hour8,hour6,hour7])
            
            (menus[Defaults.wallpaperChange] as! UIAction).state = .on
            let menu = UIMenu(title: "壁纸更换频率",children: menus)
            if #available(iOS 17.0, *) {
                menu.preferredElementSize = .automatic
            }
            rightItem.menu = menu
        } else {
            //不处理
        }
    }
    
    @IBAction func listAction(_ sender: UIBarButtonItem) {
        let vc = WallpaperAllController.fromStoryboard(.main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func moreAction(_ sender: UIBarButtonItem) {
        let vc = WallpaperController.fromStoryboard(.main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func sendRequest() {
        let api = Api.randomWallpaper + "?_=\(Date().milliStamp)"
        RequestTool.request(url: api, httpMethod: .get) { success in
            if let model = JSONDeserializer<WallpaperModel>.deserializeFrom(json: success.description) {
                if model.status == 200, model.data.count > 0 {
                    let item = model.data.first
                    self.icon.setImage(fromURL: item?.src?.rawSrc, placeholder: UIImage(named: "cm2_fm_bg.jpg_unsliced"), forceTransition: true, keepCurrentImageWhileLoading: true, completionHandler:  { result in
                        switch result {
                        case .success(_):
                            Defaults.homeWallpaper = item?.src?.rawSrc ?? ""
                            self.saveTime()
                        case .failure:
                            break
                        }
                    })
                }
            }
        }
    }
    
    func saveTime() {
        let current = (Date().timeStamp as NSString).doubleValue
        UserDefaults.standard.set(current, forKey: WallpaperLastSetTimeStamp)
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
        self.icon.layer.add(animation, forKey: "zooming")
    }
    
    func search(str: String?) {
        
        let customAllowedSet =  NSCharacterSet(charactersIn:" !#`^<>@[]|").inverted
        let urlString = str?.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        
        guard let urlStrings = urlString, urlStrings.count > 0 else {
            textField.sjc_shake()
            return
        }

        if Validate.URL(urlStrings).isRight {
            openWeb(urlStr: urlStrings)
        } else {
            openWeb(urlStr: "https://www.baidu.com/")
        }
        
    }
    
    func openWeb(urlStr: String) {
        var sourceUrl = urlStr.trimmingCharacters(in: .whitespaces)
        sourceUrl = sourceUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string: sourceUrl)!
        
        let webViewController = SFSafariViewController(url: url)
        webViewController.preferredControlTintColor = .systemGreen
        webViewController.modalPresentationStyle = .fullScreen
        webViewController.dismissButtonStyle = .close
        self.present(webViewController, animated: true)
    }
    
    func addActions() {
        let press = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        self.icon.addGestureRecognizer(press)
        self.icon.isUserInteractionEnabled = true
        
        let signleTap = UITapGestureRecognizer(target: self, action: #selector(tapActionTrue))
        self.icon.addGestureRecognizer(signleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(tapActiontWice(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.icon.addGestureRecognizer(doubleTap)

    }
    
    @objc private func onLongPress(_ press: UILongPressGestureRecognizer) {
        if press.state == .began {
            
            if self.webs.count > 0 {
                self.isWebEditing = true
            }
        }
    }
    
    @objc private func tapActiontWice(_ press: UITapGestureRecognizer) {
        guard self.icon.image != nil else { return }
        
        if self.icon.image == UIImage(named: "launch_background") {
            return
        }
        
        if UIMenuController.shared.isMenuVisible {
            UIMenuController.shared.hideMenu()
        } else {
            let point = press.location(in: press.view)
            
            becomeFirstResponder()
            let menu = UIMenuController.shared
            let copy = UIMenuItem(title: "保存此壁纸", action: #selector(saveActionTrue))
//                let more = UIMenuItem(title: "更多精美壁纸", action: #selector(moreImages))
//                let setting = UIMenuItem(title: "设置", action: #selector(settingAction))
            menu.menuItems = [copy]
            menu.showMenu(from: self.icon, rect: CGRect(origin: point, size: CGSize(width: 1, height: 1)))
        }
    }
    
    @objc private func tapActionTrue() {
        self.isWebEditing = false
    }
    
    @objc private func saveActionTrue() {
        PhotoSaveTool.savePhotoWithImage(self.icon.image!)
    }
    
    @objc private func moreImages() {
        self.moreAction(UIBarButtonItem())
    }
    
    @objc private func settingAction() {
        let vc = SettingController.fromStoryboard(.main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func websiteAction(_ sender: UIBarButtonItem) {
        let vc = WebsiteController.fromStoryboard(.main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func bottomHeight() -> CGFloat {
        var hasLiuHai: Bool = false
        let window = UIApplication.shared.windows.first
        hasLiuHai = window?.safeAreaInsets.bottom ?? 0 > 0
        return hasLiuHai ? 34.0 : 0.0
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        self.isWebEditing = false
    }
    
    var isWebEditing = false {
        didSet {
            if isWebEditing != oldValue {
                
                if isWebEditing {
                    UIView.animate(withDuration: 0.25, delay: 0) {
                        self.doneBtn.transform = .identity
                    }
                } else {
                    UIView.animate(withDuration: 0.25, delay: 0) {
                        self.doneBtn.transform = .init(translationX: 0, y: self.bottomHeight()+32)
                    }
                }
                self.webView.reloadData()
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if event?.subtype == .motionShake && self.webs.count > 0 {
            self.isWebEditing = true
        }
    }
    
}


extension HomeController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.search(str: textField.text)
        return true
    }
}


extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageControl.isHidden = webs.count < 9
        self.pageControl.alpha = 0.0
        if !self.pageControl.isHidden {
            self.pageControl.numberOfPages = Int(webs.count/8) + (webs.count%8 > 0 ? 1 : 0)
            self.hidePageControl()
        }
        return webs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeWebCell", for: indexPath) as? HomeWebCell {
            cell.item = webs[indexPath.item]
            cell.isEditing = isWebEditing
            cell.deleteBtn.isHidden = !isWebEditing
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //得遵循UICollectionViewDelegateFlowLayout，不然这里无效
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/4.0, height: collectionView.frame.height/2.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.isWebEditing {
            self.deleteAction(indexPath)
        } else {
            let item = self.webs[indexPath.item]
            openWeb(urlStr: item.url)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
    }
    
    @objc func deleteAction(_ indexPath: IndexPath) {
        self.webView.performBatchUpdates {
            self.webs.remove(at: indexPath.item)
            HomeCollectionWebs.shared.synchronizyWebs(self.webs)
            self.webView.deleteItems(at: [indexPath])
            if self.webs.count == 0 {
                self.isWebEditing = false
            }
        } completion: { _ in
            self.webView.reloadData()
        }

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let current: Float = Float(scrollView.contentOffset.x / scrollView.frame.size.width)
        self.pageControl.currentPage = lroundf(current)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hidePageControl), object: nil)
        self.showPageControl()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.perform(#selector(hidePageControl), with: nil, afterDelay: 0)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.perform(#selector(hidePageControl), with: nil, afterDelay: 0)
    }
    
    @objc func showPageControl() {
        self.pageControl.alpha = 1.0
    }
    
    @objc func hidePageControl() {
        UIView.animate(withDuration: 0.25, delay: 1.0) {
            self.pageControl.alpha = 0.0
        }
    }
}


extension HomeController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        true
    }

    ///处理首次拖动时，是否响应
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        if indexPath.item == 0 {
//            return []
//        }
        let item = NSString(string: "\(indexPath.item)")
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item //用IndexPath更简单
        dragingIndexPath = indexPath
        return [dragItem]
    }
    
    ///处理拖动放下后如何处理
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }
        switch coordinator.proposal.operation {
        case .move:
            let items = coordinator.items
            if let item = items.first, let sourceIndexPath = item.sourceIndexPath {
                //执行批量更新
                collectionView.performBatchUpdates({
                    let index = Int(item.dragItem.localObject as! String)!
                    let data = self.webs[index]
                    self.webs.remove(at: sourceIndexPath.item)
                    self.webs.insert(data, at: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                //将项目动画化到视图层次结构中的任意位置
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                HomeCollectionWebs.shared.synchronizyWebs(self.webs)
            }
            break
        case .copy:
            //执行批量更新
            collectionView.performBatchUpdates({
                var indexPaths = [IndexPath]()
                for (index, item) in coordinator.items.enumerated() {
                    let indexPath = IndexPath(row: destinationIndexPath.item + index, section: destinationIndexPath.section)
                    let index = Int(item.dragItem.localObject as! String)!
                    let data = self.webs[index]
                    self.webs.insert(data, at: indexPath.item)
                    indexPaths.append(indexPath)
                }
                collectionView.insertItems(at: indexPaths)
            })
            break
        default:
            return
        }
    }
    ///处理拖动过程中
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
//        if destinationIndexPath?.item == 0 {
//            return UICollectionViewDropProposal(operation: .forbidden)
//        }
        guard dragingIndexPath?.section == destinationIndexPath?.section else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        if session.localDragSession != nil {
            if collectionView.hasActiveDrag {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            } else {
                return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let cell = collectionView.cellForItem(at: indexPath) as! HomeWebCell
        let previewParameters = UIDragPreviewParameters()
        let path = UIBezierPath(roundedRect: cell.contentView.frame, cornerRadius: 12.0)
        previewParameters.visiblePath = path
        previewParameters.backgroundColor = UIColor.white.withAlphaComponent(0.4)//.clear
        return previewParameters
    }
}
