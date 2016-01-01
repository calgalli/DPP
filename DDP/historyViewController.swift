//
//  historyViewController.swift
//  DDP
//
//  Created by cake on 12/12/2558 BE.
//  Copyright © 2558 cake. All rights reserved.
//

import UIKit
import SwiftHTTP


class historyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var historyTableView: UITableView!
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var historyJson : JSON?
    
    struct historyDetail {
        var from : String = String()
        var to : String = String()
        var driverPicUrl : String = String()
        var driverLicensePlace : String = String()
        var dateTime : String = String()
        var price : Double = 0

    }
    
    var historyDetailAll : [historyDetail] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.setTitle("\u{276C}Back", forState: .Normal)

        print("Member ID = \(self.delegate.userJson!["AuthenMember"]["Id"].string)")
        historyTableView.rowHeight = 60
        self.historyTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        let params: Dictionary<String,AnyObject> = ["Action" : "12","Member" : self.delegate.userJson!["AuthenMember"]["Id"].string!]
        
        do {
            let opt = try HTTP.PUT(mainhost + "/api/order", parameters: params)
            opt.start { response in
                //do things...
                if let obj: AnyObject =  response.data {
                    
                    self.historyJson = JSON(data: obj as! NSData)
                    print(self.historyJson)
                    print("************************* History **************************")
                    if self.historyJson!["Status"].string ==  "SUCCESS" {
                        print("************************* SUCCESS *****************************")
                        for (_,subJson):(String, JSON) in self.historyJson!["Orders"] {
                            let fromName = subJson["FromName"].string!
                            let toName = subJson["ToName"].string!
                            let price = subJson["TotalPrice"].double!
                            let dateTime = subJson["OrderDateTime"].string!
                            print("\(fromName) to \(toName)")
                            
                            let hd : historyDetail = historyDetail(from: fromName, to: toName, driverPicUrl: "", driverLicensePlace: "", dateTime: dateTime ,price: price)
                            
                            self.historyDetailAll.append(hd)
                            
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.historyTableView.reloadData()
                        }
                    } else {
                        
                    }
                }
                
            }
            
        } catch let error {
            print("got an error creating the request: \(error)")
        }
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(sender: AnyObject) {
        performSegueWithIdentifier("historyToMain", sender: nil)
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //self.resultSearchController.active
       
        return self.historyDetailAll.count
      
        
        
    }
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell  = historyTableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath) as? UITableViewCell
        //print("****************** Do searching *********************")
        
        if cell != nil {
            
            if let fromTo = cell!.viewWithTag(2) as? UILabel { //3
                fromTo.text = historyDetailAll[indexPath.row].from + " to "  + historyDetailAll[indexPath.row].to
            }
            if let price = cell!.viewWithTag(1) as? UILabel {
                price.text = "THB " + String(historyDetailAll[indexPath.row].price)
            }
            
            if let date = cell!.viewWithTag(3) as? UILabel {
                date.text = String(historyDetailAll[indexPath.row].dateTime)
            }

            return cell!
            
        } else {
            return cell!
        }
        
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Publist MQTT message to the selected taxi
        //var cell = searchList.dequeueReusableCellWithIdentifier("searchResults", forIndexPath: indexPath)
        
        //self.selectedCell = cell
        
        let indexP = indexPath.row
        
        
    }
    
    

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
