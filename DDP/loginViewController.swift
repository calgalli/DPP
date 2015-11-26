//
//  loginViewController.swift
//  DDP
//
//  Created by cake on 11/26/2558 BE.
//  Copyright © 2558 cake. All rights reserved.
//

import UIKit

class loginViewController: UIViewController {
    
    var firstNameTextView : UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var center : [CGFloat] = [0,0,0,0,0,0]
        var gap = 8
        
    //    for i:Int = 0;i < 6;i++ {
            
    //    }
        
          firstNameTextView  = UITextView(frame: CGRectMake(0, 0, self.view.frame.width , 25))
       //   firstNameTextView!.center = CGPointMake(<#T##x: CGFloat##CGFloat#>, <#T##y: CGFloat##CGFloat#>)
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
