//
//  ViewController.swift
//  WalmartLabsTest
//
//  Created by Swapnil Jain on 9/28/17.
//  Copyright © 2017 WalmartLabs. All rights reserved.
//

import UIKit

class WLProductsTableViewController: UITableViewController, UITableViewDataSourcePrefetching {

    // MARK:- Properties
    var productManager = WLProductManager()
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var pendingImageDownloadStack = [IndexPath]()
    
    // MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set activity indicator view center
        activityIndicatorView.center = tableView.center
        activityIndicatorView.startAnimating()
        
        // Add actiity indicator view
        tableView.addSubview(activityIndicatorView)
        
        // Load the first page
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
        
        guard let tableViewCell = cell as? WLProductTableViewCell else{
            return cell
        }
        
        if indexPath.row < productManager.listOfProducts.count{
            // Get the product and update the cell
            let product = productManager.listOfProducts[indexPath.row]
            setDataInCell(tableViewCell: tableViewCell, product: product, indexPath: indexPath)
        }else{
            setDataInCell(tableViewCell: tableViewCell, product: nil, indexPath: indexPath)
        }
        return tableViewCell
    }
    
    // MARK:- UITableViewDataSourcePrefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]){
        print("prefetchRowsAt IndexPaths: \(indexPaths)")
        guard  let lastIndexPath = indexPaths.last else {
            return
        }
        
        let nextPageIndexToLoad = (lastIndexPath.row / productManager.pageSize) + 1
        
        // During normal scorll, this loop will be call just once.
        while nextPageIndexToLoad >= productManager.nextPageIndex{
            print("LOAD PAGE for INDEX: \(nextPageIndexToLoad)")
            // getWalmartProducts API call increment the productManager.nextPageIndex count by 1
            productManager.getWalmartProducts {
                // do NOT reload table view/cell here
            }
        }
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
        downloadPendingImages()
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate){
            reloadVisibleCellIfNeeded()
            downloadPendingImages()
        }
    }
    
    // MARK:- Cell reload
    func reloadVisibleCellIfNeeded(){
        let visibleIndexPaths = tableView.indexPathsForVisibleRows
        guard let indexPaths = visibleIndexPaths else{
            return
        }
        print("reloadVisibleCellIfNeeded: \(indexPaths.count)")
        for indexPath in indexPaths{
            if let cell = tableView.cellForRow(at: indexPath) as? WLProductTableViewCell, cell.isLoading, indexPath.row < productManager.listOfProducts.count{
                print("reloadVisibleCellIfNeeded:")
                let product = productManager.listOfProducts[indexPath.row]
                setDataInCell(tableViewCell: cell, product: product, indexPath: indexPath)
            }
        }
    }
    
    // MARK:- Reset data in cell for IndexPath
    func setDataInCell(tableViewCell: WLProductTableViewCell, product: WLProduct?, indexPath: IndexPath){
        if let product = product{
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
                if tableView.isDragging == false && tableView.isDecelerating == false{
                    product.downloadImage {
                        tableViewCell.productImageView.image = product.productImage
                    }
                }else{
                    pendingImageDownloadStack.append(indexPath)
                }
                // placeholder image
                tableViewCell.productImageView.image = UIImage(named: "load-d")
            }
        }else{
            tableViewCell.isLoading = true
            tableViewCell.productName.text = "Loading.."
            tableViewCell.productDescription.text = ""
            tableViewCell.productRatings.text = ""
            tableViewCell.productPrice.text = ""
            tableViewCell.productReviewCount.text = ""
            tableViewCell.productInStock.text = ""
            tableViewCell.productImageView.image = UIImage(named: "load-d")
        }
    }
    
    // MARK:- Lazy image downloading (Will be called only when user stop scrolling)
    func downloadPendingImages(){
        print("downloadPendingImages: \(pendingImageDownloadStack.count)")
        while pendingImageDownloadStack.count > 0{
            let indexPath = pendingImageDownloadStack.removeLast()
            if productManager.listOfProducts.count > indexPath.row{
                let product = productManager.listOfProducts[indexPath.row]
                // Start image download only if needed.
                if product.productImage == nil{
                    product.downloadImage {
                        let visibleIndexPaths = self.tableView.indexPathsForVisibleRows
                        // Update image only for the visible cells
                        if let indexPaths = visibleIndexPaths, indexPaths.contains(indexPath), let cell = self.tableView.cellForRow(at: indexPath) as? WLProductTableViewCell{
                            cell.productImageView.image = product.productImage
                        }
                    }
                }
            }
        }
    }
}

