//
//  ArticlesTableViewCell.swift
//  Agentdesks
//
//  Created by Ravi on 23/03/18.
//  Copyright © 2018 ThinkAnts. All rights reserved.
//

import UIKit

class ArticlesTableViewCell: UITableViewCell {

    @IBOutlet weak var articlesImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
    
    let defaultImage = UIImage(named: "agentDesk")
    var closure: (()->())? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(ArticlesTableViewCell.tapFunction))
        urlLabel.addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        articlesImageView.image = defaultImage
        closure = nil
    }
    
    func configure(_ viewModel: ArticleViewModel) {
        titleLabel.text = viewModel.articleTitle
        if viewModel.articleDescription == "" {
            descriptionHeightConstraint.constant = 0
        } else {
            descriptionHeightConstraint.constant = 36
            descriptionLabel.text = viewModel.articleDescription
        }
        urlLabel.text = viewModel.articleUrlString
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        closure?()
    }
}
