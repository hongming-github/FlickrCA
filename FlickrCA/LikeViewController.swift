//
//  SecondViewController.swift
//  FlickerCA
//
//  Created by zhm on 16/8/15.
//  Copyright © 2016年 zhm. All rights reserved.
//

import UIKit

class LikeViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate,NSURLSessionDataDelegate,UITextViewDelegate{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBarController: UISearchBar!
    var dbManage : DataManagement!
    var collectionViewShowPhotos = [Photo]()
    var cellIndex = 0
    var updateComments : String?
    var updateUrl : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionViewShowPhotos = dbManage.selectAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.collectionViewShowPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell : MyCollectionCell  = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! MyCollectionCell
        cell.commentsShow.delegate = self
        let imgURL:NSURL = NSURL(string: collectionViewShowPhotos[indexPath.row].url)!
        let defaultConfigObject:NSURLSessionConfiguration =
            NSURLSessionConfiguration.defaultSessionConfiguration()
        let session:NSURLSession = NSURLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        session.dataTaskWithURL(imgURL, completionHandler: {(data, response, error) in
            
            if error != nil {
                print("Error %@",error!.userInfo);
                print("Error description %@", error!.localizedDescription);
                print("Error domain %@", error!.domain);
            }
            if data != nil {
                let img = UIImage(data:data!)
                cell.imageshow.image = img
                cell.commentsShow.text = self.collectionViewShowPhotos[indexPath.row].comments
            }
            
        }).resume()
        
        return cell
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
         print("cell\(cellIndex)end")
         dbManage.update(textView.text, url: updateUrl!)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
         cellIndex = indexPath.row
         updateUrl = collectionViewShowPhotos[indexPath.row].url
    }
    
    override func viewWillAppear(animated: Bool) {
        collectionViewShowPhotos = dbManage.selectAll()
        collectionView.reloadData()
    }
    
}

