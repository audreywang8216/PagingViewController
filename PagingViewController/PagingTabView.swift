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
    
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 50, height: options.tabViewHeight)
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
        view.backgroundColor = options.indicatorColor
        return view
    }()
    
    private lazy var separateLine: UIView = {
        let view = UIView()
        view.backgroundColor = options.separateLineColor
        return view
    }()
    
    let options: TabStyleOptions
    
    let reuseIdentifier: String
    
    private let cellClass: AnyClass
    
    init(cellClass: AnyClass, reuseIdentifier: String, options: TabStyleOptions) {
        self.cellClass = cellClass
        self.reuseIdentifier = reuseIdentifier
        self.options = options
        super.init(frame: .zero)
        initCollectionView(cellClass: cellClass, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initCollectionView(cellClass: AnyClass, reuseIdentifier: String) {
        collectionView.backgroundColor = options.tabViewBgColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    private func setupUI() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(separateLine)
        separateLine.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.addSubview(indicatorView)
        
        separateLine.isHidden = !options.hasSeparateLine
        indicatorView.isHidden = !options.hasIndicator
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separateLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            separateLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separateLine.heightAnchor.constraint(equalToConstant: options.separateLineHeight),
            separateLine.topAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func getItemSize() -> CGSize {
        switch options.itemSize {
        case .fix(let width):
            return CGSize(width: width, height: options.tabViewHeight)
        case .average:
            let count = dataSource?.numberOfItems() ?? 0
            let spaceCount = max(count - 1, 0)
            let totalWidth = screenWidth - options.leftSpacing - options.rightSpacing - options.itemSpacing * CGFloat(spaceCount)
            let width: CGFloat = (count == 0) ? 0 : totalWidth / CGFloat(count)
            return CGSize(width: width, height: options.tabViewHeight)
        case .selfSize:
            return layout.estimatedItemSize
        }
    }
    
    func configure(selectedIndex: Int) {
        initIndicator(selectedIndex: selectedIndex)
        updateCell(fromIndex: selectedIndex, toIndex: selectedIndex, progress: 1.0)
        collectionView.reloadData()
    }
    
    private func initIndicator(selectedIndex: Int) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) else { return }
        let indicatorWidth = options.indicatorWidthRatio * cell.frame.width
        let minX = cell.frame.minX + (cell.frame.width - indicatorWidth) / 2
        indicatorView.frame = CGRect(x: minX, y: cell.frame.height - options.indicatorHeight, width: indicatorWidth, height: options.indicatorHeight)
    }
    
    /// 更新指示器位置
    func updateIndicator(fromIndex: Int, toIndex: Int, progress: CGFloat, withAnimation: Bool = false) {
        guard let fromCell = collectionView.cellForItem(at: IndexPath(item: fromIndex, section: 0)),
              let toCell = collectionView.cellForItem(at: IndexPath(item: toIndex, section: 0)) else { return }
        let fromCellFrame = fromCell.frame
        let toCellFrame = toCell.frame
        let fromWidth = options.indicatorWidthRatio * fromCellFrame.width
        let fromMinX = fromCellFrame.minX + (fromCellFrame.width - fromWidth) / 2
        let toWidth = options.indicatorWidthRatio * toCellFrame.width
        let toMinX = toCellFrame.minX + (toCellFrame.width - toWidth) / 2
        let currentX = fromMinX + (toMinX - fromMinX) * progress
        let currentWidth = fromWidth + (toWidth - fromWidth) * progress
        let duration: TimeInterval = withAnimation ? 0.2 : 0.0
        UIView.animate(withDuration: duration) { [weak self] in
            guard let self = self else { return }
            self.indicatorView.frame = CGRect(x: currentX, y: self.indicatorView.frame.minY, width: currentWidth, height: self.indicatorView.frame.height)
        }
    }
    
    /// 更新cell顏色
    func updateCell(fromIndex: Int, toIndex: Int, progress: CGFloat, withAnimation: Bool = false) {
        let toIndexPath = IndexPath(item: toIndex, section: 0)
        guard let fromCell = collectionView.cellForItem(at: IndexPath(item: fromIndex, section: 0)) as? TabCellProtocol,
              let toCell = collectionView.cellForItem(at: toIndexPath)as? TabCellProtocol else { return }
        let fromColor = UIColor.interpolate(from: options.selectedTextColor, to: options.textColor, progress: progress)
        let toColor = UIColor.interpolate(from: options.textColor, to: options.selectedTextColor, progress: progress)
        let fromBgColor = UIColor.interpolate(from: options.itemSelectedBgColor, to: options.itemBgColor, progress: progress)
        let toBgColor = UIColor.interpolate(from: options.itemBgColor, to: options.itemSelectedBgColor, progress: progress)
        let fromBorderColor = UIColor.interpolate(from: options.itemSelectedBorderColor, to: options.itemBorderColor, progress: progress)
        let toBorderColor = UIColor.interpolate(from: options.itemBorderColor, to: options.itemSelectedBorderColor, progress: progress)
        let duration: TimeInterval = withAnimation ? 0.2 : 0.0
        UIView.animate(withDuration: duration) { [weak self] in
            guard let self = self else { return }
            fromCell.setTextStyle(backgroundColor: fromBgColor, borderColor: fromBorderColor, textColor: fromColor, font: self.options.textFont)
            toCell.setTextStyle(backgroundColor: toBgColor, borderColor: toBorderColor, textColor: toColor, font: self.options.selectedTextFont)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getItemSize()
    }
    
}
