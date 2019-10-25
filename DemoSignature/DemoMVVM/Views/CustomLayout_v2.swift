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
    private var originalWidth: CGFloat {
        return collectionView!.bounds.width - contentInsets.left - contentInsets.right
    }
    // width height scale
    private let bodyScale: CGFloat = 0.7
    
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
        let contentWidthWithoutIndent = originalWidth * bodyScale
        
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
                      y: columnYoffset, //+ firstItemHeight * 0.5,
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
        // calculate distance between the attribute.minY and scroll contents current offsets
        let itemDistanceY = attributes.center.y - height * 0.5 - offsetY
        // distance / height
        let positionY = itemDistanceY / height
        let contentView = collectionView.cellForItem(at: attributes.indexPath)
        
        // set to front
        attributes.zIndex = totalItemsInSection - attributes.indexPath.row
        
        /*printLog(logs: [
            "offsetY: \(offsetY)",
            "itemY: \(itemDistanceY)",
            "center.y: \(attributes.center.y)",
            "positionY: \(positionY)"
        ], title: "addParallaxAttributes at \(attributes.indexPath)")*/
        
        
        let startTransformPoint: CGFloat = 1.5
        
        guard offsetY != 0 else {
            if  positionY <= 0, attributes.indexPath.row == 0 { // 第一個item 在初始畫面完成時的狀態
                let scale = 1 / bodyScale
                contentView?.transform = CGAffineTransform(scaleX: scale, y: scale)
                
            } else {
                
                //let scaleCheck = abs(startTransformPoint - positionY)
                //var translateY_v3: CGFloat = (scaleCheck) * height
                
                let transY = height / (1 / bodyScale)
                contentView?.transform = CGAffineTransform(translationX: 0, y: transY).scaledBy(x: 1, y: 1)
            }
            
            return attributes
        }
        
        if positionY > startTransformPoint { // 不是第一個的時候
            let scale: CGFloat = 1
            
            contentView?.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: scale, y: scale)
            
        } else {
            let scaleCheck = abs(startTransformPoint - positionY)
            var scale: CGFloat = 0
            
            var translateY_v3: CGFloat = -(scaleCheck) * height
            
            // scale ok!
            if (scaleCheck + 1) > 1 / bodyScale { // : 1 / bodyScale 還原倍率貼齊螢幕寬
                scale = 1 / bodyScale
                
            } else {
                scale = scaleCheck + 1
            }
            
            if attributes.center.y - height * scale * 0.5 < -1.0 { // ok
                translateY_v3 = 0
            }
            
            /** animation translat will reverse 0.5 and scroll to top */
            //let translateY_v1 = height * (1 - positionY)
            //let translateY_v2 = -(height * abs(startTransformPoint - positionY)) // ok!
         
            contentView?.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: 0, y: translateY_v3)
            
        }
        
        return attributes
    }
    
}
