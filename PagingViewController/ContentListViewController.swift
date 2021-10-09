//
//  ContentListViewController.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/9.
//

import UIKit

class ContentListViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        return UITableView()
    }()
    
    let index: Int
    
    private let model = ContentModel()
    
    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
        setupUI()
    }
    
    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: ContentTableViewCell.reuseIdentifier())
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ContentListViewController: UITableViewDelegate {
    
}

extension ContentListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.reuseIdentifier(), for: indexPath) as? ContentTableViewCell,
              model.data.indices.contains(indexPath.row) else { return UITableViewCell() }
        let data = model.data[indexPath.row]
        cell.configure(titleText: data.name, imageName: data.imageName, contentText: data.description)
        return cell
    }
    
    
}
