//
//  Articles.swift
//  Agentdesks
//
//  Created by Ravi on 23/03/18.
//  Copyright © 2018 ThinkAnts. All rights reserved.
//

import Foundation
import ObjectMapper

struct Articles: Mappable {
    var articles = [Article]()

    init?(map: Map) {
    }

    init() {
    }
    
    mutating func mapping(map: Map) {
        articles <- map["articles"]
    }
}

struct Article: Mappable {
    var author = ""
    var title = ""
    var description = ""
    var url = ""
    var imageUrl = ""
    var publishedAt = ""
    var source = Source()

    init?(map: Map) {
    }

    init() {
    }
    
    mutating func mapping(map: Map) {
        author <- map["author"]
        title <- map["title"]
        description <- map["description"]
        url <- map["url"]
        imageUrl <- map["urlToImage"]
        publishedAt <- map["publishedAt"]
        source <- map["source"]
    }
}

struct Source: Mappable {
    var sourceId = ""
    var name = ""
    
    init?(map: Map) {
    }
    
    init() {
    }
    
    mutating func mapping(map: Map) {
        sourceId <- map["id"]
        name <- map["name"]
    }
}

