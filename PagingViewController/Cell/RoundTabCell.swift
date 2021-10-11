//
//  RoundTabCell.swift
//  PagingViewController
//
//  Created by Tienyun Wang on 2021/10/11.
//

import UIKit

class RoundTabCell: UICollectionViewCell, TabCellProtocol {
    
    private let redDotWidth: CGFloat = 8
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.933, green: 0.933, blue: 0.933, alpha: 1)
        return view
    }()
    
    private lazy var redDot: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = .black
        label.sizeToFit()
        return label
    }()
    
    private var contentViewHeightConstraint = NSLayoutConstraint()
    
    private var bgViewHeightConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.layer.borderWidth = 1
        
        bgView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bgView.addSubview(redDot)
        redDot.translatesAutoresizingMaskIntoConstraints = false
        redDot.layer.cornerRadius = redDotWidth / 2
        
        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 40)
        bgViewHeightConstraint = bgView.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([
            contentViewHeightConstraint,
            
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bgView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bgViewHeightConstraint,
            
            titleLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            titleLabel.heightAnchor.constraint(equalTo: bgView.heightAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -12),
            
            redDot.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            redDot.topAnchor.constraint(equalTo: bgView.topAnchor),
            redDot.widthAnchor.constraint(equalToConstant: redDotWidth),
            redDot.heightAnchor.constraint(equalTo: redDot.widthAnchor)
        ])
    }
    
    func setTextStyle(backgroundColor: UIColor, borderColor: UIColor, textColor: UIColor, font: UIFont) {
        bgView.backgroundColor = backgroundColor
        bgView.layer.borderColor = borderColor.cgColor
        titleLabel.textColor = textColor
        titleLabel.font = font
    }
    
    func configure(text: String, options: TabStyleOptions, isItemSelected: Bool) {
        titleLabel.text = text
        setItemColor(isItemSelected: isItemSelected, options: options)
        let bgHeight = options.tabViewHeight * options.itemHeightRatio
        contentViewHeightConstraint.constant = options.tabViewHeight
        bgViewHeightConstraint.constant = bgHeight
        bgView.layer.cornerRadius = bgHeight / 2.0
    }
    
    func setRedDot(isShow: Bool) {
        redDot.isHidden = !isShow
    }
    
    private func setItemColor(isItemSelected: Bool, options: TabStyleOptions) {
        if isItemSelected {
            bgView.backgroundColor = options.itemSelectedBgColor
            bgView.layer.borderColor = options.itemSelectedBorderColor.cgColor
            titleLabel.textColor = options.selectedTextColor
            titleLabel.font = options.selectedTextFont
        } else {
            bgView.backgroundColor = options.itemBgColor
            bgView.layer.borderColor = options.itemBorderColor.cgColor
            titleLabel.textColor = options.textColor
            titleLabel.font = options.textFont
        }
    }
    
}
