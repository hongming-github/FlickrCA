//
//  PhotoResultController.swift
//  FlickerCA
//
//  Created by zhm on 16/8/15.
//  Copyright © 2016年 zhm. All rights reserved.
//

import Foundation
import UIKit

class PhotoResultsController: UITableViewController ,NSURLSessionDataDelegate {
    var results:SearchPhoto!
    var dbManage:DataManagement!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
    }
    override func viewWillAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return results.id.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell :PhotoSearchCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PhotoSearchCell
        
        let s = "http://farm\(results.farm[indexPath.row]).staticflickr.com/\(results.server[indexPath.row])/\(results.id[indexPath.row])_\(results.secret[indexPath.row])_m.jpg"
        
        let imgURL:NSURL = NSURL(string: s)!
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
                let img=UIImage(data:data!)
                cell.imagePhoto.image = img
                cell.tvTitle.text = self.results.title[indexPath.row] as? String
            }
            
        }).resume()
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBigImage" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let photo = Photo(id: results.id[indexPath.row] as! String,
                                  url: "http://farm\(results.farm[indexPath.row]).staticflickr.com/\(results.server[indexPath.row])/\(results.id[indexPath.row])_\(results.secret[indexPath.row])_z.jpg",
                                  title: results.title[indexPath.row] as! String,
                                  tag: results.tag )
                
                let controller = segue.destinationViewController as! BigImageController
                controller.bigImage = photo
                controller.dbManage = dbManage
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
}
