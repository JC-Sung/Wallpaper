//
//  HomeFlowLayout.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/26.
//

import Foundation
import UIKit

//iOS UICollectionView 横向分页布局

class HomeCustomFlowLayout: UICollectionViewFlowLayout {
    // 一行中 cell的个数
    var itemCountPerRow: Int = 4
    // 一页显示多少行
    var rowCount: Int = 2
    
    var allAttributes = [UICollectionViewLayoutAttributes]()
    var sectionPageDictionary = Dictionary<String, Any>()
    
    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        allAttributes.removeAll()
        sectionPageDictionary.removeAll()
        
        let section = self.collectionView?.numberOfSections ?? 0
        
        for sectionIndex in 0 ..< section {
            let itemCount = self.collectionView?.numberOfItems(inSection: sectionIndex) ?? 0
            for item in 0 ..< itemCount {
                let indexPath = IndexPath(item: item, section: sectionIndex)
                let attributes = self.layoutAttributesForItem(at: indexPath)!
                self.allAttributes.append(attributes)
            }
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as! UICollectionViewLayoutAttributes
        self.updateItemLayoutAttributes(attributes)
        return attributes
    }
    
    func updateItemLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) {
        if attributes.representedElementKind != nil {
            return
        }
        
        let section = attributes.indexPath.section
        let itemIndex = attributes.indexPath.item
        let itemCount = self.collectionView?.numberOfItems(inSection: section) ?? 0
        let sectionInsets = self.evaluatedInsetForSectionAtIndex(section)
        var minimumInteritemSpacing = self.evaluatedMinimumInteritemSpacingForSectionAtIndex(section)
        var minimumLineSpacing = self.evaluatedMinimumLineSpacingForSectionAtIndex(section)
        let itemWidth = attributes.frame.size.width
        let itemHeight = attributes.frame.size.height
        let collectionViewWidth = self.collectionView?.frame.width ?? 0
        let collectionViewHeight = self.collectionView?.frame.height ?? 0
        var xItemCount = Int((collectionViewWidth - sectionInsets.left - sectionInsets.right)/itemWidth)
        if (CGFloat(xItemCount) * itemWidth + sectionInsets.left + sectionInsets.right + CGFloat(xItemCount - 1)*minimumInteritemSpacing) > collectionViewWidth
        {
            xItemCount -= 1
            if(xItemCount == 0)
            {
                xItemCount = 1
            }
        }
        if xItemCount > 1
        {
            minimumInteritemSpacing = (collectionViewWidth - sectionInsets.left - sectionInsets.right - CGFloat(xItemCount)*itemWidth)/CGFloat(xItemCount - 1)
        }
        

        var yItemCount = Int((collectionViewHeight - sectionInsets.top - sectionInsets.bottom)/itemHeight)
        if (CGFloat(yItemCount)*itemHeight + sectionInsets.top + sectionInsets.bottom) + CGFloat(yItemCount - 1)*minimumLineSpacing > collectionViewHeight
        {
            yItemCount -= 1
        }
        if yItemCount > 1
        {
            minimumLineSpacing = (collectionViewHeight - sectionInsets.top - sectionInsets.bottom - CGFloat(yItemCount)*itemHeight)/CGFloat(yItemCount - 1)
        }
        
        let eachPageItemCount: Int = (xItemCount * yItemCount)
        let currentPage: Int = Int(itemIndex/eachPageItemCount)
        let remain: Int = Int(itemIndex % xItemCount)
        
        var xCellOffset: CGFloat = 0
        if remain == 0
        {
            xCellOffset = CGFloat(remain) * itemWidth + sectionInsets.left
        }
        else
        {
            xCellOffset = CGFloat(remain) * itemWidth + CGFloat(remain)*minimumInteritemSpacing + sectionInsets.left
        }
        
        let merchant = Int((itemIndex - currentPage * eachPageItemCount)/xItemCount)
        var yCellOffset: CGFloat = 0
        if merchant == 0
        {
            yCellOffset = CGFloat(merchant) * itemHeight + sectionInsets.top
        }
        else
        {
            yCellOffset = CGFloat(merchant) * itemHeight + CGFloat(merchant)*minimumLineSpacing + sectionInsets.top
        }
        let eachSectionPageCount = itemCount % eachPageItemCount == 0 ? Int(itemCount / eachPageItemCount) : Int(itemCount / eachPageItemCount) + 1
        
        self.sectionPageDictionary["\(section)"] = eachSectionPageCount
        
        if self.scrollDirection == .horizontal
        {
            var allSectionPage: Int = 0
            
            for (_, value) in self.sectionPageDictionary {
                allSectionPage += value as! Int
            }
           
            let key = "\( self.sectionPageDictionary.keys.count-1)"
            
            allSectionPage -= self.sectionPageDictionary[key] as! Int
            xCellOffset += collectionViewWidth*CGFloat(allSectionPage + currentPage)
            
        }
        else
        {
            
            yCellOffset += CGFloat(section) * collectionViewHeight
        }
        attributes.frame = CGRect(x: xCellOffset, y: yCellOffset, width: itemWidth, height: itemHeight)
    }
    
    override var collectionViewContentSize: CGSize {
        var allSectionPage: Int = 0
        for (_, value) in self.sectionPageDictionary {
            allSectionPage += value as! Int
        }
        return CGSize(width: CGFloat(allSectionPage)*(self.collectionView?.frame.width ?? 0), height: self.collectionView?.contentSize.height ?? 0)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.allAttributes
    }
    
    func evaluatedMinimumInteritemSpacingForSectionAtIndex(_ sectionIndex: Int) -> CGFloat
    {
        if self.collectionView!.delegate != nil && self.collectionView!.delegate!.conforms(to: UICollectionViewDelegateFlowLayout.self) && self.collectionView!.delegate!.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:)))  {
            let flowLayoutDelegate = self.collectionView!.delegate as! UICollectionViewDelegateFlowLayout
            return flowLayoutDelegate.collectionView!(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAt: sectionIndex)
        }
        return self.minimumInteritemSpacing
    }

   func evaluatedMinimumLineSpacingForSectionAtIndex(_ sectionIndex: Int) -> CGFloat
    {
        if self.collectionView!.delegate != nil && self.collectionView!.delegate!.conforms(to: UICollectionViewDelegateFlowLayout.self) && self.collectionView!.delegate!.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:)))  {
            let flowLayoutDelegate = self.collectionView!.delegate as! UICollectionViewDelegateFlowLayout
            return flowLayoutDelegate.collectionView!(self.collectionView!, layout: self, minimumLineSpacingForSectionAt: sectionIndex)
        }
        return self.minimumLineSpacing
    }

    func evaluatedInsetForSectionAtIndex(_ sectionIndex: Int) -> UIEdgeInsets
    {
        if self.collectionView!.delegate != nil && self.collectionView!.delegate!.conforms(to: UICollectionViewDelegateFlowLayout.self) && self.collectionView!.delegate!.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:)))  {
            let flowLayoutDelegate = self.collectionView!.delegate as! UICollectionViewDelegateFlowLayout
            return flowLayoutDelegate.collectionView!(self.collectionView!, layout: self, insetForSectionAt: sectionIndex)
        }
        return self.sectionInset
    }
    
    
   
    
}



