//
//  CustomLayout_v2.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/24.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class CustomLayout_v2: BaseCollectionViewFlowLayout {
 
    private var _itemSize: CGSize!
    private var firstItemHeight: CGFloat {//= 100// (200 * scale)
        return 200 * bodyScale
    }
    // width height scale
    private let bodyScale: CGFloat = 0.5
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.totalColumns = 1
    }
    
    override init() {
        super.init()
        self.totalColumns = 1
    }

    // MARK: - Override methods.
    override func calculateItemSize() {
        let contentWidthWithoutIndent = (collectionView!.bounds.width - contentInsets.left - contentInsets.right) * bodyScale
        
        _itemSize = CGSize(width: contentWidthWithoutIndent, height: firstItemHeight)
    }
    
    override func calculateItemFrame(indexPath: IndexPath, columnIndex: Int, columnYoffset: CGFloat) -> CGRect {
        
        /*let itemSizeAtIndex = itemHeigt(at: indexPath)
        let positionY = itemPositionY(at : indexPath, with: itemSizeAtIndex)
        let positionX = itemPositionX(with: itemSizeAtIndex)
        
        let rect = CGRect(x: positionX, y: positionY, width: itemSizeAtIndex.width, height: itemSizeAtIndex.height)
        
        printLog(logs: [
            "index: \(indexPath)",
            "rect: \(rect)",
            "columnYoffset: \(columnYoffset)"
        ], title: "calculateItemFrame")
        
        return rect*/
        
        return CGRect(x: (collectionView!.bounds.width - _itemSize.width) * 0.5,
                      y: columnYoffset + firstItemHeight * 0.5,
                      width: _itemSize.width,
                      height: _itemSize.height)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)?
            .compactMap { $0.copy() as? UICollectionViewLayoutAttributes }
            .compactMap(addParallaxAttributes(_:))
    }
    
    
    // MARK: - helpful method
    private func addParallaxAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = collectionView else { return attributes }
        
        let height = firstItemHeight
        let offsetY = collectionView.contentOffset.y
        let itemY = attributes.center.y - offsetY
        let positionY = (itemY - height * bodyScale) / height
        let contentView = collectionView.cellForItem(at: attributes.indexPath)
        
        /*printLog(logs: [
            "offsetY: \(offsetY)",
            "itemY: \(itemY)",
            "positionY: \(positionY)"
        ], title: "addParallaxAttributes at \(attributes.indexPath)")
        */
        
        if positionY > 1 { // 不是第一個的時候
            let scaleCheck = positionY - 1
            let scale: CGFloat = scaleCheck > 1 ? 0 : (1 - scaleCheck)
            let translate: CGFloat = scaleCheck > 1 ? height * (1 - scaleCheck) : 0
            
            // old y:  -(height * 0.25)
            contentView?.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1 + scale, y: 1 + scale)
            
        } else {
            let scaleCheck = 1 + positionY
            let scale = scaleCheck <= 1 / bodyScale ? scaleCheck : 1 / bodyScale
            
            /** animation translat will reverse 0.5 and scroll to top */
            let translateY_v1 = height * (1 - positionY)
            
            contentView?.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: 0, y: translateY_v1)
            
        }
        
        return attributes
        
    }
    
    /*private func itemHeigt(at indexPath: IndexPath) -> CGSize {
        var itemHeight = _itemSize.height * (1 - CGFloat(indexPath.item) / CGFloat(totalItemsInSection - 1))
        var itemWidth = _itemSize.width * (1 - CGFloat(indexPath.item) / CGFloat(totalItemsInSection - 1))
        
        if itemHeight < 100 {
            itemHeight = 100
        }
        
        if itemWidth < collectionView!.bounds.width * 0.6 {
            itemWidth = collectionView!.bounds.width * 0.6
        }
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    private func itemPositionY(at indexPath: IndexPath, with size: CGSize) -> CGFloat {
        let y = CGFloat(indexPath.item) * (firstItemHeight - size.height)
        
        return y
    }
    private func itemPositionX(with size: CGSize) -> CGFloat {
        
        return (_itemSize.width - size.width) * 0.5
    }*/
    
}
