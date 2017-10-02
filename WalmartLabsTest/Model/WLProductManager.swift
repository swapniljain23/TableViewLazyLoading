//
//  WLProducts.swift
//  WalmartLabsTest
//
//  Created by Swapnil Jain on 9/28/17.
//  Copyright © 2017 WalmartLabs. All rights reserved.
//

import UIKit

class WLProductManager {
    
    // MARK:- Properties
    var listOfProducts = [WLProduct]()
    var totalProducts = 0
    var nextPageIndex = 1
    let pageSize = 10
    
    // MARK:- Instance methods
    // Request to get products
    func getWalmartProducts(completionHandler: @escaping () -> Void){
        print("getWalmartProducts: \(nextPageIndex)")
        
        // Initiate url request
        let urlRequest = URLRequest(url: URL(string: "\(kAPIUrl)/walmartproducts/\(kWalmartAPIKey)/\(nextPageIndex)/\(pageSize)")!)
        
        // Initiate data task
        let sessionTask = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in

            guard let _ = response, let data = data else{
                return
            }
            do{
                guard let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String, Any> else{
                    // Handle unexpected format here.
                    return
                }
                //print(jsonData)
                for (key, value) in jsonData{
                    switch key{
                    case kProductsKey:
                        if let productsArr = value as? [Dictionary<String, Any>]{
                            for product in productsArr{
                                self.listOfProducts.append(WLProduct(productDictionary: product))
                            }
                        }
                    case kTotalProductsKey:
                        if let totalProducts = value as? Int{
                            self.totalProducts = totalProducts
                        }
                    case kPageNumberKey:
                        break
                    case kPageSizeKey:
                        break
                    case kStatusKey:
                        if let status = value as? Int, status != 200{
                            // Handle error here
                        }
                    default:
                        break
                    }
                }
            }catch{
                // Handle any exception here
            }
            if let _ = error{
                // Handle error here.
            }else{
                // Handle unexpected error here
            }
            
            // Get main queue and call completion handler
            DispatchQueue.main.async(){
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completionHandler()
            }
        }
        
        // Start data task
        sessionTask.resume()
        
        // Update pageIndex cursor
        self.nextPageIndex += 1
        
        // Start activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}
