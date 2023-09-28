//
//  RequestTool.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/19.
//

import Foundation
import Alamofire
import SwiftyJSON

class RequestTool: NSObject {
    
    @discardableResult
    public static func request(url: String,
                               httpMethod: HTTPMethod,
                               params: [String: Any]? = nil,
                               headers: HTTPHeaders? = nil,
                               success: ((_ success: JSON) -> Void)? = nil,
                               error: ((_ error: Error) -> Void)? = nil,
                               complete: (() -> Void)? = nil) -> DataRequest {
        AF.request(url,
                   method: httpMethod,
                   parameters: params,
                   encoding: httpMethod == .get ? URLEncoding.default : JSONEncoding.prettyPrinted,
                   headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(let resultData):
                if let suc = success {
                    let obj = JSON(resultData as AnyObject)
                    suc(obj)
                }
            case .failure(let errorInfo):
                if let err = error {
                    err(errorInfo)
                }
            }
            if let comp = complete {
                comp()
            }
        }
    }
        
}
