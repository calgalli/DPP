//
//  blankViewController.swift
//  DDP
//
//  Created by cake on 1/9/2559 BE.
//  Copyright © 2559 cake. All rights reserved.
//

import UIKit

class blankViewController: UIViewController {
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Enter blank")
        leave()
        print("Leave blank")
        
        // Do any additional setup after loading the view.
    }

    func leave(){
        dispatch_async(dispatch_get_main_queue()){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc = storyboard.instantiateViewControllerWithIdentifier("ViewController") 
            
            self.delegate.window?.rootViewController = vc
            self.delegate.window?.makeKeyAndVisible()
            
        }
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
