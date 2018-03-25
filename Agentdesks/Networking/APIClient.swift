//
//  APIClient.swift
//  Agentdesks
//
//  Created by Ravi on 23/03/18.
//  Copyright © 2018 ThinkAnts. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper

let appBaseURL = "https://newsapi.org/v2/top-headlines"

enum APIClientError: Swift.Error {
    case emptyResponse
    case jsonParseError
    case serverError([String : Any])
}

struct APIClient<T: TargetType> {
    
    lazy var provider: MoyaProvider<T> = MoyaProvider<T>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    mutating func request(
        target: T,
        success successCallback: @escaping ([String : Any]?) -> Void,
        progress: Moya.ProgressBlock? = nil,
        failure failureCallback: @escaping ([String : Any]) -> Void = {(_: [String : Any]) in }) {
        
        provider.request(target, callbackQueue: nil, progress: progress) { result in
            switch result {
            case let .success(response):
                do {
                    guard let responseObject = try response.mapJSON() as? [String: Any] else {
                        throw APIClientError.jsonParseError
                    }
                    
                    guard let apiResponse = APIResponse(JSON:responseObject) else {
                        throw APIClientError.jsonParseError
                    }

                    if apiResponse.statusCode > 0 {
                        failureCallback(apiResponse.status)
                        return
                    }

                    successCallback(responseObject)
                } catch {
                    failureCallback(["Error": response.description ])
                }
            case let .failure(error):
                failureCallback(["Error": error.errorDescription ?? "Request failed !"])
                break
            }
        }
    }
}
