//
//  PagingTabView.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/7.
//

import UIKit

protocol PagingTabViewDelegate: AnyObject {
    
    func pagingTabView(_ pagingTabView: PagingTabView, didSelectItemAt index: Int)
}

protocol PagingTabViewDataSource: AnyObject {
    
    func numberOfItems() -> Int
    
    func pagingTabView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}

class PagingTabView: UIView {
    
    weak var delegate: PagingTabViewDelegate? = nil
    
    weak var dataSource: PagingTabViewDataSource? = nil
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 50, height: 38)
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let options: TabStyleOptions
    
    init(cellClass: AnyClass, reuseIdentifier: String, options: TabStyleOptions) {
        self.options = options
        super.init(frame: .zero)
        initCollectionView(cellClass: cellClass, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initCollectionView(cellClass: AnyClass, reuseIdentifier: String) {
        collectionView.backgroundColor = .red
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    private func setupUI() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func initIndicator(selectedIndex: Int) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? TabCollectionViewCell else { return }
        indicatorView.frame = CGRect(x: cell.frame.minX, y: cell.frame.height - options.indicatorHeight, width: cell.frame.width, height: options.indicatorHeight)
    }
    
    func updateIndicator(fromIndex: Int, toIndex: Int, progress: CGFloat, withAnimation: Bool = false) {
        guard let fromCell = collectionView.cellForItem(at: IndexPath(item: fromIndex, section: 0)) as? TabCollectionViewCell,
              let toCell = collectionView.cellForItem(at: IndexPath(item: toIndex, section: 0))as? TabCollectionViewCell else { return }
        let fromCellFrame = fromCell.frame
        let toCellFrame = toCell.frame
        let currentX = fromCellFrame.minX + (toCellFrame.minX - fromCellFrame.minX) * progress
        let currentWidth = fromCellFrame.width + (toCellFrame.width - fromCellFrame.width) * progress
        let duration: TimeInterval = withAnimation ? 0.2 : 0.0
        UIView.animate(withDuration: duration) { [weak self] in
            guard let self = self else { return }
            self.indicatorView.frame = CGRect(x: currentX, y: self.indicatorView.frame.minY, width: currentWidth, height: self.indicatorView.frame.height)
        }
    }
    
    func updateCell(fromIndex: Int, toIndex: Int, progress: CGFloat, withAnimation: Bool = false) {
        let toIndexPath = IndexPath(item: toIndex, section: 0)
        guard let fromCell = collectionView.cellForItem(at: IndexPath(item: fromIndex, section: 0)) as? TabCollectionViewCell,
              let toCell = collectionView.cellForItem(at: toIndexPath)as? TabCollectionViewCell else { return }
        let fromColor = UIColor.interpolate(from: options.selectedTextColor, to: options.textColor, progress: progress)
        let toColor = UIColor.interpolate(from: options.textColor, to: options.selectedTextColor, progress: progress)
        let duration: TimeInterval = withAnimation ? 0.2 : 0.0
        UIView.animate(withDuration: duration) {
            fromCell.setTextColor(color: fromColor)
            toCell.setTextColor(color: toColor)
        }
        
        collectionView.scrollToItem(at: toIndexPath, at: .centeredHorizontally, animated: true)
    }
}

extension PagingTabView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pagingTabView(self, didSelectItemAt: indexPath.row)
    }
}

extension PagingTabView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItems() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource?.pagingTabView(collectionView, cellForItemAt: indexPath) ?? UICollectionViewCell()
    }
}

extension PagingTabView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: options.leftSpacing, bottom: 0, right: options.rightSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return options.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return options.itemSpacing
    }

}
