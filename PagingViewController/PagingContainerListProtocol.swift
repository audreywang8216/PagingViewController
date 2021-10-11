//
//  PagingContainerListProtocol.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/9.
//

import UIKit

protocol PagingContainerListDelegate: AnyObject {
    
    func scrollViewDidScroll(_ listTableView: UITableView)
    
    func willBeginDragging(_ listTableView: UITableView)
    
    func didEndScrolling(_ listTableView: UITableView)
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

extension PagingContainerListDelegate {
    
    func willBeginDragging(_ listTableView: UITableView) {}
    
    func didEndScrolling(_ listTableView: UITableView) {}
    
}

protocol PagingContainerListProtocol: UIViewController {
    
    var delegate: PagingContainerListDelegate? { get set }
    
    var tableView: TableView { get }
    
}
