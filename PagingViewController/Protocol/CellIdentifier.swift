//
//  CellIdentifier.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/7.
//

import UIKit

protocol CellIdentifier {}

extension CellIdentifier {
    static func reuseIdentifier() -> String {
        return String(describing: self)
    }
}

extension UITableViewCell: CellIdentifier {}
extension UITableViewHeaderFooterView: CellIdentifier {}
extension UICollectionViewCell: CellIdentifier {}
extension UICollectionReusableView: CellIdentifier {}
