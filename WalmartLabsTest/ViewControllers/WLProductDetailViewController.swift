//
//  WLProductDetailViewController.swift
//  WalmartLabsTest
//
//  Created by Swapnil Jain on 9/29/17.
//  Copyright © 2017 WalmartLabs. All rights reserved.
//

import UIKit

class WLProductDetailViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // Initiate page view controller
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    var productManager: WLProductManager?
    var currentPageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set pageViewController data source and delegate
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // Add pageViewController's view as subview
        pageViewController.view.backgroundColor = UIColor.white
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        // Provide viewController's array to pageViewController
        var viewControllers = Array<WLProductDataViewController>()
        viewControllers.append(viewControllerAtIndex(index: currentPageIndex))
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK:- UIPageView Controller Data source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WLProductDataViewController).pageIndex
        
        if index == 0{
            return nil
        }
        
        index = index - 1
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WLProductDataViewController).pageIndex
        
        if let productManager = productManager, index == productManager.totalProducts - 1{
            return nil
        }
        
        index = index + 1
        return viewControllerAtIndex(index: index)
    }
    
    // MARK:- UIPageView Controller Delegate
    
    // MARK:- Helpers
    func viewControllerAtIndex(index: Int) -> WLProductDataViewController{
        // Prefetch data if needed.
        prefetchNextPageIfNeeded(index: index)
        
        // Initiate a new data vc
        let dataVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WLProductDataVC") as! WLProductDataViewController
        dataVC.pageIndex = index
        if let productManager = productManager, index < productManager.listOfProducts.count {
            dataVC.product = productManager.listOfProducts[index]
        }
        return dataVC
    }
    
    func prefetchNextPageIfNeeded(index: Int){
        guard let productManager = productManager else{
            return
        }
        let nextPageIndexToLoad = ((index+productManager.pageSize) / productManager.pageSize) + 1
        if nextPageIndexToLoad >= productManager.nextPageIndex{
            print("LOAD PAGE for INDEX: \(nextPageIndexToLoad)")
            // getWalmartProducts API call increment the productManager.nextPageIndex count by 1
            productManager.getWalmartProducts {
                // do NOT reload table view/cell here
            }
        }
    }
}
