//
//  WLProductDataViewController.swift
//  WalmartLabsTest
//
//  Created by Swapnil Jain on 9/29/17.
//  Copyright © 2017 WalmartLabs. All rights reserved.
//

import UIKit

class WLProductDataViewController: UIViewController {

    // MARK:- Properties
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productShortDescription: UILabel!
    @IBOutlet weak var productLongDescription: UILabel!
    @IBOutlet weak var productRatings: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productReviewCount: UILabel!
    @IBOutlet weak var productInStock: UILabel!
    @IBOutlet weak var productImageView: UIImageView!

    var pageIndex = 0
    var product: WLProduct?
    
    // MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let product = product{
            productName.text = product.productName
            productRatings.text = "Ratings: \(product.reviewRating)"
            productPrice.text = product.price
            productReviewCount.text = "Review Count: \(product.reviewCount)"
            productInStock.text = product.inStock ? "In-Stock" : "Not In-Stock"
            productShortDescription.attributedText = product.shortDescription.htmlAttributedString()
            productLongDescription.attributedText = product.longDescription.htmlAttributedString()
            if let _ = product.productImage{
                productImageView.image = product.productImage
            }else{
                product.downloadImage {
                    self.productImageView.image = product.productImage
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
