//
//  WLProducts.swift
//  WalmartLabsTest
//
//  Created by Swapnil Jain on 9/28/17.
//  Copyright © 2017 WalmartLabs. All rights reserved.
//

import UIKit

class Product {
    var productId: String
    var productName: String
    var shortDescription: String
    var longDescription: String
    var price: String
    var productImageUrl: String
    var reviewRating: Double
    var reviewCount: Int
    var inStock: Bool
    var productImage: UIImage?
    
    // Failable initializer
    /* init?(productDictionary: Dictionary<String, Any>) {
        // Guard against any unexpected values here.
        guard let productId = productDictionary[kProductIdKey] as? String,
        let productName = productDictionary[kProductNameKey] as? String,
        let shortDescription = productDictionary[kProductShortDescKey] as? String,
        let longDescription = productDictionary[kProductLongDescKey] as? String,
        let price = productDictionary[kProductPriceKey] as? String,
        let productImageUrl = productDictionary[kProductImageKey] as? String,
        let reviewRating = productDictionary[kProductReviewRatingKey] as? Double,
        let reviewCount = productDictionary[kProductReviewCountKey] as? Int,
        let inStock = productDictionary[kProductInStockKey] as? Bool else{
            return nil
        }
        
        // Proceed further to initialize
        self.productId = productId
        self.productName = productName
        self.shortDescription = shortDescription
        self.longDescription = longDescription
        self.price = price
        self.productImageUrl = productImageUrl
        self.reviewRating = reviewRating
        self.reviewCount = reviewCount
        self.inStock = inStock
    } */
    
    // Designated Initializer
    init(productDictionary: Dictionary<String, Any>){
        self.productId = productDictionary[kProductIdKey] as? String ?? ""
        self.productName = productDictionary[kProductNameKey] as? String ?? ""
        self.shortDescription = productDictionary[kProductShortDescKey] as? String ?? ""
        self.longDescription = productDictionary[kProductLongDescKey] as? String ?? ""
        self.price = productDictionary[kProductPriceKey] as? String ?? ""
        self.productImageUrl = productDictionary[kProductImageKey] as? String ?? ""
        self.reviewRating = productDictionary[kProductReviewRatingKey] as? Double ?? 0
        self.reviewCount = productDictionary[kProductReviewCountKey] as? Int ?? 0
        self.inStock = productDictionary[kProductInStockKey] as? Bool ?? false
    }
    
    func downloadImage(completionHandler: @escaping () -> Void){
        guard let url = URL(string: productImageUrl) else{
            return
        }
        let urlRequest = URLRequest(url: url)
        let sessionTask = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in
            if let _ = response, let data = data{
                self.productImage = UIImage(data: data)
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
        sessionTask.resume()
    }
}

class WLProducts {
    var listOfProducts = [Product]()
    var totalProducts = 0
    var nextPageIndex = 1
    let pageSize = 10
    
    func getWalmartProducts(completionHandler: @escaping () -> Void){
        print("getWalmartProducts: \(nextPageIndex)")
        let urlRequest = URLRequest(url: URL(string: "\(kAPIUrl)/walmartproducts/\(kWalmartAPIKey)/\(nextPageIndex)/\(pageSize)")!)
        let sessionTask = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in

            if let _ = response, let data = data{
                do{
                    guard let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String, Any> else{
                        // Handle unexpected format here.
                        return
                    }
                    print(jsonData)
                    for (key, value) in jsonData{
                        switch key{
                        case kProductsKey:
                            if let productsArr = value as? [Dictionary<String, Any>]{
                                for product in productsArr{
                                    self.listOfProducts.append(Product(productDictionary: product))
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
                    
                }
            }else if let _ = error{
                
            }else{
                
            }
            
            // Get the main queue and call completion handler
            DispatchQueue.main.async(){
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completionHandler()
            }
        }
        sessionTask.resume()
        self.nextPageIndex += 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}
