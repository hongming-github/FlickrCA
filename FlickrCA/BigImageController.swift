//
//  BigImageController.swift
//  FlickerCA
//
//  Created by zhm on 16/8/15.
//  Copyright © 2016年 zhm. All rights reserved.
//

import UIKit
import Social
import MessageUI

class BigImageController:UIViewController,NSURLSessionDataDelegate, MFMailComposeViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var ivBigImage: UIImageView!
    @IBOutlet weak var ivLikeImage: UIImageView!
    var dbManage : DataManagement!
    var bigImage : Photo!
    var results : SearchPhoto!
    var img : UIImage!
    var attachment:NSData!
    var isHidden : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ivLikeImage.hidden = true
        
        let shareBar: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem:.Action, target: self, action: #selector(BigImageController.userDidTapShare))
        self.navigationItem.rightBarButtonItem = shareBar
        
        let imgURL:NSURL = NSURL(string: bigImage.url)!
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
                self.attachment = data
                self.img = UIImage(data:data!)
                self.ivBigImage.image = self.img
            }
            
        }).resume()
        
        let doubleTouch = UITapGestureRecognizer()
        doubleTouch.numberOfTapsRequired = 2
        doubleTouch.addTarget(self, action: #selector(BigImageController.like))
        view.userInteractionEnabled = true
        view.addGestureRecognizer(doubleTouch)
        
    }
    //user like photo
    func like(){
        if !isHidden {
            self.navigationController?.navigationBar.hidden = true
            self.tabBarController?.tabBar.hidden = true
        }
        
        if bigImage.like {
            ivLikeImage.hidden = true
            bigImage.like = false
        }
        else{
            ivLikeImage.hidden = false
            bigImage.like = true
        }
    }
    //touch share button
    func userDidTapShare() {
        
        let actionSheet = UIAlertController(title: "", message: "Share", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let tweetAction = UIAlertAction(title: "Share to Twitter", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.shareToTwitter()
        }
        
        let facebookPostAction = UIAlertAction(title: "Share to Facebook", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.shareToFacebook()
        }
        
        let emailAction = UIAlertAction(title: "Share to Email", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.shareToEmail()
        }
        
        let airdropAction = UIAlertAction(title: "Share to AirDrop", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.shareToAirdrop()
        }
        
        let localPhotoAction = UIAlertAction(title: "Share Local Photo", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.shareLocalPhoto()
        }
        
        let dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
        }
        actionSheet.addAction(tweetAction)
        actionSheet.addAction(facebookPostAction)
        actionSheet.addAction(emailAction)
        actionSheet.addAction(airdropAction)
        actionSheet.addAction(localPhotoAction)
        actionSheet.addAction(dismissAction)
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func shareToFacebook(){
        
        if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)) {
            let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            controller.setInitialText("Test Post from Zhao")
            controller.addImage(self.img)
            self.presentViewController(controller, animated:true, completion:nil)
            
        } else {
            print("No Facebook account found on device")
        }
    }
    
    func shareToTwitter(){
        
        if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)) {
            let controller = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            controller.setInitialText("This is a tweet from ZhaoHongming")
            controller.addImage(self.img)
            self.presentViewController(controller, animated:true, completion:nil)
        }
        else {
            print("No twitter account found on device")
        }
        
    }
    
    func shareToEmail(){
        let emailShareController : MFMailComposeViewController = MFMailComposeViewController()
        emailShareController.mailComposeDelegate = self
        emailShareController.setSubject("Share image")
        emailShareController.addAttachmentData(self.attachment, mimeType:"image/jpeg", fileName: "Image")
        emailShareController.setMessageBody("This attachment is an image", isHTML: false)
        self.presentViewController(emailShareController, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shareToAirdrop(){
        let controller = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        controller.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypeMail,UIActivityTypeMessage]
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func shareLocalPhoto(){
        let imagePicker : UIImagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true,completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let activityItem  = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.dismissViewControllerAnimated(true,completion: nil)
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [activityItem], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler =  {
            (activity, success, items, error) in
            if !success {
                return
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isHidden{
            //appear
            self.navigationController?.navigationBar.hidden = false
            self.tabBarController?.tabBar.hidden = false
            isHidden = false
        }
        else{
            //hide
            self.navigationController?.navigationBar.hidden = true
            self.tabBarController?.tabBar.hidden = true
            isHidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if dbManage.findByUrl(bigImage.url) {
            ivLikeImage.hidden = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if bigImage.like && !dbManage.findByUrl(bigImage.url) {
            if dbManage.create(bigImage.id, url: bigImage.url, title: bigImage.title, tag: bigImage.tag) {
                print("create like photo successful")
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}