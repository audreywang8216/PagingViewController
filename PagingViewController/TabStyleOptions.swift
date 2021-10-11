//
//  TabStyleOptions.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/7.
//

import UIKit

struct TabStyleOptions {
    
    /// 頁籤高度
    var tabViewHeight: CGFloat = 38
    
    /// 最左邊間隔
    var leftSpacing: CGFloat = 16
    
    /// 最右邊間隔
    var rightSpacing: CGFloat = 16
    
    /// item之間的間隔
    var itemSpacing: CGFloat = 20
    
    /// item相對於頁籤高度的比例
    var itemHeightRatio: CGFloat = 1.0
    
    /// 頁籤背景顏色
    var tabViewBgColor: UIColor = .white
    
    /// item大小
    var itemSize: ItemSize = .selfSize
    
    /// item背景顏色
    var itemBgColor: UIColor = .white
    
    /// item選中的背景顏色
    var itemSelectedBgColor: UIColor = .white
    
    /// item邊界顏色
    var itemBorderColor: UIColor = .clear
    
    /// item選中的邊界顏色
    var itemSelectedBorderColor: UIColor = .clear
    
    /// 文字顏色
    var textColor: UIColor = .black
    
    /// 選擇的文字顏色
    var selectedTextColor: UIColor = .black
    
    /// 文字字體
    var textFont: UIFont = .systemFont(ofSize: 17)
    
    /// 選擇的文字字體
    var selectedTextFont: UIFont = .systemFont(ofSize: 17)
    
    /// 是否有指示器
    var hasIndicator: Bool = true
    
    /// 指示器高度
    var indicatorHeight: CGFloat = 4
    
    /// 指示器顏色
    var indicatorColor: UIColor = .red
    
    /// 指示器寬度相對於item的比例
    var indicatorWidthRatio: CGFloat = 1.0
    
    /// 頁籤view下是否有分隔線
    var hasSeparateLine: Bool = true
    
    /// 分隔線顏色
    var separateLineColor: UIColor = .lightGray
    
    /// 分隔線高度
    var separateLineHeight: CGFloat = 1.0
    
    // 滑動頁籤下與頁面之間的高度
    var fixViewHeight: CGFloat = 38
}

/// item大小
enum ItemSize {
    
    /// 固定寬度
    case fix(width: CGFloat)
    
    /// 平均分配螢幕寬度
    case average
    
    /// 自適應
    case selfSize
}
