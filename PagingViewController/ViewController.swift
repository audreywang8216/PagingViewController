//
//  ViewController.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/7.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var tabNameList: [String] = ["ETF", "投資快訊", "保險", "基金", "投資", "股市"]
    
    private lazy var subViewController: [PagingContainerListProtocol] = {
        var list: [PagingContainerListProtocol] = []
        for (index, tab) in tabNameList.enumerated() {
            let vc = ContentListViewController(index: index)
            vc.title = tab
            list.append(vc)
        }
        return list
    }()
    
    private lazy var headerPagingVC: HeaderPagingViewController = {
        return HeaderPagingViewController(subViewController: subViewController, isTabViewPinned: true)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        addChild(headerPagingVC)
        view.addSubview(headerPagingVC.view)
        headerPagingVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerPagingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerPagingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerPagingVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerPagingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        headerPagingVC.didMove(toParent: self)
    }
}

