//
//  WebsiteController.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/25.
//

import Foundation
import UIKit
import CRRefresh
import HandyJSON
import ETNavBarTransparent
import SwiftyJSON
import SafariServices
import Alamofire
import SwiftyUserDefaults

class WebsiteController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var rightItem: UIBarButtonItem!
    var lang: String = "zh-CN"
    var type: String = ""//popular
    var source: String = ""//shareByUser
    var keyword: String = ""
    
    var request: DataRequest?

    //起始页码
    var page: Int = 0
    
    var total: Int = 0
    
    var isHeader: Bool = true
    
    var websites = [WebsiteItem]()
    var types = [WebsiteTypeItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "网址导航"
        self.navBarBgAlpha = 0
        searchView.layer.cornerRadius = 16
        searchView.layer.masksToBounds = true
        
        self.bigCell = Defaults.bigCell
        
        tableView.roundCornersWithSpecificCorners(.topRight, radius: 8)
        //collectionView.roundCornersWithSpecificCorners([.topLeft, .topRight], radius: 10)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        tableView.register(UINib(nibName: "WebsiteTabViewCell", bundle: nil), forCellReuseIdentifier: "WebsiteTabViewCell")
        collectionView.register(UINib(nibName: "WebsiteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WebsiteCollectionViewCell")
        collectionView.register(UINib(nibName: "HomeWebCell", bundle: nil), forCellWithReuseIdentifier: "HomeWebCell")
        
        tableView.keyboardDismissMode = .onDrag
        collectionView.keyboardDismissMode = .onDrag
        
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
        creatTypes()
        
    }
    
    deinit {
        collectionView.cr.removeHeader()
        collectionView.cr.removeFooter()
    }
    
    
    @IBAction func switchAction(_ sender: UIBarButtonItem) {
        self.bigCell = !self.bigCell
        Defaults.bigCell = self.bigCell
        collectionView.reloadData()
    }
    
    var bigCell: Bool = true {
        didSet {
            self.rightItem.image = UIImage(systemName: bigCell ? "rectangle.grid.2x2" : "rectangle.grid.1x2")
        }
    }
    
    
    func creatTypes() {
        let path = Bundle.main.path(forResource: "websitetype_data", ofType: "json")!
        let testData = NSData(contentsOfFile: path)
        let json = try! JSON(data: testData! as Data)

        let model = JSONDeserializer<WebsiteTypeModel>.deserializeFrom(json: json.description)!
        self.types = model.types
        self.currentIndex = 0
    }
    
    var currentIndex: Int = -1 {
        didSet {
            if currentIndex != oldValue {
                
                for (index, _) in self.types.enumerated() {
                    self.types[index].isSecleted = index == currentIndex
                }
                
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: currentIndex, section: 0), at: .middle, animated: true)
                
                let item = self.types[currentIndex]
                self.type = item.type
                self.source = item.source
                self.collectionView.cr.beginHeaderRefresh()
            }
        }
    }
    
    var searchContent: String = "" {
        didSet {
            if searchContent != oldValue {
                self.keyword = searchContent
                self.reload()
            }
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
    
    func sendRequest(successBlock: (() -> Void)? = nil) {
        
        var urlString: String = ""
        
        if self.searchContent.count > 0 {
            urlString += "?lang=" + lang
            urlString += "&type=" + "search"
            urlString += "&keyword=" + keyword
            urlString += "&page=" + "\(page)"
        } else {
            urlString += "?lang=" + lang
            urlString += "&type=" + type
            urlString += "&source=" + source
            urlString += "&page=" + "\(page)"
        }
        
        let api = Api.websiteList + urlString
        
        if let req = request, self.page == 0 {
            req.cancel()
        }
        
        let request = RequestTool.request(url: api, httpMethod: .get) { success in
            if let model = JSONDeserializer<WebsiteModel>.deserializeFrom(json: success.description) {
                if model.success {
                    if self.page == 0 {
                        self.websites.removeAll()
                    }
                    
                    self.websites.append(contentsOf: model.icons)
                    
                    self.total = model.count
                    
                    if self.isHeader {
                        self.collectionView.cr.endHeaderRefresh()
                        self.collectionView.cr.resetNoMore()
                    } else {
                        self.collectionView.cr.endLoadingMore()
                        if self.websites.count == model.count {
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
        
        self.request = request
    }
    
}

extension WebsiteController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.search(str: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.search(str: textField.text)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        self.search(str: textField.text)
        return false //避免输入框再次成为第一响应者
    }
    
    func search(str: String?) {
        let customAllowedSet =  NSCharacterSet(charactersIn:" !#`^<>@[]|").inverted
        let ss = str?.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        self.searchContent = ss ?? ""
    }
}

extension WebsiteController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.types.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WebsiteTabViewCell", for: indexPath) as? WebsiteTabViewCell {
            cell.item = self.types[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentIndex = indexPath.row
    }
    
}


extension WebsiteController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.websites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if bigCell {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WebsiteCollectionViewCell", for: indexPath) as? WebsiteCollectionViewCell {
                cell.item = self.websites[indexPath.item]
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeWebCell", for: indexPath) as? HomeWebCell {
                cell.item = self.websites[indexPath.item]
                cell.name.textColor = .black
                cell.deleteBtn.isHidden = false
                cell.deleteBtn.isUserInteractionEnabled = true
                cell.deleteBtn.tag = indexPath.item
                cell.deleteBtn.touchAreaInsets = UIEdgeInsets(top: 16, left: 8, bottom: 8, right: 16)
                cell.deleteBtn.setImage(UIImage(named: "addicon_channel_12x12_"), for: .normal)
                cell.deleteBtn.addTarget(self, action: #selector(addToHome(_:)), for: .touchUpInside)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    @objc func addToHome(_ sender: UIButton) {
        let data = self.websites[sender.tag]
        HomeCollectionWebs.shared.addWeb(web: data)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if bigCell {
            let width = collectionView.frame.width
            let textHeight = self.websites[indexPath.item].description.height(withConstrainedWidth: width - 16*4, font: UIFont.systemFont(ofSize: 13, weight: .regular)) + 60+16+16+16 + 20+8
            return CGSize(width: width, height: textHeight)
        } else {
            let width = collectionView.frame.width/3.0
            let height = 90.0
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.websites[indexPath.item]
        openWeb(urlStr: item.url)
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
}
