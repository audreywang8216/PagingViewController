//
//  PagingContainerView.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/7.
//

import UIKit

protocol PagingContainerViewDelegate: AnyObject {
    func pagingContainerView(scrollViewDidScroll scrollView: UIScrollView)
    
    func pagingContainerView(_ scrollView: UIScrollView, willBeginDragging atIndex: Int)
    
    func pagingContainerView(willBeginDecelerating scrollView: UIScrollView)
    
    func pagingContainerView(didEndDecelerating index: Int)
    
    func pagingContainerView(didEndScrollingAnimation index: Int)
}

protocol PagingContainerViewDataSource: AnyObject {
    
    func numberOfItems() -> Int
    
    func pagingContainerView(cellContentView: UIView, cellForItemAt index: Int)
}

class PagingContainerView: UIView {
    
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isDirectionalLockEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    var panGestureRecognizer: UIPanGestureRecognizer {
        return collectionView.panGestureRecognizer
    }
    
    weak var delegate: PagingContainerViewDelegate? = nil
    
    weak var dataSource: PagingContainerViewDataSource? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCollectionView()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.reuseIdentifier())
    }
    
    private func setupUI() {
        collectionView.backgroundColor = .white
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setScrollingEnabled(_ isEnabled: Bool) {
        collectionView.isScrollEnabled = isEnabled
    }
    
    func selected(at index: Int) {
        collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
}

extension PagingContainerView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItems() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.reuseIdentifier(), for: indexPath)
        dataSource?.pagingContainerView(cellContentView: cell.contentView, cellForItemAt: indexPath.row)
        return cell
    }
}

extension PagingContainerView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: frame.height)
    }
    
}

extension PagingContainerView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / screenWidth)
        delegate?.pagingContainerView(scrollView, willBeginDragging: index)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.pagingContainerView(scrollViewDidScroll: scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.pagingContainerView(willBeginDecelerating: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int((scrollView.contentOffset.x / screenWidth).rounded())
        delegate?.pagingContainerView(didEndDecelerating: index)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = Int((scrollView.contentOffset.x / screenWidth).rounded())
        delegate?.pagingContainerView(didEndScrollingAnimation: index)
    }
    
}
