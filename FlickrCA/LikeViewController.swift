//
//  SecondViewController.swift
//  FlickerCA
//
//  Created by zhm on 16/8/15.
//  Copyright © 2016年 zhm. All rights reserved.
//

import UIKit

class LikeViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate,NSURLSessionDataDelegate,UITextFieldDelegate{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBarController: UISearchBar!
    @IBOutlet weak var labelNoResults: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
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
        searchBarController.delegate = self
        self.navigationItem.rightBarButtonItem = editButtonItem()
        toolbar.hidden = true
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
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.allowsMultipleSelection = editing
        tabBarController?.tabBar.hidden = true
        toolbar.hidden = !editing
        let selectedIndex = collectionView.indexPathsForVisibleItems()
        for i in selectedIndex{
            collectionView.deselectItemAtIndexPath(i, animated: true)
            highlightCell(i, flag: false)
        }
        print(selectedIndex)
        if !editing {
            tabBarController?.tabBar.hidden = false
            for i in selectedIndex{
                print("no edit \(i.row)")
                collectionView.deselectItemAtIndexPath(i, animated: true)
                highlightCell(i, flag: false)
            }
            
        }
    }
    
    @IBAction func deletePhoto(sender: AnyObject) {
        var deletePhotosUrl = [String]()
        for i in collectionView.indexPathsForSelectedItems()!{
            collectionView.deselectItemAtIndexPath((i), animated: true)
            deletePhotosUrl.append(collectionViewShowPhotos[i.row].url)
        }
        for i in deletePhotosUrl{
            if dbManage.delete(i){
                print("delete successful)")
            }
        }
        collectionViewShowPhotos = dbManage.selectAll()
        collectionView.reloadData()
    }
    func textFieldDidEndEditing(textField: UITextField) {
        print("cell\(cellIndex)end")
        print(textField.text)
        dbManage.update(textField.text!, url: updateUrl!)
        for i in collectionView.indexPathsForVisibleItems(){
            let cell = collectionView.cellForItemAtIndexPath(i) as! MyCollectionCell
            cell.commentsShow.resignFirstResponder()
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
         print("didDeselect\(indexPath.row)")
         highlightCell(indexPath, flag: false)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
         cellIndex = indexPath.row
         updateUrl = collectionViewShowPhotos[indexPath.row].url
         highlightCell(indexPath, flag: true)
         print("select:\(cellIndex)")
    }
    
    func highlightCell(indexPath : NSIndexPath, flag: Bool){
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MyCollectionCell
        if flag {
            cell.commentsShow.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2)
        } else {
            cell.commentsShow.backgroundColor = nil
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
         collectionViewShowPhotos = dbManage.findByTag((searchBarController.text?.lowercaseString)!)
         collectionView.reloadData()
        if collectionViewShowPhotos.count == 0 {
            labelNoResults.hidden = false
        }
        else{
            labelNoResults.hidden = true
        }
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            collectionViewShowPhotos = dbManage.selectAll()
            collectionView.reloadData()
            labelNoResults.hidden = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        for i in collectionView.indexPathsForSelectedItems()!{
            collectionView.deselectItemAtIndexPath(i, animated: true)
            highlightCell(i, flag: false)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
         collectionViewShowPhotos = dbManage.selectAll()
         collectionView.reloadData()
         labelNoResults.hidden = true
    }
    
}

