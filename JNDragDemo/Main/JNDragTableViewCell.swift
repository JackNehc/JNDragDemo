//
//  JNDragTableViewCell.swift
//  JNDragDemo
//
//  Created by Jack on 2025/4/15.
//

import UIKit

class JNDragTableViewCell: UITableViewCell {
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRectMake(10, 10, 40, 40))
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRectMake(60, 10, UIScreen.main.bounds.width - 200, 40))
        return titleLabel
    }()
    
    lazy var dragImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRectMake(UIScreen.main.bounds.size.width - 50, 10, 40, 40))
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initUI() {
        self.contentView.addSubview(self.iconImageView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.dragImageView)
    }
    
    func updataData(title: String = "") {
        self.titleLabel.text = title
    }
}
