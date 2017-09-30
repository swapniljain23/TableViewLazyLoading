//
//  WLProductTableViewCell.swift
//  WalmartLabsTest
//
//  Created by Swapnil Jain on 9/28/17.
//  Copyright © 2017 WalmartLabs. All rights reserved.
//

import UIKit

class WLProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productRatings: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productReviewCount: UILabel!
    @IBOutlet weak var productInStock: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    var isLoading = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
