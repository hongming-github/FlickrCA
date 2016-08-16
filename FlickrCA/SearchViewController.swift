
import UIKit

class SearchViewController: UIViewController,NSURLSessionDataDelegate {
    @IBOutlet var searchString:UITextField!
    var results:SearchPhoto!
    var isHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
    }
    
    @IBAction func search() {
        
        let baseURL = "https://api.flickr.com/services/rest/?&method=flickr.photos.search"
        let apiString = "&api_key=97bc397c935a9e681a56214d5b717efa"
        let searchTag = "&tags=\(searchString.text!)"
        let format = "&format=json&nojsoncallback=1&per_page=10&accuracy=1"
        
        let requestURL = NSURL(string: baseURL + apiString + searchTag + format)
        
        let defaultConfigObject:NSURLSessionConfiguration =
            NSURLSessionConfiguration.defaultSessionConfiguration()
        let session:NSURLSession = NSURLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        session.dataTaskWithURL(requestURL!, completionHandler: {(data, response, error) in
            
            if (error != nil) {
                print("Error %@",error!.userInfo);
                print("Error description %@", error!.localizedDescription);
                print("Error domain %@", error!.domain);
            }
            
            if (data != nil){
                let mutableData : NSMutableData = NSMutableData(data: data!)
                self.processResponse(mutableData)
            }
            
        }).resume()
    }
    
    func processResponse(data:NSMutableData) {
        
        do{
            if results.id.count != 0 {
                results.clear()
            }
            
            let json : NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
            
            if let photos : NSDictionary = json["photos"] as? NSDictionary {
                if let photo = photos["photo"] as? [[String: AnyObject]] {
                    for i in photo{
                        if let id = i["id"] as? String {
                            results.id.addObject(id)
                        }
                        if let owner = i["owner"] as? String {
                            results.owner.addObject(owner)
                        }
                        if let farm = i["farm"] as? Int {
                            results.farm.addObject(farm)
                        }
                        if let server = i["server"] as? String {
                            results.server.addObject(server)
                        }
                        if let secret = i["secret"] as? String {
                            results.secret.addObject(secret)
                        }
                        if var title = i["title"] as? String {
                            if title == ""{
                                title = "Title"
                            }
                            results.title.addObject(title)
                        }
                    }
                }
            }
        }
        catch{
            print("error serializing JSON: \(error)")
        }
        results.tag = searchString.text!.lowercaseString
        NSNotificationCenter.defaultCenter().postNotificationName("switchResultView", object: self)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isHidden{
            //appear
            self.tabBarController?.tabBar.hidden = false
            isHidden = false
        }
        else{
            //hide
            self.tabBarController?.tabBar.hidden = true
            isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
}

