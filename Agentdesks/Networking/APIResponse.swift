//
//  APIResponse.swift
//  Agentdesks
//
//  Created by Ravi on 23/03/18.
//  Copyright © 2018 ThinkAnts. All rights reserved.
//

import Foundation
import ObjectMapper

struct APIResponse: Mappable {
    var status = [String: Any]()
    var statusCode = 0
    var error = ""
    var statusMessage = ""
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        statusCode <- map["status.statusCode"]
        error <- map["status.message"]
        statusMessage <- map["status"]
    }
    
}
