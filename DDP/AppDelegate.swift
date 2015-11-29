//
//  AppDelegate.swift
//  DDP
//
//  Created by cake on 10/17/2558 BE.
//  Copyright © 2558 cake. All rights reserved.
//


// to test Google Cloud Messaging
//curl -X POST -H "Authorization: key= AIzaSyBZwYV9Qtv4Kz0umJmMNg58IfIcIybHImM" -H "Content-Type: application/json" -d '{ "registration_ids": [ "lCiKrmbllN8:APA91bHD_CyYH5r7g7XileYY0xAifkSXlKvGn5GnATfHP5_3n9_naRiW69qWGM5d1wP78i-KuFWXhRsxs92bFzfNUujcuw2xB1jpBbJiXb_6MU7F4awjr7NVPOmlZaQZRLf2s4uiP3lZ" ], "data": { "message": "YOUR_MESSAGE" }}'  https://android.googleapis.com/gcm/send

//

import UIKit
import CoreData
import SwiftHTTP
import GoogleMaps

let mainhost = "http://pdnmobileserver.azurewebsites.net"
let googleAPIkey = "AIzaSyDWXy81aAm7qR9qb-AkWSNXhRmuzoUHI1A"
let localLat = 13.854   //7.8900  //13.854 //
let localLon = 100.624471  //98.3983 //100.624471 //
var GCMRegistrationID = "lLt6FW-cC-M:APA91bG7JeP6OSPWIo9TjYFEPN0ShlHUKibcpoAKVTwbHhAvWjYFccAFQqhlPu9sfGL2rhANl_Dd3i1wMHic-ZoN2GuhZ65FSWU3P3Ta_DsiDYYxc5Xs_Mebm-7RnLu46OyRRk1yi1Tr"
let registrationKey = "onRegistrationCompleted"
let messageKey = "onMessageReceived"
let areaIdMax = 18

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate,  GCMReceiverDelegate{

    var window: UIWindow?

    struct placeDetail {
        var Type : Int = 0
        var locationName : String = String()
        var areaName : String = String()
        var locationAddress : String = String()
        var location : CLLocation = CLLocation()
        var AreaId : Int = 0
        var CategoryId : Int = 0
    }
    
    var allPlaces = [placeDetail]()
    var cat3Count: Int = 0
   
    var CategoryId = [Int: String]()
    var placeCount : Int = 0
    
    
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    let subscriptionTopic = "/topics/global"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
         GMSServices.provideAPIKey(googleAPIkey)
       
        //we have to add the explicit type, else the wrong type is inferred. See the vluxe.io article for more info.
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
        
        
        //getPlace()
        
        var configureError:NSError?
        
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        
        print("Sender ID = \(gcmSenderID)")
        // [END_EXCLUDE]
        // Register for remote notifications
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        
        // [END register_for_remote_notifications]
        // [START start_gcm_service]
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
     
        GCMService.sharedInstance().startWithConfig(gcmConfig)
        // [END start_gcm_service]
        

        
        
        return true
    }

    //MARK: Getplace
    
    func getPlace(){
        
        var allPlaces1 = [placeDetail]()
        var allPlaces2 = [placeDetail]()
        
        
        let params: Dictionary<String,AnyObject> = ["Action" : "1"]
        
        
        do {
            let opt = try HTTP.PUT(mainhost + "/api/landmark", parameters: params)
            opt.start { response in
                //do things...
                if let obj: AnyObject =  response.data {
                    
                    let json = JSON(data: obj as! NSData)
                  
                    print(json["LandmarkCats"])
                    for (i, x) in json["LandmarkCats"] {
                        print("CatID = \(x["CategoryId"].int!)")
                        
                        self.CategoryId[x["CategoryId"].int!] = x["Name"].string!

                        for var aId = 1;aId < areaIdMax;aId++ {
                            let params2: Dictionary<String,AnyObject> = ["Action" : "3", "CategoryId" : "3" ,"AreaId" : String(aId)]
                            
                            
                            
                            do {
                                let opt = try HTTP.PUT(mainhost + "/api/landmark", parameters: params2)
                                opt.start { response in
                                    //do things...
                                    //print("=================== By category ====================")
                                    if let obj: AnyObject =  response.data {
                                        
                                        let json = JSON(data: obj as! NSData)
                                        
                                        for (i, x) in json["Landmarks"] {
                                            var a: placeDetail = placeDetail()
                                            a.AreaId = x["AreaId"].int!
                                            a.location = CLLocation(latitude: x["Lat"].double!, longitude: x["Lng"].double!)
                                            a.areaName = x["AreaName"].string!
                                            a.locationName = x["LocationName"].string!
                                            a.CategoryId = x["CategoryId"].int!
                                            a.locationAddress = x["LocationAddress"].string!
                                            a.Type = x["Type"].int!
                                            
                                            allPlaces1.append(a)
                                            
                                        }
                                        
                                        
                                        
                                        if self.placeCount == 303 {
                                            print("Done ======================================= ")
                                            for xx in self.allPlaces {
                                                let cc = xx  as! placeDetail
                                                
                                                print("Name: \(cc.locationName) Cat : \(cc.CategoryId) Area ID : \(cc.AreaId)")
                                            }
                                        }
                                        
                                    }
                                    
                                    // print(self.placeCount)
                                    self.placeCount++;
                                }
                                
                                
                                self.cat3Count++
                                 print("Cat3 = \(self.cat3Count)")
                                
                                if self.cat3Count == areaIdMax - 2 {
                                    print("Done ======================================= ")
                                
                                    for xx in allPlaces1 {
                                        let cc = xx  as! placeDetail
                                    
                                        print("Name: \(cc.locationName) Cat : \(cc.CategoryId) Area ID : \(cc.AreaId)")
                                    }
                                }
                                
                            } catch let error {
                                print("got an error creating the request: \(error)")
                            }
                            
                            let params3: Dictionary<String,AnyObject> = ["Action" : "3", "CategoryId" : "4" ,"AreaId" : String(aId)]
                            
                            
                            do {
                                let opt = try HTTP.PUT(mainhost + "/api/landmark", parameters: params3)
                                opt.start { response in
                                    //do things...
                                    //print("=================== By category ====================")
                                    if let obj: AnyObject =  response.data {
                                        
                                        let json = JSON(data: obj as! NSData)
                                        
                                        for (i, x) in json["Landmarks"] {
                                            var a: placeDetail = placeDetail()
                                            a.AreaId = x["AreaId"].int!
                                            a.location = CLLocation(latitude: x["Lat"].double!, longitude: x["Lng"].double!)
                                            a.areaName = x["AreaName"].string!
                                            a.locationName = x["LocationName"].string!
                                            a.CategoryId = x["CategoryId"].int!
                                            a.locationAddress = x["LocationAddress"].string!
                                            a.Type = x["Type"].int!
                                            
                                            allPlaces2.append(a)
                                            
                                        }
                                        
                                        
                                        
                                        if self.placeCount > 220 {
                                           // print("Done ***************")
                                            for xx in self.allPlaces {
                                                let cc = xx  as! placeDetail
                                                if cc.CategoryId == 4 {
                                                    print("Name: \(cc.locationName) Cat : \(cc.CategoryId) Area ID : \(cc.AreaId)")
                                                }
                                            }
                                        }
                                        
                                    }
                                    
                                    // print(self.placeCount)
                                    
                                    self.placeCount++;
                                }
                                
                                print("Done ******************************** ")
                                
                                for xx in allPlaces2 {
                                    let cc = xx  as! placeDetail
                                    
                                    print("Name: \(cc.locationName) Cat : \(cc.CategoryId) Area ID : \(cc.AreaId)")
                                }
                                
                            } catch let error {
                                print("got an error creating the request: \(error)")
                            }
                        }
                        
                       
                        //print(x)
                    }
                    
                    
                }
                
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
        

    }
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if(registrationToken != nil && connectedToGCM) {
            GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: subscriptionTopic,
                options: nil, handler: {(NSError error) -> Void in
                    if (error != nil) {
                        // Treat the "already subscribed" error more gently
                        if error.code == 3001 {
                            print("Already subscribed to \(self.subscriptionTopic)")
                        } else {
                            print("Subscription failed: \(error.localizedDescription)");
                        }
                    } else {
                        self.subscribedToTopic = true;
                        NSLog("Subscribed to \(self.subscriptionTopic)");
                    }
            })
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        GCMService.sharedInstance().disconnect()
        // [START_EXCLUDE]
        self.connectedToGCM = false
        // [END_EXCLUDE]
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Connect to the GCM server to receive non-APNS notifications
         print("#################################")
        GCMService.sharedInstance().connectWithHandler({
            (NSError error) -> Void in
            if error != nil {
                print("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                print("Connected to GCM")
                // [START_EXCLUDE]
                self.subscribeToTopic()
                // [END_EXCLUDE]
            }
        })
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    //MARK: GCM Delegate
    
    // [START receive_apns_token]
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: NSData ) {
            // [END receive_apns_token]
            // [START get_gcm_reg_token]
            // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
            let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
            instanceIDConfig.delegate = self
            // Start the GGLInstanceID shared instance with that config and request a registration
            // token to enable reception of notifications
            GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
            registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
                kGGLInstanceIDAPNSServerTypeSandboxOption:true]
            GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
                scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
            
            print("^^^^^^^^^^^^")
            print("Get token");
            
            // [END get_gcm_reg_token]
    }
    
    // [START receive_apns_token_error]
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: NSError ) {
            print("Registration for remote notification failed with error: \(error.localizedDescription)")
            // [END receive_apns_token_error]
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                registrationKey, object: nil, userInfo: userInfo)
    }
    
    // [START ack_message_reception]
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
            print("Notification received: \(userInfo)")
            // This works only if the app started the GCM service
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
            // Handle the received message
            // [START_EXCLUDE]
            NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
                userInfo: userInfo)
            // [END_EXCLUDE]
    }
    
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
        fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
            print("Notification received: \(userInfo)")
            // This works only if the app started the GCM service
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
            // Handle the received message
            // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
            // [START_EXCLUDE]
            NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
                userInfo: userInfo)
            handler(UIBackgroundFetchResult.NoData);
            // [END_EXCLUDE]
    }
    // [END ack_message_reception]
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        print("^^^^^^^^^^^^")
        print("Registration");
        if (registrationToken != nil) {
            
     

            
            self.registrationToken = registrationToken
            GCMRegistrationID = registrationToken
            print("Registration Token: \(registrationToken)")
            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            
            
            NSNotificationCenter.defaultCenter().postNotificationName(registrationKey, object: nil, userInfo: userInfo)
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(registrationKey, object: nil, userInfo: userInfo)
        }
    }
    
    // [START on_token_refresh]
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    // [END on_token_refresh]
    
    // [START upstream_callbacks]
    func willSendDataMessageWithID(messageID: String!, error: NSError!) {
        if (error != nil) {
            // Failed to send the message.
        } else {
            // Will send message, you can save the messageID to track the message
        }
    }
    
    func didSendDataMessageWithID(messageID: String!) {
        // Did successfully send message identified by messageID
    }
    // [END upstream_callbacks]
    
    func didDeleteMessagesOnServer() {
        // Some messages sent to this device were deleted on the GCM server before reception, likely
        // because the TTL expired. The client should notify the app server of this, so that the app
        // server can resend those messages.
    }

    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "aa.DDP" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("DDP", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

