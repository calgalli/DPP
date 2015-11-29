//
//  loginViewController.swift
//  DDP
//
//  Created by cake on 11/26/2558 BE.
//  Copyright © 2558 cake. All rights reserved.
//

import UIKit
import SwiftHTTP

class loginViewController: UIViewController, UITextFieldDelegate {
    
    var firstNameTextView : UITextView?
    
    let button   = UIButton(type: UIButtonType.System) as UIButton
    
    var firstName : String = ""
    var lastName : String = ""
    
    
    override func viewDidLoad() {
         super.viewDidLoad()

        enum inputType {
            case FirstName
            case LastName
            case Email
            case Password
            case Mobile
            case GCMRegistrationID
        }
        
        
        
        
        // Do any additional setup after loading the view.
        let hight : CGFloat = 30
        let gap : CGFloat = 8
        var textViews = [UITextField]()
        let offset : CGFloat = 90
        let labels = ["FirstName","LastName","e-mail","Password","Mobile"]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "RegistarionComplete:", name: registrationKey, object: nil)

        
        for var i = 0;i < 5;i++ {
            textViews.insert(UITextField(frame: CGRectMake(0, 0, self.view.frame.width/2 , hight)), atIndex: i)
            //textViews[i].borderStyle = UITextBorderStyle.Line
            textViews[i].layer.borderWidth = 1
            textViews[i].layer.borderColor = UIColor.lightGrayColor().CGColor
            textViews[i].layer.cornerRadius = 5
            textViews[i].delegate = self
            textViews[i].tag = i
        }
        
        for var i = 0;i < 5;i++ {
            textViews[i].center = CGPointMake(self.view.frame.width/2 +  self.view.frame.width/4 - 10, offset + CGFloat(i)*(hight + gap))
            let label = UILabel(frame: CGRectMake(0, 0, self.view.frame.width/2 , hight))
            label.center = CGPointMake(10 + self.view.frame.width/4 , offset + CGFloat(i)*(hight + gap))
            label.text = labels[i]
            self.view.addSubview(textViews[i])
            self.view.addSubview(label)
            
        }
        
        button.frame = CGRectMake(100, 100, 100, 50)
        button.center = CGPointMake(self.view.frame.width/2 , self.view.frame.height - 100)
        button.backgroundColor = UIColor.lightGrayColor()
        button.setTitle("Register", forState: UIControlState.Normal)
        button.setTitle("Waiting", forState: UIControlState.Disabled)
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        button.userInteractionEnabled = false
        
        self.view.addSubview(button)
        
      //  firstNameTextView!.center = CGPointMake(, )
        

        
    }

    
    
    func buttonAction(sender:UIButton!)
    {
        print("Button tapped")
        /*let params: Dictionary<String,AnyObject> = ["FirstName":"fllay","LastName":"asler12","Email" : "asler12@gmail.com","Password" : "1234","Mobile" : "1112222","GCMRegistrationID" : GCMRegistrationID]
        
        
        do {
            let opt = try HTTP.POST(mainhost + "/api/member", parameters: params)
            opt.start { response in
                //do things...
                if let obj: AnyObject =  response.data {
                    
                    let json = JSON(data: obj as! NSData)
                    
                    print(json)
                }
                
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }*/
    }
    
    
    //MARK: Messagging callbacks
    
    func RegistarionComplete(notification:NSNotification){
        button.userInteractionEnabled = true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- ---> Textfield Delegates
    func textFieldDidBeginEditing(textField: UITextField) {
        //print("TextField did begin editing method called")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch (textField.tag){
            case 0:
                print(textField.text)
            case 1:
                print(textField.text)
            case 2:
                print(textField.text)
            case 3:
                print(textField.text)
            case 4:
                print(textField.text)
            
            default: break
        }
        print("TextField did end editing method called")
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //print("TextField should begin editing method called")
        return true;
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        //print("TextField should clear method called")
        return true;
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        //print("TextField should snd editing method called")
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //print("While entering the characters this method gets called")
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //print("TextField should return method called")
        textField.resignFirstResponder();
        return true;
    }
    // MARK: Textfield Delegates <---

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
