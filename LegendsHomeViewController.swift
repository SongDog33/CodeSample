//
//  LegendsHomeViewController.swift
//  Legends TV
//
//  Created by Joel Myers on 10/24/17.
//  Copyright © 2017 Legends Media. All rights reserved.
//

import UIKit

class LegendsHomeViewController: UIViewController, UIScrollViewDelegate, ListingViewDelegate {

    @IBOutlet weak var homeScrollView: UIScrollView!
    @IBOutlet weak var homePageControl: UIPageControl!
    @IBOutlet weak var slideUpBtn: UIButton!

    let jsonHandler = JSONHandler.defaultHandler

    var moviesArray : [[String : Any]]?
    var picsArray : [UIImage]? = []
    
    var currentPage = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        slideUpBtn.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        moviesArray = jsonHandler.parseMovieArray()
        getData()
    }

    func getData() {
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.center = self.view.center
        activityView.startAnimating()
        view.addSubview(activityView)
        
        DispatchQueue.global().async {
            for viewing in self.moviesArray!{
                let dict = viewing["movie"] as AnyObject
                
                //get "thumbnail key string"
                let url = URL(string: "\(dict["thumbnail"] as! String)")
                if let data = try? Data(contentsOf: url!) {
                    self.picsArray?.append(UIImage(data: data)!)
                }
            }
            DispatchQueue.main.sync {
                //Create ScrollView of all Movie Pics
                self.setupHomeScroll()
                activityView.stopAnimating()
            }
        }
    }
    
    //MARK: Method that loads LegendsListingVCs in the proper amount of moviearray.count and adds them to the homeScrollView contentView width by SCREEN_WIDTH * count for paging
    func setupHomeScroll() {
        if moviesArray != nil {
            homePageControl.numberOfPages = (moviesArray?.count)!
        }
        var viewingDict : [String : AnyObject]
        
        if let arr = picsArray {
            homeScrollView.contentSize = CGSize(width: ScreenSize.SCREEN_WIDTH * CGFloat((moviesArray?.count)!), height: ScreenSize.SCREEN_HEIGHT)
            var count = 0
            
            for __ in picsArray! {
                let listingView = LegendsListingView(frame: CGRect(x: ScreenSize.SCREEN_WIDTH * CGFloat(count), y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT))
                listingView.delegate = self
                let img = arr[count]
                listingView.imageView.image = img
                
                //Grab proper dictionary from movies array and parse data for labels
                let dict = moviesArray?[count] as AnyObject
                viewingDict = dict["movie"] as! [String : AnyObject]
                listingView.titleLabel.text = viewingDict["title"] as? String
                
                let dict2 = viewingDict["content"] as! [String : Any]
                listingView.durationLabel.text = "\(Int(Int((dict2["duration"] as? String)!)! / 60)) MINS"
                
                homeScrollView.addSubview(listingView)
                count += 1
            }
        }
    }
    
    //MARK: ListingViewDelegate for when Play button tapped, segue to full Screen Video player
    func playPressed() {
//        performSegue(withIdentifier: "PlayListingSegue", sender: self)
        let navi = UIStoryboard(name: "V2UI", bundle: nil).instantiateViewController(withIdentifier: "navi") as! UINavigationController
        let vc = navi.viewControllers[0] as! LegendsVideoViewController
        
        let dict = moviesArray?[currentPage] as AnyObject
        vc.viewingDict = dict["movie"] as! [String : AnyObject]?
        present(navi, animated: true, completion: nil)
    }
    
    //MARK: UIScrollViewDelegate Methods
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth : CGFloat = scrollView.frame.width
        currentPage = Int(floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1)
        // Change the indicator
        homePageControl.currentPage = currentPage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func swipeUp() {
        performSegue(withIdentifier: "DetailSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if segue.identifier == "DetailSegue" {
            let vc = segue.destination as! LegendsDetailViewController
            
            let dict = moviesArray?[currentPage] as AnyObject
            vc.viewingDict = dict["movie"] as? [String : AnyObject]
        }
    }
}
