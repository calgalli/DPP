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
    var email : String = ""
    var password : String = ""
    var mobile : String = ""
    //var GCMRegistrationID : String = ""
    var textViews = [UITextField]()
    
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
        
        let offset : CGFloat = 90
        let labels = ["FirstName","LastName","e-mail","Password","Mobile"]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "RegistarionComplete:", name: registrationKey, object: nil)
        dispatch_async(dispatch_get_main_queue()){
        
            for var i = 0;i < 5;i++ {
                self.textViews.insert(UITextField(frame: CGRectMake(0, 0, self.view.frame.width/2 , hight)), atIndex: i)
                //textViews[i].borderStyle = UITextBorderStyle.Line
                self.textViews[i].layer.borderWidth = 1
                self.textViews[i].layer.borderColor = UIColor.lightGrayColor().CGColor
                self.textViews[i].layer.cornerRadius = 5
                self.textViews[i].delegate = self
                self.textViews[i].tag = i
                
                if(i == 2){
                    self.textViews[i].keyboardType = UIKeyboardType.EmailAddress
                } else if(i == 4){
                    self.textViews[i].keyboardType = UIKeyboardType.NumberPad
                    let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
                    doneToolbar.barStyle = UIBarStyle.BlackTranslucent
                    
                    let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
                    var items = [UIBarButtonItem]()
                    items.append(done)
                    
                    doneToolbar.items = items
                    doneToolbar.sizeToFit()
                    
                    self.textViews[i].inputAccessoryView = doneToolbar
                    
                    
                }
            }
            
            for var i = 0;i < 5;i++ {
                self.textViews[i].center = CGPointMake(self.view.frame.width/2 +  self.view.frame.width/4 - 10, offset + CGFloat(i)*(hight + gap))
                let label = UILabel(frame: CGRectMake(0, 0, self.view.frame.width/2 , hight))
                label.center = CGPointMake(10 + self.view.frame.width/4 , offset + CGFloat(i)*(hight + gap))
                label.text = labels[i]
                self.view.addSubview(self.textViews[i])
                self.view.addSubview(label)
                
            }
            
            self.button.frame = CGRectMake(100, 100, 100, 50)
            self.button.center = CGPointMake(self.view.frame.width/2 , self.view.frame.height - 100)
            self.button.backgroundColor = UIColor.lightGrayColor()
            self.button.setTitle("Register", forState: UIControlState.Normal)
            self.button.setTitle("Waiting", forState: UIControlState.Disabled)
            self.button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            self.button.userInteractionEnabled = false
            
            self.view.addSubview(self.button)
        }
        
      //  firstNameTextView!.center = CGPointMake(, )
        
        

        
    }

    
    
    func buttonAction(sender:UIButton!)
    {
        print("Button tapped")
        
        //prefs.setObject(GCMRegistrationID, forKey: "GCMRegistrationID")
        
        print(GCMRegistrationID)
        
        let params: Dictionary<String,AnyObject> = ["FirstName":firstName,"LastName":lastName,"Email" : email,"Password" : password,"Mobile" : mobile,"GCMRegistrationID" : GCMRegistrationID]
        print(params)
        
        do {
            let opt = try HTTP.POST(mainhost + "/api/member", parameters: params)
            opt.start { response in
                //do things...
                if let obj: AnyObject =  response.data {
                    
                    let json = JSON(data: obj as! NSData)
                    print(json)
                    if json["Status"].string ==  "SUCCESS" {
                        print("************************* SUCCESS *****************************")
                        prefs.setObject("yes", forKey: "haveLogin")
                        
                        dispatch_async(dispatch_get_main_queue()){
                        
                            let alertController = UIAlertController(title: "Registration complete", message: "Contratulation", preferredStyle: .Alert)
                            
                            let commentAction = UIAlertAction(title: "OK", style: .Default) { (_) in
                                self.performSegueWithIdentifier("toMainView", sender: nil)
                            }
                            
                            
                            alertController.addAction(commentAction)
                            
                            self.presentViewController(alertController, animated: true) {
                                // ...
                            }

                        
                        }
                        
                       
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue()){
                            let alertController = UIAlertController(title: "Registration Fail", message: "Incomplete data. Please check you data and try again", preferredStyle: .Alert)
                            
                            let commentAction = UIAlertAction(title: "OK", style: .Default) { (_) in
                                
                            }
                            
                            
                            alertController.addAction(commentAction)
                            
                            self.presentViewController(alertController, animated: true) {
                                // ...
                            }
                        }

                    }

                    
                    
                    
                    
                }
                
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    
    //MARK: Messagging callbacks
    
    func RegistarionComplete(notification:NSNotification){
        dispatch_async(dispatch_get_main_queue()){
            self.button.userInteractionEnabled = true
        }
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
                firstName = textField.text!
                prefs.setObject(firstName, forKey: "firstName")
                print(textField.text)
            case 1:
                lastName = textField.text!
                prefs.setObject(lastName, forKey: "lastName")

                print(textField.text)
            case 2:
                email = textField.text!
                prefs.setObject(email, forKey: "email")

                print(textField.text)
            case 3:
                password = textField.text!
                prefs.setObject(password, forKey: "password")

                print(textField.text)
            case 4:
                mobile = textField.text!
                prefs.setObject(mobile, forKey: "mobile")

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
        dispatch_async(dispatch_get_main_queue()){
            textField.resignFirstResponder();
        }
        return true;
    }
    // MARK: Textfield Delegates <---
    // MARK: Done button
    
    func addDoneButtonOnKeyboard()
    {
        
    }
    
    func doneButtonAction()
    {
        
        for x in textViews {
            dispatch_async(dispatch_get_main_queue()){
                x.resignFirstResponder()
            }
        }
      
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
