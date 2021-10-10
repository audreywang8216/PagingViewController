//
//  UITableViewExtension.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/9.
//

import UIKit

protocol TableViewGestureRecognizerDelegate: AnyObject {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    
}

class TableView: UITableView, UIGestureRecognizerDelegate {
    
    weak var gestureDelegate: TableViewGestureRecognizerDelegate? = nil
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureDelegate = gestureDelegate {
            return gestureDelegate.gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer)
        }
        return true
    }
}
