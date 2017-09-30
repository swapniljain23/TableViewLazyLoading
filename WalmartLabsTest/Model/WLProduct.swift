//
//  WLProduct.swift
//  WalmartLabsTest
//
//  Created by Swapnil Jain on 9/29/17.
//  Copyright © 2017 WalmartLabs. All rights reserved.
//

import UIKit

class WLProduct {
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
    
    // Download image in background thread
    func downloadImage(completionHandler: @escaping () -> Void){
        guard let url = URL(string: productImageUrl) else{
            return
        }
        // Initiate url request
        let urlRequest = URLRequest(url: url)
        
        // Initiate data task
        let sessionTask = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in
            if let _ = response, let data = data{
                self.productImage = UIImage(data: data)
                // Get main queue to call completion handler
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
        // Start data task
        sessionTask.resume()
    }
}
