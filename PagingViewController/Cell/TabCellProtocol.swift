//
//  TabCellProtocol.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/11.
//

import UIKit

protocol TabCellProtocol: UICollectionViewCell {
    
    func setTextStyle(backgroundColor: UIColor, borderColor: UIColor, textColor: UIColor, font: UIFont)
    
    func configure(text: String, options: TabStyleOptions, isItemSelected: Bool)
}
