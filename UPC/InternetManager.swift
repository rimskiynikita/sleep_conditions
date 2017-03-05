//
//  InternetManager.swift
//  UPC
//
//  Created by Никита Римский on 03.03.17.
//  Copyright © 2017 Никита Римский. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class InternetManager {
    
    static let sharedInstance = InternetManager()
    
    private let URL = "https://sleep-more.com/"
    private let getData = "get_data_for_ios/?id=2&fields=noise,temperature,humidity,light"
    
    func getTemper(completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
        makeCall(completionHandler: completionHandler)
    }
    
    func makeCall(completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
        
        let getRequest = URL + getData
        
        Alamofire.request(getRequest)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                case .failure(let error):
                    completionHandler(nil, error)
                }
        }
    }
}
