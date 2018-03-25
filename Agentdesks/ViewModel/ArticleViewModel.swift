//
//  ArticleViewModel.swift
//  Agentdesks
//
//  Created by Ravi on 24/03/18.
//  Copyright © 2018 ThinkAnts. All rights reserved.
//

import Foundation

struct ArticleViewModel {
    let articleTitle: String
    let articleDescription: String
    let articleImageUrl: String
    let articleUrlString: String
    
    init(article: Article) {
        articleImageUrl = article.imageUrl
        articleTitle = article.title
        articleDescription = article.description
        articleUrlString = article.url
    }
}
