//
//  HeaderPagingViewController.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/10.
//

import UIKit

class HeaderPagingViewController: UIViewController {
    
    /// 螢幕寬
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    /// Header高度
    private let headerViewHeight: CGFloat = 200
    
    /// 底層tableView的Header
    private lazy var tableHeaderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerViewHeight))
        let imageView = UIImageView(image: UIImage(named: "1"))
        view.addSubview(imageView)
        imageView.frame = view.frame
        return view
    }()
    
    /// 底層tableView
    private lazy var mainTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: tableViewStyle)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    /// 跟隨頁籤滑動的containerView
    private lazy var containerView: PagingContainerView = {
        return PagingContainerView()
    }()
    
    /// 頁籤名稱列表
    private var tabListName: [String] {
        return subViewController.map { $0.title ?? ""}
    }
    
    /// 頁籤view
    private let tabView: PagingTabView
    
    /// 頁籤樣式
    private var options: TabStyleOptions {
        return tabView.options
    }
    
    /// 子ViewController列表
    private let subViewController: [PagingContainerListProtocol]
    
    /// 頁籤在Header消失時是否固定在最頂端
    private let isTabViewPinned: Bool
    
    /// Header顯示/消失的臨界值
    private var criticalHeight: CGFloat {
        if isTabViewPinned {
            return headerViewHeight
        }
        return headerViewHeight + options.tabViewHeight
    }
    
    /// 底層TableView的樣式
    private var tableViewStyle: UITableView.Style {
        if isTabViewPinned {
            return .plain
        }
        return .grouped
    }
    
    private let contentOffsetKeyPath = "contentOffset"
    
    /// 當前選擇index
    private var selectedIndex: Int = 0
    
    /// 滑動中的列表
    private var listTableView: UIScrollView? = nil
    
    /// 底層TableView是否可以滑動
    private var isMainScrollingEnabled: Bool = true
    
    // MARK: - 頁籤切換過程參數
    
    /// 滑動前index
    private var fromIndex: Int? = nil
    
    /// 滑動後index
    private var targetIndex: Int = 0
    
    /// 點擊頁籤index
    private var tapIndex: Int? = nil
    
    /// 滑動初始x位置
    private var startContentOffsetX: CGFloat? = nil
    
    /// 滑動是否停止
    private var isScrollingEnd: Bool = true
    
    /// 滑動快結束是否設定VC的AppearanceTransition
    private var hasSetAppearanceTransition: Bool = false
    
    // MARK: - life cycle
    
    init(subViewController: [PagingContainerListProtocol], pagingTabView: PagingTabView, isTabViewPinned: Bool) {
        self.tabView = pagingTabView
        self.isTabViewPinned = isTabViewPinned
        self.subViewController = subViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegateAndDataScource()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTabViewInitStatus()
    }
    
    /// 防止在加入subViewController的時候就觸發viewWillAppear
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    // MARK: - 設定UI
    
    /// 設定底層MainTableView
    private func setDelegateAndDataScource() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier())
        mainTableView.separatorStyle = .none
        mainTableView.tableHeaderView = tableHeaderView
        mainTableView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: [.new], context: nil)
        
        tabView.dataSource = self
        tabView.delegate = self
        containerView.dataSource = self
        containerView.delegate = self
        subViewController.forEach{ $0.delegate = self }
    }
    
    /// 設定UI
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(mainTableView)
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    /// 設定指示器跟頁籤初始位置跟樣式
    private func setTabViewInitStatus() {
        tabView.configure(selectedIndex: selectedIndex)
        guard subViewController.indices.contains(selectedIndex) else { return }
        let vc = subViewController[selectedIndex]
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
    }
    
    /// 切換頁籤完畢重新設置index
    private func resetIndex() {
        fromIndex = nil
        tapIndex = nil
        startContentOffsetX = nil
        hasSetAppearanceTransition = false
    }
    
    /// 滑動停止要做的事情
    private func endScrollingHandler(toIndex: Int) {
        resetIndex()
        isScrollingEnd = true
        tabView.updateCell(fromIndex: selectedIndex, toIndex: toIndex, progress: 1.0)
        guard subViewController.indices.contains(toIndex),
              subViewController.indices.contains(selectedIndex),
              toIndex != selectedIndex else { return }
        let toVC = subViewController[toIndex]
        let fromVC = subViewController[selectedIndex]
        selectedIndex = toIndex
        // 呼叫fromVC的viewDidDisappear
        fromVC.endAppearanceTransition()
        // 呼叫toVC的viewDidAppear
        toVC.endAppearanceTransition()
    }
    
    /// 檢查點擊時的progress，設定progress超過0.5呼叫viewWillAppear
    private func checkProgressWhenTap(progress: CGFloat) {
        if progress > 0.5, hasSetAppearanceTransition == false {
            setSubViewControllerAppearance()
            hasSetAppearanceTransition = true
        }
    }
    
    // 滑動快要停止，設定fromVC的viewWillDisappear，targetVC的viewWillAppear
    private func setSubViewControllerAppearance() {
        guard subViewController.indices.contains(targetIndex),
              let fromIndex = fromIndex,
              subViewController.indices.contains(fromIndex) else { return }
        let fromVC = subViewController[fromIndex]
        let targetVC = subViewController[targetIndex]
        fromVC.beginAppearanceTransition(false, animated: false)
        targetVC.beginAppearanceTransition(true, animated: false)
    }
    
    /// 觀察mainTableView的contentOffset
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == contentOffsetKeyPath,
              let newOffset = change?[NSKeyValueChangeKey.newKey] as? CGPoint else { return }
        if newOffset.y < criticalHeight,
           isMainScrollingEnabled {
            listTableView?.contentOffset = .zero
        } else if newOffset.y >= criticalHeight {
            isMainScrollingEnabled = false
        }
    }
}

// MARK: - PagingTabViewDelegate (點擊頁籤)
extension HeaderPagingViewController: PagingTabViewDelegate {
    
    /// 點擊頁籤
    func pagingTabView(_ pagingTabView: PagingTabView, didSelectItemAt index: Int) {
        guard selectedIndex != index else { return }
        // 與當前所在頁籤不同才要動作
        tapIndex = index
        containerView.selected(at: index)
    }
}

// MARK: - PagingTabViewDataSource (頁籤的dataSource)
extension HeaderPagingViewController: PagingTabViewDataSource {
    
    func numberOfItems() -> Int {
        return subViewController.count
    }
    
    /// 指定頁籤的cell
    func pagingTabView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tabView.reuseIdentifier, for: indexPath) as? TabCellProtocol,
              tabListName.indices.contains(indexPath.row) else {
            return UICollectionViewCell()
        }
        let isSelected = indexPath.row == selectedIndex
        cell.configure(text: tabListName[indexPath.row], options: options, isItemSelected: isSelected)
        return cell
    }
    
}

// MARK: - PagingContainerViewDelegate (左右滑動頁面相關)
extension HeaderPagingViewController: PagingContainerViewDelegate {
    
    /// 滑動快要停止
    func pagingContainerView(willBeginDecelerating scrollView: UIScrollView) {
        setSubViewControllerAppearance()
    }
    
    /// 滑動Container停止
    func pagingContainerView(didEndDecelerating index: Int) {
        endScrollingHandler(toIndex: index)
    }
    
    /// 點擊頁籤停止
    func pagingContainerView(didEndScrollingAnimation index: Int) {
        endScrollingHandler(toIndex: index)
    }
    
    /// 滑動Container開始
    func pagingContainerView(_ scrollView: UIScrollView, willBeginDragging atIndex: Int) {
        if isScrollingEnd == false {
            // 滑動很快時，前一個滑動尚未停止就進行下一個
            fromIndex = Int((scrollView.contentOffset.x / screenWidth).rounded())
        } else {
            fromIndex = atIndex
        }
        isScrollingEnd = false
        startContentOffsetX = CGFloat(fromIndex ?? 0) * screenWidth
    }
    
    func pagingContainerView(scrollViewDidScroll scrollView: UIScrollView) {
        guard let fromIndex = fromIndex,
              let startContentOffsetX = startContentOffsetX else {
            /// 點擊頁籤開始
            fromIndex = Int((scrollView.contentOffset.x / screenWidth).rounded())
            startContentOffsetX = CGFloat(fromIndex ?? 0) * screenWidth
            return
        }
        
        // 滑動ContainerView設定targetIndex跟progress
        var progress: CGFloat
        if scrollView.contentOffset.x > startContentOffsetX {
            targetIndex = min(fromIndex + 1, tabListName.count - 1)
            progress = (scrollView.contentOffset.x - CGFloat(fromIndex) * screenWidth) / screenWidth
        } else {
            targetIndex = max(fromIndex - 1, 0)
            progress = -(scrollView.contentOffset.x - CGFloat(fromIndex) * screenWidth) / screenWidth
        }
        
        if let tapIndex = tapIndex {
            // 點擊頁籤設定targetIndex跟progress
            targetIndex = tapIndex
            let spacing = CGFloat(tapIndex - fromIndex) * screenWidth
            // 滑動前後index相同直接設定progress=0，否則分母會為0
            progress = (spacing == 0) ? 0 : (scrollView.contentOffset.x - CGFloat(fromIndex) * screenWidth) / spacing
            checkProgressWhenTap(progress: progress)
        } else {
            // 滑動ContainerView漸變頁籤顏色
            tabView.updateCell(fromIndex: fromIndex, toIndex: targetIndex, progress: progress)
        }
        tabView.updateIndicator(fromIndex: fromIndex, toIndex: targetIndex, progress: progress)
    }

}

// MARK: - PagingContainerViewDataSource (頁面的dataSource)
extension HeaderPagingViewController: PagingContainerViewDataSource {
    
    func pagingContainerView(cellContentView: UIView, cellForItemAt index: Int) {
        guard subViewController.indices.contains(index),
              cellContentView.subviews.count == 0 else { return }
        // 只有在第一次cellForItemAt加入ViewController
        let vc = subViewController[index]
        addChild(vc)
        cellContentView.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            vc.view.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor)
        ])
        vc.didMove(toParent: self)
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate (MainTableView相關)
extension HeaderPagingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier(), for: indexPath)
        cell.contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tabView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return options.tabViewHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height
    }
}

// MARK: - MainTableView的滑動
extension HeaderPagingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isMainScrollingEnabled {
            scrollView.contentOffset = CGPoint(x: 0, y: criticalHeight)
        }
    }
}

// MARK: - PagingContainerListDelegate(列表的滑動)
extension HeaderPagingViewController: PagingContainerListDelegate {
    
    func scrollViewDidScroll(_ listTableView: UITableView) {
        if !isMainScrollingEnabled {
            mainTableView.contentOffset = CGPoint(x: 0, y: criticalHeight)
        }
        if !isMainScrollingEnabled,
           listTableView.contentOffset.y <= 0 {
            isMainScrollingEnabled = true
        }
    }
    
    func willBeginDragging(_ listTableView: UITableView) {
        self.listTableView = listTableView
    }
    
    /// 當左右滑動切換頁面時不要觸發列表上下滑動
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == containerView.panGestureRecognizer {
            return false
        }
        return true
    }
    
}
