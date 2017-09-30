//
//  ViewController.swift
//  WalmartLabsTest
//
//  Created by Swapnil Jain on 9/28/17.
//  Copyright © 2017 WalmartLabs. All rights reserved.
//

import UIKit

class WLProductsTableViewController: UITableViewController {

    var walmartProducts = WLProducts()
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set activity indicator view center
        activityIndicatorView.center = tableView.center
        activityIndicatorView.startAnimating()
        
        // Add actiity indicator view
        tableView.addSubview(activityIndicatorView)
        
        // Get products
        walmartProducts.getWalmartProducts(){
            // Remove activity indicator and reload table view
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.removeFromSuperview()
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- UITableView Data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walmartProducts.totalProducts
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        
        if indexPath.row < walmartProducts.listOfProducts.count{
            // Get the product and update the cell
            let product = walmartProducts.listOfProducts[indexPath.row]
            
            if let cell = cell as? WLProductTableViewCell{
                cell.isLoading = false
                cell.productName.text = product.productName
                cell.productDescription.attributedText = product.shortDescription.htmlAttributedString()
                cell.productRatings.text = "Ratings: \(product.reviewRating)"
                cell.productPrice.text = product.price
                cell.productReviewCount.text = "Review Count: \(product.reviewCount)"
                cell.productInStock.text = (product.inStock)  ? "In Stock" : "Not In Stock"
                if product.productImage != nil{
                    cell.productImageView.image = product.productImage
                }else{
                    if self.tableView.isDragging == false && self.tableView.isDecelerating == false{
                        product.downloadImage {
                            cell.productImageView.image = product.productImage
                        }
                    }
                    // placeholder image
                    cell.productImageView.image = UIImage(named: "load-d")
                }
            }
            
        }else{
            // load the placeholder cell
            if let cell = cell as? WLProductTableViewCell{
                cell.isLoading = true
                cell.productName.text = "Loading.."
                cell.productDescription.text = ""
                cell.productRatings.text = ""
                cell.productPrice.text = ""
                cell.productReviewCount.text = ""
                cell.productInStock.text = ""
            }
        }

        loadTheNextPageIfNeeded(indexPath: indexPath)
        
        return cell
    }
    
    // MARK: UITableView Delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = WLProductDetailViewController()
        detailVC.currentPageIndex = indexPath.row
        detailVC.products = walmartProducts
        
        // Push
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK:- UIScrollView Delegates
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        reloadVisibleCellIfNeeded()
        downloadImageForVisibleRows()
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate){
            reloadVisibleCellIfNeeded()
            downloadImageForVisibleRows()
        }
    }
    
    //
    func loadTheNextPageIfNeeded(indexPath: IndexPath){
        if indexPath.row + walmartProducts.pageSize < walmartProducts.listOfProducts.count{
            return
        }
        if (indexPath.row +  walmartProducts.pageSize) / walmartProducts.pageSize + 1 >= walmartProducts.nextPageIndex{
            walmartProducts.getWalmartProducts(){
                self.reloadVisibleCellIfNeeded()
            }
        }
    }
    
    func reloadVisibleCellIfNeeded(){
        if self.tableView.isDragging == true && self.tableView.isDecelerating == true{
            return
        }
        let visibleIndexPaths = tableView.indexPathsForVisibleRows
        guard let indexPaths = visibleIndexPaths else{
            return
        }
        for indexPath in indexPaths{
            if let cell = tableView.cellForRow(at: indexPath) as? WLProductTableViewCell, cell.isLoading, indexPath.row < walmartProducts.listOfProducts.count{
                let product = walmartProducts.listOfProducts[indexPath.row]
                cell.isLoading = false
                cell.productName.text = product.productName
                cell.productDescription.attributedText = product.shortDescription.htmlAttributedString()
                cell.productRatings.text = "Ratings: \(product.reviewRating)"
                cell.productPrice.text = product.price
                cell.productReviewCount.text = "Review Count: \(product.reviewCount)"
                cell.productInStock.text = (product.inStock)  ? "In Stock" : "Not In Stock"
            }
        }
    }
    
    func downloadImageForVisibleRows(){
        let visibleIndexPaths = tableView.indexPathsForVisibleRows
        guard let indexPaths = visibleIndexPaths else{
            return
        }
        for indexPath in indexPaths{
            if let cell = tableView.cellForRow(at: indexPath) as? WLProductTableViewCell, indexPath.row < walmartProducts.listOfProducts.count{
                let product = walmartProducts.listOfProducts[indexPath.row]
                if product.productImage == nil{
                    product.downloadImage {
                        cell.productImageView.image = product.productImage
                    }
                }
            }
        }
    }
}

