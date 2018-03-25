//
//  ArticlesAPI.swift
//  Agentdesks
//
//  Created by Ravi on 23/03/18.
//  Copyright © 2018 ThinkAnts. All rights reserved.
//

import Foundation
import Moya

var pageCount = ""
var pageSize = ""
enum ArticlesAPI {
    case getArticlesList(count: String, pageSize: String)
}

extension ArticlesAPI: TargetType {

    var baseURL: URL {
        var urlComponents = URLComponents(string: appBaseURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "category", value: AppConstants.category),
            URLQueryItem(name: "apiKey", value: AppConstants.apiKey),
            URLQueryItem(name: "pageSize", value: pageSize),
            URLQueryItem(name: "page", value: pageCount),
        ]
        return urlComponents.url!
    }

    var parameterEncoding: ParameterEncoding {
        switch self {
        default:
            return JSONEncoding.default
        }
    }

    var path: String {
        switch self {
        case .getArticlesList(let count, let size):
            pageCount = count
            pageSize = size
            return  ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getArticlesList(_, _):
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }

}
