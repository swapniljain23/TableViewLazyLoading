//
//  ViewController.swift
//  WalmartLabsTest
//
//  Created by Swapnil Jain on 9/28/17.
//  Copyright © 2017 WalmartLabs. All rights reserved.
//

import UIKit

class WLProductsTableViewController: UITableViewController {

    var productManager = WLProductManager()
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
        productManager.getWalmartProducts(){
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
        return productManager.totalProducts
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        
        if indexPath.row < productManager.listOfProducts.count{
            // Get the product and update the cell
            let product = productManager.listOfProducts[indexPath.row]
            
            guard let tableViewCell = cell as? WLProductTableViewCell else{
                return cell
            }
            
            tableViewCell.isLoading = false
            tableViewCell.productName.text = product.productName
            tableViewCell.productDescription.attributedText = product.shortDescription.htmlAttributedString()
            tableViewCell.productRatings.text = "Ratings: \(product.reviewRating)"
            tableViewCell.productPrice.text = product.price
            tableViewCell.productReviewCount.text = "Review Count: \(product.reviewCount)"
            tableViewCell.productInStock.text = (product.inStock)  ? "In Stock" : "Not In Stock"
            if product.productImage != nil{
                tableViewCell.productImageView.image = product.productImage
            }else{
                if self.tableView.isDragging == false && self.tableView.isDecelerating == false{
                    product.downloadImage {
                        tableViewCell.productImageView.image = product.productImage
                    }
                }
                // placeholder image
                tableViewCell.productImageView.image = UIImage(named: "load-d")
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
                cell.productImageView.image = UIImage(named: "load-d")
            }
        }
        loadTheNextPageIfNeeded(indexPath: indexPath)
        return cell
    }
    
    // MARK: UITableView Delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = WLProductDetailViewController()
        detailVC.currentPageIndex = indexPath.row
        detailVC.productManager = productManager
        
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
        if indexPath.row + productManager.pageSize < productManager.listOfProducts.count{
            return
        }
        if (indexPath.row +  productManager.pageSize) / productManager.pageSize + 1 >= productManager.nextPageIndex{
            productManager.getWalmartProducts(){
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
            if let cell = tableView.cellForRow(at: indexPath) as? WLProductTableViewCell, cell.isLoading, indexPath.row < productManager.listOfProducts.count{
                let product = productManager.listOfProducts[indexPath.row]
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
            if let cell = tableView.cellForRow(at: indexPath) as? WLProductTableViewCell, indexPath.row < productManager.listOfProducts.count{
                let product = productManager.listOfProducts[indexPath.row]
                if product.productImage == nil{
                    product.downloadImage {
                        cell.productImageView.image = product.productImage
                    }
                }
            }
        }
    }
}

