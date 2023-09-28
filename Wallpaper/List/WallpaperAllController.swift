//
//  WallpaperAllController.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/20.
//

import Foundation
import UIKit
import JXSegmentedView
import SnapKit

class WallpaperAllController: UIViewController {
    var segmentedDataSource: JXSegmentedTitleDataSource!
    var segmentedView: JXSegmentedView!
    var listContainerView: JXSegmentedListContainerView!
    @IBOutlet weak var targetView: UIView!
    @IBOutlet weak var targetHeight: NSLayoutConstraint!
    
    // MARK: Properties
    
    private lazy var titles: [String] = ["全部壁纸源",
                                         "Infinity风景",
                                         "Infinity动漫",
                                         "Bing",
                                         "Unsplash",
                                         "Life Of Pix",
                                         "MMT",
                                         "Realistic Shots",
                                         "Jay Mantri",
                                         "Free Nature Stock",
                                         "Skitter Photo",
                                         "Startup Stock Photos",
                                         "Barn Images",
                                         "Picography"]
    private lazy var source: [String] = ["",
                                         "InfinityLandscape",
                                         "Infinity",
                                         "bing",
                                         "Unsplash",
                                         "Life+Of+Pix",
                                         "MMT",
                                         "Realistic+Shots",
                                         "Jay+Mantri",
                                         "Free+Nature",
                                         "Skitter+Photo",
                                         "Startup+Stock+Photos",
                                         "Barn+Images",
                                         "Picography"]
    private lazy var tagNames: [String] = ["自然",
                                         "海洋",
                                         "建筑",
                                         "动物",
                                         "旅行",
                                         "美食",
                                         "动漫",
                                         "运动",
                                         "技术",
                                         "街头",
                                         "Bing每日"]
    private lazy var tags: [String] = ["nature",
                                         "ocean",
                                         "architecture",
                                         "animals",
                                         "travel",
                                         "food-drink",
                                         "anime",
                                         "athletics",
                                         "technology",
                                         "street-photography",
                                         "Bing"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        targetHeight.constant = 0
    
        navigationItem.title = "全球精选壁纸"
        view.backgroundColor = .white

        //1、初始化JXSegmentedView
        segmentedView = JXSegmentedView()

        //2、配置数据源
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedDataSource = JXSegmentedTitleDataSource()
        segmentedDataSource.titles = titles + tagNames
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titleNormalColor = UIColor.black.withAlphaComponent(0.4)
        segmentedDataSource.titleSelectedColor = UIColor.black
        segmentedDataSource.titleNormalFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        segmentedDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        segmentedDataSource.itemSpacing = 20
        segmentedView.dataSource = segmentedDataSource
        
        //3、配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        indicator.lineStyle = .normal
        indicator.indicatorCornerRadius = 1
        indicator.indicatorHeight = 2
        indicator.indicatorColor = UIColor.black
        indicator.verticalOffset = 8
        segmentedView.indicators = [indicator]

        //4、配置JXSegmentedView的属性
        view.addSubview(segmentedView)

        //5、初始化JXSegmentedListContainerView
        listContainerView = JXSegmentedListContainerView(dataSource: self, type: .collectionView)
        view.addSubview(listContainerView)

        //6、将listContainerView.scrollView和segmentedView.contentScrollView进行关联
        segmentedView.listContainer = listContainerView
        
        segmentedView.defaultSelectedIndex = 0
        segmentedView.delegate = self

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        segmentedView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(targetView.snp.bottom)
            make.height.equalTo(50)
        }
        listContainerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(segmentedView.snp.bottom).offset(0)
        }
    }
    
}

extension WallpaperAllController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return segmentedDataSource.dataSource.count
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let vc = WallpaperListController.fromStoryboard(.main)
        if index < source.count {
            vc.source = source[index]
        } else {
            vc.tag = tags[index-source.count]
        }
        return vc
    }
    
}

extension WallpaperAllController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
    }
}
