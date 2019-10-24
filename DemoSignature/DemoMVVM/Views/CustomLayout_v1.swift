//
//  CustomLayout_v1.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/24.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

private let kReducedHeightColumnIndex = 1
private let kItemHeightAspect: CGFloat = 2

class CustomLayout_v1: BaseCollectionViewFlowLayout {
    
    private var _itemSize: CGSize!
    private var columnsXoffset: [CGFloat]!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.totalColumns = 3
    }
    
    override init() {
        super.init()
        self.totalColumns = 3
        
    }
    
    private func isLastItemSingleInRow(_ indexPath: IndexPath) -> Bool {
        return (indexPath.item == totalItemsInSection - 1) && (indexPath.item % totalColumns == 0)
    }
    
    override func calculateItemSize() {
        let contentWidthWithoutIndent = collectionView!.bounds.width - contentInsets.left - contentInsets.right
        let itemWidth = (contentWidthWithoutIndent - (CGFloat(totalColumns) - 1) * interItemSpacing) / CGFloat(totalColumns)
        let itemHeight = itemWidth * kItemHeightAspect
        
        _itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        columnsXoffset = []
        
        for columnIndex in 0 ... totalColumns - 1 {
            columnsXoffset.append(CGFloat(columnIndex) * (itemWidth + interItemSpacing))
        }
        
    }
    
    override func columnIndexForItemAt(indexPath: IndexPath) -> Int {
        let columnIndex = indexPath.row % totalColumns
        // if is last item single move its index to kReducedHeightColumnIndex
        return isLastItemSingleInRow(indexPath) ? kReducedHeightColumnIndex : columnIndex
        
    }
    
    override func calculateItemFrame(indexPath: IndexPath, columnIndex: Int, columnYoffset: CGFloat) -> CGRect {
        let rowIndex = indexPath.item / totalColumns
        let halfItemHeight = (_itemSize.height - interItemSpacing) * 0.5
        
        var itemHeight = _itemSize.height
        
        if (rowIndex == 0 && columnIndex == kReducedHeightColumnIndex) || isLastItemSingleInRow(indexPath) {
            itemHeight = halfItemHeight
        }
        
        return CGRect(x: columnsXoffset[columnIndex], y: columnYoffset, width: _itemSize.width, height: itemHeight)
    }
}
