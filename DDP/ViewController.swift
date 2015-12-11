//
//  ViewController.swift
//  DDP
//
//  Created by cake on 10/17/2558 BE.
//  Copyright © 2558 cake. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SwiftHTTP
import TZStackView
import CoreData


class ViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, FloatRatingViewDelegate {
    
 
    @IBOutlet weak var searchList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var toImage: UIImageView!
    @IBOutlet weak var pickupImages: UIImageView!
    @IBOutlet weak var mainPrice: UILabel!
    @IBOutlet weak var callTaxiButton: UIButton!
    @IBOutlet weak var topTitleView: UIView!
    
    @IBOutlet weak var mapHeight: NSLayoutConstraint!
    @IBOutlet weak var fromToSelection: UIView!
    
    let vheight : [CGFloat] = [40, 70, 40, 40, 40, 50, 40]
    let gap: CGFloat  = 1;
    
    let topView  = UIView()
    let driverView  = UIView()
    let carView  = UIView()
    let mobileView  = UIView()
    let arriveView = UIView()
    let noteView = UIView()
    let buttomView = UIView()
    var driverInfoView : UIView?
    
    let arrivalTimeLabel = UILabel()
    let arrivalDistance = UILabel()
    let arrivalTimeTextLabel = UILabel()
    let arrivalDistanceLabel = UILabel()
    
   
    @IBOutlet weak var carSelectionView: UIView!
    @IBOutlet weak var utilView: UIView!
   
   
    @IBOutlet weak var fromPlaceLabel: UILabel!
    @IBOutlet weak var fromAddress: UILabel!
   
    @IBOutlet weak var toPlaceLabel: UILabel!
    @IBOutlet weak var toAddress: UILabel!
    
    struct locDetail {
        var name : String = String()
        var address : String = String()
        var location : CLLocation = CLLocation()
        var distance : Double = 0
        var placeID : String = String()
        var CategoryId : Int = 0
    }
    
    var locAll : [locDetail] = []
    var locItems : [String] = [String]()
    
    struct bookmarkLocDetail {
        var name : String = String()
        var phoneNUmber : String = String()
        var location : CLLocation = CLLocation()
    }
    
    var bookmarkLocAll : [bookmarkLocDetail] = []
    
    
    var searchActive : Bool = false
    var filteredTableData : [String] = ["Searching....."]
    
    var fromPlace : locDetail = locDetail()
    var toPlace : locDetail = locDetail()
    var fromOrTo : Bool = true
    
    @IBOutlet weak var fromViewButton: UIView!
    @IBOutlet weak var toViewButton: UIView!
    
    @IBOutlet weak var map: GMSMapView!

    @IBOutlet weak var searchMapView: GMSMapView!
    var placePicker: GMSPlacePicker?
    var placesClient: GMSPlacesClient?
    
    @IBOutlet weak var placeSelectionView: UIView!
    @IBOutlet weak var centerLabel: UIImageView!
    @IBOutlet weak var fromButton: UIButton!
    var locationManager: CLLocationManager?
    
    var carType : [String] =  ["Sedan", "SUV", "Lux car","Van", "Tuk Tuk"]
    var carImage : [String] = ["sedan.png","suv.png" ,"luxSedan.png","van.png", "tuktuk.png"]
    var carImageActive : [String] = ["sedanActive.png","suvActive.png" ,"luxSedanActive.png","vanActive.png", "tuktukActive.png"]
    
    

    // 7 (School) 8 (Other) 12 (Public) has no icon
    
    var placeImage : [String] = ["places.png", "beach.png", "hotel.png", "shopping.png", "foodAndDrink.png","transportation.png","emergency.png", "places.png","rentCarOrBike.png","niteSpot.png","emergency.png","places.png","bookmarkIcon.png"]
    
    var myLocation = CLLocationCoordinate2D(
        latitude: 0,
        longitude: 0
    )
    
    var userJson : JSON?
    var callTaxiResponseJson : JSON?
    
    var locationTimer:NSTimer = NSTimer()
    var loginTimer:NSTimer = NSTimer()
    
    var orderID:String = "";
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var checkGeocode : Bool = true
    
    var tPrice = ""
    var destinationType : Int = 1
    let pending = UIAlertController(title: "Initailizing", message: nil, preferredStyle: .Alert)
    var isPickedUp: Bool = false
    var mapManager = MapManager()
    var firstUpdateTaxiLocation : Bool = true
    var firstUpdateDestinationLocation : Bool = true
    
    var waitingTaxiAlert : UIAlertController?
    
    
    var placeNameTextField: UITextField?
    var phoneNumberTextField: UITextField?
    var commentTextField: UITextField?
    
    var ratingScore : Float = 4.0
    
    let finishAlertView = UIView()
    let ratingView = FloatRatingView()
    let alertViewBookmark = UIView()
    let greyOutView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
  
        //==== Load bookmark from database
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        //1
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Places")
        
        //3
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            let pp = results as! [NSManagedObject]
            for x in pp {
                
                var eLoc : bookmarkLocDetail = bookmarkLocDetail()
                eLoc.name = x.valueForKey("name") as! String
                eLoc.phoneNUmber = x.valueForKey("phoneNumber") as! String
                let llat = x.valueForKey("lat") as! Double
                let llon = x.valueForKey("lon") as! Double
                eLoc.location = CLLocation(latitude: llat, longitude: llon)
                bookmarkLocAll.append(eLoc)
                
                
                

            
            }
            
            print("#######################################")
            print(bookmarkLocAll)

            
            // people = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        
        //==================================
        fromViewButton.backgroundColor = UIColor.whiteColor()
        toViewButton.backgroundColor = UIColor.whiteColor()
        
        
        placeSelectionView.hidden = true
        placeSelectionView.userInteractionEnabled = false
        
        
        centerLabel.layer.masksToBounds = true
        centerLabel.layer.cornerRadius = 8.0
        centerLabel.layer.cornerRadius = 8.0
        centerLabel.layer.borderWidth = 1
        centerLabel.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        
        let border = CALayer()
        
        border.frame = CGRectMake(0, 5, 1, 50)
        
        
        border.backgroundColor = UIColor.lightGrayColor().CGColor;
        
        toViewButton.layer.addSublayer(border)
        
        
        //toViewButton.layer.addBorder(.Left, color: UIColor.lightGrayColor(), thickness: 1)
        
        centerLabel.sizeToFit()
        centerLabel.image = UIImage(named: "arrow.png")
        
        let topH : CGFloat = 40
        let fromToSelectionH : CGFloat = 60
        let utilViewH : CGFloat = 44
        let carSelViewH : CGFloat = 70
        let mapH = self.view.frame.height - topH - fromToSelectionH - utilViewH - carSelViewH - self.statusBarHeight()
        
        /*let mapH = self.view.frame.height - self.topTitleView.frame.height - self.fromToSelection.frame.height - self.utilView.frame.height - self.carSelectionView.frame.height - self.statusBarHeight()
        print("Map height = \(mapH), total frame height = \(self.view.frame.height)")
        print("Top hieght = \(self.topTitleView.bounds.height), from to selection \(self.fromToSelection.frame.height)")
        print("Util hieght = \(self.utilView.frame.height), car selection height \(self.carSelectionView.frame.height),status bar height \(self.statusBarHeight())")*/
        
        dispatch_async(dispatch_get_main_queue()){
            
            self.mapHeight.constant = mapH
            
            
            
            //self.callTaxiButton.frame = CGRectMake(0, 0, 300, 30)
            self.callTaxiButton.layer.cornerRadius = 15
            self.callTaxiButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.callTaxiButton.layer.borderWidth = 2
            self.callTaxiButton.layer.masksToBounds = true;
            
            self.callTaxiButton.userInteractionEnabled = false
            self.callTaxiButton.backgroundColor = UIColor.lightGrayColor()
            
            
            self.pickupImages.image = UIImage(named: "pickupActive.png")
            self.toImage.image = UIImage(named: "destination")
            
            self.searchBar.layer.cornerRadius = 5
            self.searchBar.layer.borderColor = UIColor.whiteColor().CGColor
            self.searchList.layer.cornerRadius = 5
            self.bookmarkButton.layer.cornerRadius = 5
            
            self.searchBar.backgroundColor = UIColor.whiteColor()
            self.searchBar.tintColor = UIColor.whiteColor()
            
            
            let spacing : CGFloat = 10; // the amount of spacing to appear between image and title
            self.bookmarkButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, spacing);
            self.bookmarkButton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
            
            self.bookmarkButton.setImage(UIImage(named: "addBookmark.png"), forState: .Normal)
            
            self.bookmarkButton.imageView!.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin ,
                UIViewAutoresizing.FlexibleWidth ,
                UIViewAutoresizing.FlexibleRightMargin ,
                UIViewAutoresizing.FlexibleTopMargin ,
                UIViewAutoresizing.FlexibleHeight ,
                UIViewAutoresizing.FlexibleBottomMargin]
            
        }
        
        if((prefs.objectForKey("haveLogin")) != nil){
            
            if(prefs.objectForKey("haveLogin") as! String == "yes"){
                //  let email = prefs.objectForKey("username") as! String
                //  let password1 = prefs.objectForKey("password") as! String
                
                loginTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "login", userInfo: nil, repeats: true)
                
                
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    
                    self.performSegueWithIdentifier("toLogin", sender: nil)
                }
            }
            
        } else {
            dispatch_async(dispatch_get_main_queue()){
                
                self.performSegueWithIdentifier("toLogin", sender: nil)
            }
        }
        
        
      
        
        dispatch_async(dispatch_get_main_queue()){
            
            //create an activity indicator
            let indicator = UIActivityIndicatorView(frame: self.pending.view.bounds)
            indicator.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
            indicator.color = UIColor.lightGrayColor()
        
            //add the activity indicator as a subview of the alert controller's view
            self.pending.view.addSubview(indicator)
            indicator.userInteractionEnabled = false // required otherwise if there buttons in the UIAlertController you will not be able to press them
            indicator.startAnimating()
        
            self.presentViewController(self.pending, animated: true, completion: nil)
        }
     
        
        
  
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "RegistarionComplete:", name: registrationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onMessageReceived:", name: messageKey, object: nil)

        
        
        
   
        
        locationManager = CLLocationManager()
        locationManager?.delegate  = self;
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        //update when the different distance is greater than 10 meters
        locationManager?.distanceFilter = 50.0;
        
        if CLLocationManager.locationServicesEnabled() {
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("8") == true){
                
                if (locationManager?.respondsToSelector("requestWhenInUseAuthorization") != nil) {
                    locationManager?.requestWhenInUseAuthorization()
                                      //locationManager?.startUpdatingLocation()
                }
                //else {
                //locationManager?.startUpdatingLocation()
                //}
            }
        }
        
        locationManager?.startUpdatingLocation()
        

        map.myLocationEnabled = true
        
       /* let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = map*/
        
        
        placesClient = GMSPlacesClient()
        var locT : locDetail = locDetail()
        locT.address = ""
        locT.name = ""
        
        locAll.append(locT)
        
        
     
       
   
      
        
    }

    
    func login(){
        print(prefs.objectForKey("email")!)
        
        
        let params: Dictionary<String,AnyObject> = ["Email" : prefs.objectForKey("email")!,"GCMRegistrationID" : GCMRegistrationID]
        
        do {
            let opt = try HTTP.PUT(mainhost + "/api/startup", parameters: params)
            opt.start { response in
                //do things...
                if let obj: AnyObject =  response.data {
                    
                    self.userJson = JSON(data: obj as! NSData)
                    print(self.userJson)
                    print("*************************************************************")
                    if self.userJson!["Status"].string ==  "SUCCESS" {
                        print("************************* SUCCESS *****************************")
                        
                        dispatch_async(dispatch_get_main_queue()){
                            
                            self.pending.dismissViewControllerAnimated(true, completion: nil)
                        }
                        
                        self.loginTimer.invalidate()
                    } else {
                        
                    }
                }
                
            }
            
        } catch let error {
            print("got an error creating the request: \(error)")
        }
        
        

    }
    
    //MARK: Messagging callbacks
    
    func RegistarionComplete(notification:NSNotification){
        
    }
    
    func onMessageReceived(notification:NSNotification){
        let userInfo = notification.userInfo as! Dictionary<String,String>
        print("__________________________")
        
        if(userInfo["MessageType"] == "2"){
            print("Confirm")
            
            self.dismissViewControllerAnimated(false, completion: nil)
            
            isPickedUp = false
            destinationType = 1
            firstUpdateTaxiLocation = true
            locationTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "checkTaxiLocation", userInfo: nil, repeats: true)
            
            
            var yy : [CGFloat] = [0,0,0,0,0,0,0]
            var ycc : CGFloat = 0;
            for var i = 1;i < vheight.count;i++ {
                ycc = ycc + vheight[i-1] + gap
                yy[i] = ycc
                print(yy[i])
            }
            
            topView.frame = CGRectMake(0, yy[0], self.view.frame.width, vheight[0])
            driverView.frame = CGRectMake(0, yy[1], self.view.frame.width, vheight[1])
            carView.frame = CGRectMake(0, yy[2], self.view.frame.width, vheight[2])
            mobileView.frame = CGRectMake(0, yy[3], self.view.frame.width, vheight[3])
            arriveView.frame = CGRectMake(0, yy[4], self.view.frame.width, vheight[4])
            noteView.frame = CGRectMake(0, yy[5], self.view.frame.width, vheight[5])
            buttomView.frame = CGRectMake(0, yy[6], self.view.frame.width, vheight[6])
            
            
            utilView.hidden = true
            utilView.userInteractionEnabled = false
            carSelectionView.hidden = true
            carSelectionView.userInteractionEnabled = false
         
            print("viewh = \(self.view.frame.height) viewW = \(self.view.frame.width)")
            
            let height: CGFloat = 326
            
            driverInfoView = UIView(frame: CGRectMake(0, self.view.frame.height - height, self.view.frame.width, height))
            driverInfoView!.backgroundColor=UIColor.darkGrayColor()
            
            driverInfoView!.translatesAutoresizingMaskIntoConstraints = false
          
            self.view.addSubview(driverInfoView!)
     
            
            
            
            let leftEdge : CGFloat = 10
            
            //Top View
            
            let label = UILabel(frame: CGRectMake(0, 0, 100, 30))
            label.center = CGPointMake(100/2 + leftEdge, vheight[0]/2)
            label.textAlignment = NSTextAlignment.Left
            label.text = "THB " + self.tPrice
            label.textColor = UIColor.whiteColor()
            topView.addSubview(label)
            
            //Driver View
            
            let imageView = UIImageView(frame:CGRectMake(0, 0, 60, 60));
            imageView.center = CGPointMake(60/2 + 10, vheight[1]/2)
            imageView.image = NSURL(string: userInfo["DriverPicture"]!)
                .flatMap { NSData(contentsOfURL: $0) }
                .flatMap { UIImage(data: $0) }
            driverView.addSubview(imageView)
            
            let deiverNameLabek = UILabel(frame: CGRectMake(0, 0, 100, 30))
            deiverNameLabek.center = CGPointMake(self.view.frame.width/2 - 100/2, vheight[1]/2)
            deiverNameLabek.textAlignment = NSTextAlignment.Left
            deiverNameLabek.text = userInfo["DriverName"]
            deiverNameLabek.textColor = UIColor.whiteColor()
            driverView.addSubview(deiverNameLabek)
            
            let licensePlateNumber = UILabel(frame: CGRectMake(0, 0, 70, 30))
            licensePlateNumber.center = CGPointMake(self.view.frame.width - 70/2 - leftEdge, vheight[1]/2)
            licensePlateNumber.textAlignment = NSTextAlignment.Center
            licensePlateNumber.text = userInfo["DriverLicensePlate"]
            licensePlateNumber.textColor = UIColor.blackColor()
            licensePlateNumber.layer.cornerRadius = 5
            licensePlateNumber.layer.backgroundColor = UIColor.init(hexString: "FF8000").CGColor
            driverView.addSubview(licensePlateNumber)
            
            
            //Car View
            
            
            //Mobile View
    
            let mobileLabel = UILabel(frame: CGRectMake(0, 0, 200, 30))
            mobileLabel.center = CGPointMake(200/2 + leftEdge, vheight[3]/2)
            mobileLabel.textAlignment = NSTextAlignment.Left
            mobileLabel.text = "Mobile : " + userInfo["DriverMobile"]!
            mobileLabel.textColor = UIColor.whiteColor()
            mobileView.addSubview(mobileLabel)

            
            //ArriveView2
            
            arrivalTimeTextLabel.frame = CGRectMake(0, 0, 100, 30)
            arrivalTimeTextLabel.center = CGPointMake(100/2 + leftEdge, vheight[4]/2)
            arrivalTimeTextLabel.text = "Arrival time : "
            arrivalTimeTextLabel.textColor = UIColor.whiteColor()
            arriveView.addSubview(arrivalTimeTextLabel)
            
            arrivalTimeLabel.frame = CGRectMake(0, 0, 100, 30)
            arrivalTimeLabel.center = CGPointMake(100/2 + 100 + leftEdge, vheight[4]/2)
            arrivalTimeLabel.text = " 00 Min"
            arrivalTimeLabel.textColor = UIColor.greenColor()
            arriveView.addSubview(arrivalTimeLabel)
            
            arrivalDistanceLabel.frame = CGRectMake(0, 0, 100, 30)
            arrivalDistanceLabel.center = CGPointMake(self.view.frame.width/2 + 100/2 + leftEdge, vheight[4]/2)
            arrivalDistanceLabel.text = "Distance : "
            arrivalDistanceLabel.textColor = UIColor.whiteColor()
            arriveView.addSubview(arrivalDistanceLabel)
            
            arrivalDistance.frame = CGRectMake(0, 0, 100, 30)
            arrivalDistance.center = CGPointMake(self.view.frame.width/2 + 100 + 100/2 + leftEdge, vheight[4]/2)
            arrivalDistance.text = " 00 Km"
            arrivalDistance.textColor = UIColor.greenColor()
            arriveView.addSubview(arrivalDistance)
            
            //checkTaxiLocation()
            
            //noteView
            
            
            //ButtomView
            
            let button   = UIButton(type: UIButtonType.System) as UIButton
            button.frame = CGRectMake(0, 0, 100, 30)
            button.center = CGPointMake(self.view.frame.width/2 , vheight[6]/2)
            button.backgroundColor = UIColor.clearColor()
            button.layer.cornerRadius = 15
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.layer.borderWidth = 2
            button.layer.backgroundColor = UIColor.clearColor().CGColor
            button.layer.masksToBounds = true;
            button.setTitle("Cancel", forState: UIControlState.Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.addTarget(self, action: "cancelAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            buttomView.addSubview(button)
            
            //Change color
            
            topView.backgroundColor = UIColor.blackColor()
            driverView.backgroundColor = UIColor.grayColor()
            carView.backgroundColor = UIColor.grayColor()
            mobileView.backgroundColor = UIColor.grayColor()
            arriveView.backgroundColor = UIColor.grayColor()
            noteView.backgroundColor = UIColor.grayColor()
            buttomView.backgroundColor = UIColor.grayColor()
            
            self.driverInfoView!.addSubview(topView)
            self.driverInfoView!.addSubview(driverView)
            self.driverInfoView!.addSubview(carView)
            self.driverInfoView!.addSubview(mobileView)
            self.driverInfoView!.addSubview(arriveView)
            self.driverInfoView!.addSubview(noteView)
            self.driverInfoView!.addSubview(buttomView)
            
            dispatch_async(dispatch_get_main_queue()){
                let mapH = self.view.frame.height - self.topTitleView.frame.height - self.fromToSelection.frame.height - height - self.statusBarHeight()
                self.mapHeight.constant = mapH
            }

            
       
            
        } else if(userInfo["MessageType"] == "3"){
            print("Pickup")
            firstUpdateDestinationLocation = true
            destinationType = 2
            isPickedUp = true
            
            arriveView.removeFromSuperview()
            noteView.removeFromSuperview()
            
            var yy : [CGFloat] = [0,0,0,0,0]
            var ycc : CGFloat = 0;
            
            var keepIdx : [Int] = [0,1,2,3,6]
            
            for var i = 1;i < keepIdx.count;i++ {
                ycc = ycc + vheight[keepIdx[i-1]] + gap
                yy[i] = ycc
                print(yy[i])
            }
            
            topView.frame = CGRectMake(0, yy[0], self.view.frame.width, vheight[0])
            driverView.frame = CGRectMake(0, yy[1], self.view.frame.width, vheight[1])
            carView.frame = CGRectMake(0, yy[2], self.view.frame.width, vheight[2])
            mobileView.frame = CGRectMake(0, yy[3], self.view.frame.width, vheight[3])
            buttomView.frame = CGRectMake(0, yy[4], self.view.frame.width, vheight[6])

            driverInfoView?.frame = CGRectMake(0, self.view.frame.height - 236, self.view.frame.width, 236)
            
            let mapH = self.view.frame.height - self.topTitleView.frame.height - self.fromToSelection.frame.height -             self.driverInfoView!.frame.height - statusBarHeight()
            mapHeight.constant = mapH

            
        } else if(userInfo["MessageType"] == "4"){
            print("Drop off")
            isPickedUp = false
            locationTimer.invalidate()
            
            let mapH = self.view.frame.height - self.topTitleView.frame.height - self.fromToSelection.frame.height - self.utilView.frame.height - self.carSelectionView.frame.height - self.statusBarHeight()
            self.mapHeight.constant = mapH

            
            mobileView.removeFromSuperview()
            carView.removeFromSuperview()
            buttomView.removeFromSuperview()
            
            
            
            var yy : [CGFloat] = [0,0]
            var ycc : CGFloat = 0;
            
            var keepIdx : [Int] = [0,1]
            
            for var i = 1;i < keepIdx.count;i++ {
                ycc = ycc + vheight[keepIdx[i-1]] + gap
                yy[i] = ycc
                print(yy[i])
            }
            
            topView.frame = CGRectMake(0, yy[0], self.view.frame.width, vheight[0])
            driverView.frame = CGRectMake(0, yy[1], self.view.frame.width, vheight[1])
            
            driverInfoView?.frame = CGRectMake(0, self.view.frame.height - 111, self.view.frame.width, 111)
            
            showFinishAlertView()
            
           /* let alertController = UIAlertController(title: "Default Style", message: "Arrived!", preferredStyle: .Alert)

            let commentAction = UIAlertAction(title: "Finish", style: .Default) { (_) in
                //let commentField = alertController.textFields![0] as UITextField
                self.utilView.hidden = false
                self.utilView.userInteractionEnabled = true
                self.carSelectionView.hidden = false
                self.carSelectionView.userInteractionEnabled = true
                
                self.driverInfoView?.removeFromSuperview()
                let mapH = self.view.frame.height - self.topTitleView.frame.height - self.fromToSelection.frame.height - self.utilView.frame.height - self.carSelectionView.frame.height - self.statusBarHeight()
                self.mapHeight.constant = mapH
                
                
                self.map.clear()
                self.checkGeocode = true
            }
            
          
            
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "Comment"
              
            }
            
            alertController.addAction(commentAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }*/
        }
    }
    
    
    
    func showFinishAlertView(){
        
        disableBackgroudView()
        let gap : CGFloat = 20
        
        finishAlertView.frame = CGRectMake(gap, self.view.bounds.height*0.5 - 200 - 20 , self.view.bounds.width - gap*2, 220)
        finishAlertView.layer.cornerRadius = 8
        finishAlertView.backgroundColor = UIColor.whiteColor()
        let label = UILabel()
        
        
        ratingView.frame = CGRectMake(finishAlertView.frame.width/2 - 200/2, 40, 200, 30)
       // ratingView.center = CGPointMake(finishAlertView.frame.width/2 - 200/2, 40)
        ratingView.emptyImage = UIImage(named: "StarEmpty")
        ratingView.fullImage = UIImage(named: "StarFull")
        // Optional params
        ratingView.delegate = self
        //ratingView.
        ratingView.contentMode = UIViewContentMode.ScaleAspectFit
        ratingView.maxRating = 5
        ratingView.minRating = 1
        ratingView.rating = 4
        ratingView.editable = true
        ratingView.halfRatings = true
        ratingView.floatRatings = false
        
        
        let labelW:CGFloat = 100
        label.frame = CGRectMake(finishAlertView.frame.width/2 - labelW/2, 10, labelW, 20)
        label.text = "Arrived"
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor(hexString: "FF6699")
        let placeName : UITextField = UITextField(frame: CGRectMake(gap,finishAlertView.frame.height-50-50,finishAlertView.frame.width - 2*gap,50))
        placeName.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        placeName.placeholder = " Comment"
        placeName.layer.cornerRadius = 5
        commentTextField = placeName
        
        
        
        let bHight : CGFloat = 30
        let bWidth : CGFloat = 100
        let doneButton: UIButton = UIButton(frame: CGRectMake(finishAlertView.frame.width/2 - bWidth/2,finishAlertView.frame.height  - bHight-10, bWidth ,bHight))
        doneButton.setTitle("Finish", forState: UIControlState.Normal)
        
        doneButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        doneButton.layer.cornerRadius = bHight/2
        doneButton.backgroundColor = UIColor(hexString: "339933")
        doneButton.addTarget(self, action: "finishButtonAction:", forControlEvents: .TouchUpInside)
        
        dispatch_async(dispatch_get_main_queue()){
            self.greyOutView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            let bc = UIColor.blackColor()
            let semi = bc.colorWithAlphaComponent(0.5)
            self.greyOutView.backgroundColor = semi
            self.view.addSubview(self.greyOutView)
            self.finishAlertView.addSubview(self.ratingView)
            self.finishAlertView.addSubview(doneButton)
            self.finishAlertView.addSubview(placeName)
            self.finishAlertView.addSubview(label)
            self.view.addSubview(self.finishAlertView)
            
            
        }
        
   
    }
    
    
    
    func finishButtonAction(sender: UIButton!){
        
        print(commentTextField?.text)
        //commentTextField?.resignFirstResponder()
        
        //self.utilView.userInteractionEnabled = true
        
        //self.carSelectionView.userInteractionEnabled = true
        
        
        var params: Dictionary<String,AnyObject> = ["Action":"1"]
        params["Order"] = self.orderID
        params["RatingValue"] = String(ratingScore)
        print(params)
        
        do {
            let opt = try HTTP.PUT(mainhost + "/api/rating", parameters: params)
            opt.start { response in
                //do things...
                if let obj: AnyObject =  response.data {
                    
                    let json = JSON(data: obj as! NSData)
                    print(json)
                        if json["Status"].string ==  "SUCCESS" {
                        
                            
                        }
 
                } else {
                        
                    
                }
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }

        
        enableBackgroudView()
       
        dispatch_async(dispatch_get_main_queue()){
            self.finishAlertView.removeFromSuperview()
            self.carSelectionView.hidden = false
            self.utilView.hidden = false
            self.driverInfoView?.removeFromSuperview()
            let mapH = self.view.frame.height - self.topTitleView.frame.height - self.fromToSelection.frame.height - self.utilView.frame.height - self.carSelectionView.frame.height - self.statusBarHeight()
            self.mapHeight.constant = mapH
            
            self.view.endEditing(true)
            self.map.clear()
            self.checkGeocode = true
            
        }
        
    }
    
    func cancelAction(sender:UIButton!)
    {
        self.map.clear()
        let mapH = self.view.frame.height - self.topTitleView.frame.height - self.fromToSelection.frame.height - self.utilView.frame.height - self.carSelectionView.frame.height - statusBarHeight()
        mapHeight.constant = mapH
        locationTimer.invalidate()
        var params: Dictionary<String,String> = ["Action" : "5"]
        
        params["Id"] = self.orderID
        
        
        
        print(params)
        
        do {
            let opt = try HTTP.PUT(mainhost + "/api/order", parameters: params)
            opt.start { response in
                //do things...
                if let obj: AnyObject =  response.data {
                    
                    self.callTaxiResponseJson = JSON(data: obj as! NSData)
                    let rStatus : String = self.callTaxiResponseJson!["Status"].string!
                    print("Status = \(rStatus)");
                    
                    if(rStatus == "SUCCESS"){
                        let alertController = UIAlertController(title: "Cancel complete", message: "", preferredStyle: .Alert)
                        let finishlAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (_) in
                            self.utilView.hidden = false
                            self.utilView.userInteractionEnabled = true
                            self.carSelectionView.hidden = false
                            self.carSelectionView.userInteractionEnabled = true
                            
                            self.driverInfoView?.removeFromSuperview()

                        }
                        alertController.addAction(finishlAction)
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }

                        
                        
                    } else if(rStatus == "FAIL") {
                        
                        let alertController = UIAlertController(title: "Cancel incomplete", message: "Please try again", preferredStyle: .Alert)
                        let finishlAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (_) in
                            
                        }
                        alertController.addAction(finishlAction)
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }

                        
                    }
                    
                    print(self.callTaxiResponseJson)
                
                    
                }
                
                // self.startTimer()
                
            }
        } catch let error {
                print("got an error creating the request: \(error)")
        }
    }
    
    func checkTaxiLocation(){
    
        //https://maps.googleapis.com/maps/api/distancematrix/json?origins=Seattle&destinations=San+Francisco&key=AIzaSyDWXy81aAm7qR9qb-AkWSNXhRmuzoUHI1A
        
        
      //  var urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(taxiLat),\(taxiLon)&destinations=\(fLat),\(fLon)&mode=driving&key=\(googleWebAPIkey)"
        
        let params: Dictionary<String,AnyObject> = ["Action" : "2","OrderId" : self.orderID]
        
        do {
            let opt = try HTTP.PUT(mainhost + "/api/track", parameters: params)
            opt.start { response in
                //do things...
                if let obj: AnyObject =  response.data {
                    
                    let taxiLoc = JSON(data: obj as! NSData)
                    //print("*************************************************************")
                    //print(taxiLoc["CurLocation"])
                    
                    let fromLat = self.fromPlace.location.coordinate.latitude
                    let fromLon = self.fromPlace.location.coordinate.longitude
                    
                    //var taxiLoc =
                    
                    let taxiLatF = taxiLoc["CurLocation"]["Lat"].double!
                    let taxiLonF = taxiLoc["CurLocation"]["Lng"].double!
                    
                    let taxiLat : String = String(taxiLatF)
                    let taxiLon : String = String(taxiLonF)
                    
                    //print(distanceMatrix)
                    
                    //Change map zoom lavel
                    
                    dispatch_async(dispatch_get_main_queue()){
                        var position1 : CLLocationCoordinate2D?
                        if self.destinationType == 1 {
                            
                            if self.firstUpdateTaxiLocation == true {
                                self.animateBoundsNorth(self.fromPlace.location.coordinate.latitude, southWestLon: self.fromPlace.location.coordinate.longitude, northEastLat: taxiLatF, northEastLon: taxiLonF)
                                if taxiLatF != 0 {
                                    self.firstUpdateTaxiLocation = false
                                }
                            }
                        
                       
                        
                            position1 = CLLocationCoordinate2DMake(self.fromPlace.location.coordinate.latitude, self.fromPlace.location.coordinate.longitude)
                        } else {
                            
                            if self.firstUpdateDestinationLocation == true {
                            self.animateBoundsNorth(self.toPlace.location.coordinate.latitude, southWestLon: self.toPlace.location.coordinate.longitude, northEastLat: taxiLatF, northEastLon: taxiLonF)
                                if taxiLatF != 0 {
                                    self.firstUpdateDestinationLocation = false
                                }
                            }
                            
                            
                            position1 = CLLocationCoordinate2DMake(self.toPlace.location.coordinate.latitude, self.toPlace.location.coordinate.longitude)
                        }
                        self.map.clear()
                        if self.isPickedUp == false {
                        
                            let marker = GMSMarker(position: position1!)
                            marker.map = self.map
                            marker.icon = UIImage(named: "customerPin.png")
                            //marker.icon =
                        
                            let  position2 = CLLocationCoordinate2DMake(taxiLatF, taxiLonF)
                            let marker2 = GMSMarker(position: position2)
                            marker2.map = self.map
                            marker2.icon = UIImage(named: "driverPin.png")
  
                            self.mapManager.directionsUsingGoogle(from: position2, to: position1!) { (route, directionInformation, error) -> () in
                                
                                if(error != nil){
                                    
                                    print(error!)
                                }else{
                                    
                                    print(route!)
                                    let tt : GMSPolyline = route!
                                    tt.map = self.map
                                    tt.strokeWidth = 5
                                    tt.strokeColor = UIColor.redColor()
                                }
                            }
                            
                        } else {
                            let marker = GMSMarker(position: position1!)
                            marker.map = self.map
                            marker.icon = UIImage(named: "destinationPin.png")
                            //marker.icon =
                            
                            let  position2 = CLLocationCoordinate2DMake(taxiLatF, taxiLonF)
                            let marker2 = GMSMarker(position: position2)
                            marker2.map = self.map
                            marker2.icon = UIImage(named: "ontaxiPin.png")
                            
                            self.mapManager.directionsUsingGoogle(from: position2, to: position1!) { (route, directionInformation, error) -> () in
                                
                                if(error != nil){
                                    
                                    print(error!)
                                }else{
                                    
                                    print(route!)
                                    let tt : GMSPolyline = route!
                                    tt.map = self.map
                                    tt.strokeWidth = 5
                                    tt.strokeColor = UIColor.init(hexString: "4B8C81")
                                }
                            }
                        }
                        
                        
                        
                    }
                    
                    //origins=\(taxiLat),\(taxiLon)&destinations=\(fLat),\(fLon)&mode=driving&key=\(googleWebAPIkey)"
                    
                    let urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(taxiLat),\(taxiLon)&destinations=\(fromLat),\(fromLon)&mode=driving&key=\(googleAPIkey)"
                    
                    do {
                        
                        let opt1 = try HTTP.POST(urlString, parameters: nil)
                        opt1.start { response in
                            if let obj2: AnyObject =  response.data {
                                let distanceMatrix = JSON(data: obj2 as! NSData)
                                //print(distanceMatrix)
                                dispatch_async(dispatch_get_main_queue()) {
                                    
                                    if let ETA = distanceMatrix["rows"][0]["elements"][0]["duration"]["text"].string{
                                        if let dd = distanceMatrix["rows"][0]["elements"][0]["distance"]["text"].string{
                   
                                        
                                            self.arrivalTimeLabel.text = ETA
                                            self.arrivalDistance.text = dd
                                        }
                                    }
                                }
                            }
                        }
                    } catch let error {
                        print("got an error creating the request: \(error)")
                    }
                    
                
                }
                
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        ratingScore = self.ratingView.rating
       // print("Rating = \(ratingScore)")
        //self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        ratingScore = self.ratingView.rating
       // print("Rating = \(ratingScore)")
        //self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //MARK: Handle location update
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //manager.stopUpdatingLocation()
        let location = locations[0]
        //let geoCoder = CLGeocoder()
        
        
        let clocation = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        
        myLocation = clocation
      
        
        //self.delegate.myCurrentLocation = myLocation
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(myLocation.latitude, longitude: myLocation.longitude, zoom: 12 )
        
        //let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)

       map.camera = camera
        if checkGeocode == true {
            let geocoder = GMSGeocoder()
        
            // 2
            geocoder.reverseGeocodeCoordinate(clocation) { response, error in
                if let address = response?.firstResult() {
                
                    let lines = address.lines as! [String]
                    let add1 = lines.joinWithSeparator(" ")
                    self.fromPlace.name = "Current location"
                    self.fromPlace.address = self.extractWords(add1, count: 3)
                    self.fromPlace.distance = 0
                    self.fromPlace.location = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    dispatch_async(dispatch_get_main_queue()){
                        self.fromPlaceLabel.text = "Current location"
                        self.fromAddress.text = self.extractWords(add1,count: 4)
                    
                    
                    }

                    UIView.animateWithDuration(0.25) {
                    self.view.layoutIfNeeded()
                    }
                }
            }
            checkGeocode = false
        }
        
    }
    
     //MARK: Button actions
    
    
    @IBAction func bookMarkAction(sender: AnyObject) {
        print("Adding bookmark !!")
        
        let gap : CGFloat = 20
        alertViewBookmark.frame = CGRectMake(gap, self.view.bounds.height*0.5 - 200 - 20 , self.view.bounds.width - gap*2, 200)
        alertViewBookmark.layer.cornerRadius = 8
        alertViewBookmark.backgroundColor = UIColor.whiteColor() //clearColor()
        
        let label = UILabel()
        
        let labelW:CGFloat = 200
        label.frame = CGRectMake(alertViewBookmark.frame.width/2 - labelW/2, 10, labelW, 20)
        label.text = "Add Bookmark"
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor(hexString: "FF6699")
       
        let placeName : UITextField = UITextField(frame: CGRectMake(gap,45,alertViewBookmark.frame.width - 2*gap,30))
        placeName.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        placeName.placeholder = "Enter place name"
        placeName.layer.cornerRadius = 5
        self.placeNameTextField  = placeName
        
        let phoneNumber : UITextField = UITextField(frame: CGRectMake(gap,90,alertViewBookmark.frame.width - 2*gap,30))
        phoneNumber.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        phoneNumber.placeholder = "Enter phonenumber"
        phoneNumber.layer.cornerRadius = 5
        self.phoneNumberTextField = phoneNumber
        
        let bHight : CGFloat = 40
        let doneButton: UIButton = UIButton(frame: CGRectMake(0,alertViewBookmark.frame.height  - bHight, alertViewBookmark.frame.width/2,bHight))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        let Tborder = CALayer()
        Tborder.frame = CGRectMake(0, 0, doneButton.frame.width, 1)
        Tborder.backgroundColor = UIColor.lightGrayColor().CGColor
        doneButton.layer.addSublayer(Tborder)
        let Bborder = CALayer()
        Bborder.frame = CGRectMake(doneButton.frame.width - 1, 0, 1, doneButton.frame.height)
        
        Bborder.backgroundColor = UIColor.lightGrayColor().CGColor
        doneButton.layer.addSublayer(Bborder)
        doneButton.addTarget(self, action: "doneButtonAction:", forControlEvents: .TouchUpInside)
        
        let cancelButton: UIButton = UIButton(frame: CGRectMake(alertViewBookmark.frame.width/2,alertViewBookmark.frame.height - bHight, alertViewBookmark.frame.width/2,bHight))
        let Tborder2 = CALayer()
        Tborder2.frame = CGRectMake(0, 0, doneButton.frame.width, 1)
        Tborder2.backgroundColor = UIColor.lightGrayColor().CGColor
        cancelButton.layer.addSublayer(Tborder2)
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancelButtonAction:", forControlEvents: .TouchUpInside)
        
        
        
        
        
        dispatch_async(dispatch_get_main_queue()){
            self.greyOutView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            let bc = UIColor.blackColor()
            let semi = bc.colorWithAlphaComponent(0.5)
            self.greyOutView.backgroundColor = semi
            self.view.addSubview(self.greyOutView)
            
            self.alertViewBookmark.addSubview(label)
            self.alertViewBookmark.addSubview(cancelButton)
            self.alertViewBookmark.addSubview(doneButton)
            self.alertViewBookmark.addSubview(placeName)
            self.alertViewBookmark.addSubview(phoneNumber)
            self.disableBackgroudView()
            self.view.addSubview(self.alertViewBookmark)
            
            
        }
   
        
  
    }
    
    
    func doneButtonAction(sender: UIButton!){
        print("Done")
        
        print(self.placeNameTextField!.text)
        print(self.phoneNumberTextField!.text)
        if self.placeNameTextField!.text?.isEmpty == false {
            
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let entity =  NSEntityDescription.entityForName("Places",
            inManagedObjectContext:managedContext)
        
        let place = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        //3
        place.setValue(self.placeNameTextField!.text, forKey: "name")
        place.setValue(self.phoneNumberTextField!.text, forKey: "phoneNumber")
        place.setValue(self.myLocation.latitude, forKey: "lat")
        place.setValue(self.myLocation.longitude, forKey: "lon")
        
        //4
             do {
                try managedContext.save()
                print("Adding to database")
                //5
                var eLoc : bookmarkLocDetail = bookmarkLocDetail()
                eLoc.name = self.placeNameTextField!.text!
                eLoc.phoneNUmber = self.phoneNumberTextField!.text!
            
                eLoc.location = CLLocation(latitude: self.myLocation.latitude, longitude: self.myLocation.longitude)
                self.bookmarkLocAll.append(eLoc)
            
                dispatch_async(dispatch_get_main_queue()){
                    self.enableBackgroudView()
                    self.alertViewBookmark.removeFromSuperview()
                }
            
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        
        
        }
    
        
        
   
    }
    
    func cancelButtonAction(sender: UIButton!){
        dispatch_async(dispatch_get_main_queue()){
            self.enableBackgroudView()
            self.alertViewBookmark.removeFromSuperview()
        }
    }

    func disableBackgroudView(){
        dispatch_async(dispatch_get_main_queue()){
  
           
            self.carSelectionView.userInteractionEnabled = false
            self.utilView.userInteractionEnabled = false
            self.searchBar.userInteractionEnabled = false
            self.fromToSelection.userInteractionEnabled = false
            self.searchList.userInteractionEnabled = false
            self.placeSelectionView.userInteractionEnabled = false
            self.map.userInteractionEnabled = false
        }
    }
    
    func enableBackgroudView(){
        dispatch_async(dispatch_get_main_queue()){
            self.greyOutView.removeFromSuperview()
            self.carSelectionView.userInteractionEnabled = true
            self.utilView.userInteractionEnabled = true
            self.searchBar.userInteractionEnabled = true
            self.fromToSelection.userInteractionEnabled = true
            self.searchList.userInteractionEnabled = true
            self.placeSelectionView.userInteractionEnabled = true
            self.map.userInteractionEnabled = true
        }
    }
    
    @IBAction func callTaxiAction(sender: AnyObject) {
        
        //timer1 = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "checkTaxi", userInfo: nil, repeats: true)
        
        taxiCalling();
     
    }
    
    
    
    func taxiCalling(){
        
    
        
        var params: Dictionary<String,String> = ["Action" : "10"]
        
        params["OrderDateTime"] = "2015-09-01 09:10"
        params["PickupDateTime"] = "2015-09-01 09:10"
        params["BaselinePrice"] = "300"
        params["Incentive"] = "10"
        params["TotalPrice"] = "310"
        params["FromName"] = fromPlace.name
        params["FromAddress"] = fromPlace.address
        params["ToName"] = toPlace.name
        params["ToAddress"] = toPlace.address
        params["FromLat"] = "\(fromPlace.location.coordinate.latitude)"
        params["FromLng"] = "\(fromPlace.location.coordinate.longitude)"
        params["ToLat"] = "\(toPlace.location.coordinate.latitude)"
        params["ToLng"] = "\(toPlace.location.coordinate.longitude)"
        params["IsSelfRide"] = "false"
        params["SelfRideString"] = "1"
        params["TimePeriodCode"] = "0"
        params["Member"] = userJson!["AuthenMember"]["Id"].string
        params["PassengerName"] = userJson!["AuthenMember"]["LastName"].string!  + " " + userJson!["AuthenMember"]["FirstName"].string!
        params["PassengerMobile"] = userJson!["AuthenMember"]["Mobile"].string!
        params["OrderTimeType"] = "1"
        params["PassengerMg"] = "Damn"
        params["AdditionalLocationString"] = ""
        params["CarTypeCode"] = "1"
        
        
        
        print(params)
        
        do {
            let opt = try HTTP.PUT(mainhost + "/api/order", parameters: params)
            opt.start { response in
                //do things...
                if let obj: AnyObject =  response.data {
                    
                    self.callTaxiResponseJson = JSON(data: obj as! NSData)
                    let rStatus : String = self.callTaxiResponseJson!["Status"].string!
                    print("Status = \(rStatus)");
                    
                    if(rStatus == "SUCCESS"){
                        //Start timer
                        self.orderID = self.callTaxiResponseJson!["SubmittedOrder"]["Id"].string!
                      
                        let lOrderID : String = self.callTaxiResponseJson!["SubmittedOrder"]["Id"].string!
                        
                        //let timedClock = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("Counting:"), userInfo: nil, repeats: true)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.startTimer(lOrderID)
                        
                            self.waitingTaxiAlert = UIAlertController(title: "Waiting", message: "Please wait for taxi. \n\n", preferredStyle: UIAlertControllerStyle.Alert)
                            self.presentViewController(self.waitingTaxiAlert!, animated: true, completion: nil)
                            
                            let indicator = UIActivityIndicatorView()
                           // indicator.center = CGPointMake(self.waitingTaxiAlert!.view.frame.width/2, self.waitingTaxiAlert!.view.frame.height - 10)
                            
                            //let views = ["pending" : self.waitingTaxiAlert!.view, "indicator" : indicator]
                            //var constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[indicator]-(-50)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
                           // NSLayoutConstraint.constraintsWithVisualFormat("V:[indicator]-(-50)-|", options: nil, metrics: nil, views: views)
                            //constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[indicator]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
                            //self.waitingTaxiAlert!.view.addConstraints(constraints)
                            
                            
                            indicator.userInteractionEnabled = false
                            indicator.color = UIColor.blackColor()
                            indicator.center = CGPointMake(130.5, 85.5);
                            
                            //indicator.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]

                            self.waitingTaxiAlert!.view.addSubview(indicator)
                            indicator.userInteractionEnabled = false // required otherwise if there buttons in the UIAlertController you will not be able to press them
                            indicator.startAnimating()

                        
                        }
                        
                        print("SUCESS with order ID")
                        print(self.orderID)
                        
                        
                        
                        
                    } else if(rStatus == "FAIL") {
                       
                        
                        var err_message = ""
                        if(self.callTaxiResponseJson!["ErrorMessage"] == "No signed-in driver"){
                            err_message = "No driver nearby."
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            let alert = UIAlertController(title: "Alert", message: err_message, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }

                    }
                    
                    print(self.callTaxiResponseJson)
                    //self.orderID = self.callTaxiResponseJson!["SubmittedOrder"]["Id"].string!
                
                    //print(self.orderID)

                }
                
               // self.startTimer()
                
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }

    }
    
    func startTimer(lOrderID: String){
        print("start timer \(lOrderID)")
        
       // timer1 = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "checkTaxi:", userInfo: lOrderID, repeats: true)
        //NSRunLoop.currentRunLoop().addTimer(self.timer1, forMode: NSDefaultRunLoopMode)
    }
    
    
    internal func checkTaxi(timer: NSTimer!) {
        var params: Dictionary<String,String> = ["Action" : "11"]
        
        print("checking order!!! \(self.orderID)")
        
        params["Id"] = timer.userInfo as? String
        
        
        print(params)
        
        do {
            let opt = try HTTP.PUT(mainhost + "/api/order", parameters: params)
            opt.start { response in
                //do things...
                if let obj: AnyObject =  response.data {
                    
                    self.callTaxiResponseJson = JSON(data: obj as! NSData)
                    let rStatus : String = self.callTaxiResponseJson!["Status"].string!
                    print("Status = \(rStatus)");
                    
                    if(rStatus == "SUCCESS"){
                        
                        //self.timer.invalidate()
                        
                    } else if(rStatus == "FAIL") {
                        
                        
                        
                    }
                    
                    print(self.callTaxiResponseJson)
                    self.orderID = self.callTaxiResponseJson!["SubmittedOrder"]["Id"].string!
                    
                    print(self.orderID)
                    
                }
                
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }

    }
    
    
    
    
    @IBAction func fromButtonAction(sender: AnyObject) {
        locAll.removeAll(keepCapacity: false)
        searchActive = false
        self.searchList.reloadData()
        placeSelectionView.hidden = false
        placeSelectionView.userInteractionEnabled = true
        //fromViewButton.backgroundColor = UIColor.whiteColor()
        //toViewButton.backgroundColor = UIColor.grayColor()
        fromOrTo = true;
    }
    
    @IBAction func toButtonAction(sender: AnyObject) {
        locAll.removeAll(keepCapacity: false)
        searchActive = false
        self.searchList.reloadData()
        placeSelectionView.hidden = false
        placeSelectionView.userInteractionEnabled = true
        //fromViewButton.backgroundColor = UIColor.grayColor()
        //toViewButton.backgroundColor = UIColor.whiteColor()
        
        fromOrTo = false
        
        dispatch_async(dispatch_get_main_queue()){
            self.toImage.image = UIImage(named: "destinationActive.png")
        }
    }
    
    
   
    /*
    @IBAction func mapSearchAction(sender: AnyObject) {
       // let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(myLocation.latitude, longitude: myLocation.longitude, zoom: 12 )
        
        //let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        
        //searchMapView.camera = camera
        
        
        let center = CLLocationCoordinate2DMake(myLocation.latitude, myLocation.longitude)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.05, center.longitude + 0.05)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.05, center.longitude - 0.05)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                // self.nameLabel.text = place.name
                 print(place.formattedAddress)
            } else {
                // self.nameLabel.text = "No place selected"
                // self.addressLabel.text = ""
            }
        })

        
    }
    */
   
    
    //MARK: Table view delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //self.resultSearchController.active
        if (searchActive) {
            print(self.locAll.count)
            return self.locAll.count
        } else {
            return self.filteredTableData.count
        }
        
        
    }
    
    
   
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell  = searchList.dequeueReusableCellWithIdentifier("searchResults", forIndexPath: indexPath) as? UITableViewCell
        //print("****************** Do searching *********************")
      
        if cell != nil {
        
            if (searchActive) {
                if locAll.count > 0 {
                    
                    
                    if let nameLabel = cell!.viewWithTag(2) as? UILabel { //3
                        nameLabel.text = locAll[indexPath.row].name
                    }
                    if let gameLabel = cell!.viewWithTag(3) as? UILabel {
                        gameLabel.text = locAll[indexPath.row].address
                    }
                    if let ratingImageView = cell!.viewWithTag(1) as? UIImageView {
                        ratingImageView.image = UIImage(named: placeImage[locAll[indexPath.row].CategoryId-1])
                        ratingImageView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin ,
                            UIViewAutoresizing.FlexibleWidth ,
                            UIViewAutoresizing.FlexibleRightMargin ,
                            UIViewAutoresizing.FlexibleTopMargin ,
                            UIViewAutoresizing.FlexibleHeight ,
                            UIViewAutoresizing.FlexibleBottomMargin]
                        ratingImageView.contentMode = UIViewContentMode.ScaleAspectFit
                    }
                    
                } else {
                    
                    
                    if let nameLabel = cell!.viewWithTag(2) as? UILabel { //3
                        nameLabel.text = "Searching"
                    }
                    if let gameLabel = cell!.viewWithTag(3) as? UILabel {
                        gameLabel.text = ""
                    }

                    
                }
                return cell!
            } else {
                if filteredTableData.count > 0 {
              
                    
                    
                    //Retrieve data for the cell from the server
                    
                    //cell.title.text = self.filteredTableData[indexPath.row]
                    //cell.subtitle.text = ""
                    
                   // cell!.textLabel!.text = self.filteredTableData[indexPath.row]
                   // cell!.detailTextLabel!.text = ""
                    
                    
                   // if let nameLabel = cell!.viewWithTag(2) as? UILabel { //3
                     //   nameLabel.text = tt = self.filteredTableData[indexPath.row]                     }
                    //if let gameLabel = cell!.viewWithTag(3) as? UILabel {
                      //  gameLabel.text = ""
                    //}
                }
                
                return cell!
            }
            
        } else {
            return cell!
        }
        
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Publist MQTT message to the selected taxi
        //var cell = searchList.dequeueReusableCellWithIdentifier("searchResults", forIndexPath: indexPath)
        
        //self.selectedCell = cell
        
        let indexP = indexPath.row
        
        if locAll.count > 0 {
        
            let locA = locAll[indexP]
            
            if(self.fromOrTo == true) {
                print("From ......................")
                
                self.fromPlace.name = locA.name
                self.fromPlace.address = locA.address
                self.fromPlace.distance = 0
                self.fromPlace.location = locA.location
                self.fromPlaceLabel.text = self.extractWords(locA.name, count: 2)
                self.fromAddress.text = self.extractWords(locA.address,count: 4)
                self.calPrice()
                self.searchActive = false
            } else {
                
                print("To ......................")
                
                self.toPlace.name = self.extractWords(locA.name, count: 2)
                self.toPlace.address = self.extractWords(locA.address, count: 3)
                self.toPlace.distance = 0
                self.toPlace.location = locA.location
                self.toPlaceLabel.text = self.extractWords(locA.name, count: 2)
                self.toAddress.text = self.extractWords(locA.address,count: 4)
                self.calPrice()
                
                self.searchActive = false
                
                dispatch_async(dispatch_get_main_queue()){
                    
                    self.callTaxiButton.userInteractionEnabled = true
                    self.callTaxiButton.backgroundColor = UIColor.init(hexString: "FF3366")
                }
                
                
            }
            
            dispatch_async(dispatch_get_main_queue()){
                self.placeSelectionView.hidden = true
                self.placeSelectionView.userInteractionEnabled = false
            }
            
           /*
        self.placesClient!.lookUpPlaceID(locAll[indexP].placeID, callback: { (place, error) -> Void in
            if error != nil {
                print("lookup place id query error: \(error!.localizedDescription)")
                
            } else {
                
                if let p = place {
                    let temp: CLLocation = CLLocation(latitude: p.coordinate.latitude, longitude: p.coordinate.longitude)
                    
                    
                    
                    
                    if(self.fromOrTo == true) {
                        print("From ......................")
                        
                        self.fromPlace.name = p.name
                        self.fromPlace.address = p.formattedAddress
                        self.fromPlace.distance = 0
                        self.fromPlace.location = temp
                        self.fromPlaceLabel.text = self.extractWords(p.name, count: 2)
                        self.fromAddress.text = self.extractWords(p.formattedAddress,count: 4)
                        
                         self.searchActive = false
                    } else {
                        
                        print("To ......................")
                        
                        self.toPlace.name = self.extractWords(p.name, count: 2)
                        self.toPlace.address = self.extractWords(p.formattedAddress, count: 3)
                        self.toPlace.distance = 0
                        self.toPlace.location = temp
                        self.toPlaceLabel.text = self.extractWords(p.name, count: 2)
                        self.toAddress.text = self.extractWords(p.formattedAddress,count: 4)
                        self.calPrice()
                    
                         self.searchActive = false
                        
                        dispatch_async(dispatch_get_main_queue()){
                            
                            self.callTaxiButton.userInteractionEnabled = true
                            self.callTaxiButton.backgroundColor = UIColor.init(hexString: "FF3366")
                        }
                        
                        
                    }
                    
                    //self.delegate.globalFireOnce = false
                    
                    //data.append(result)
                    
                    print("Place name \(p.name)")
                    print("Place address \(p.formattedAddress)")
                    print("Place placeID \(p.placeID)")
                    print("Place attributions \(p.attributions)")
                    
                    self.placeSelectionView.hidden = true
                    self.placeSelectionView.userInteractionEnabled = false
                   
                    
                } else {
                    print("No place details for \(self.locAll[indexP].placeID)")
                }
                
            }
        })
        */
        
        }
        
    }
    

    
    //MARK: Search bar delegate
    
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.locItems.removeAll(keepCapacity: false)
        self.locAll.removeAll(keepCapacity: false)
        
      
        var sLoc : locDetail = locDetail()
        
        
        print("************* local sdearch ************")
        var ii: Int = 0
        for x in bookmarkLocAll {
            let range : Range? = x.name.rangeOfString(searchText, options: [NSStringCompareOptions.CaseInsensitiveSearch, NSStringCompareOptions.AnchoredSearch],range: nil, locale: nil)
            if let _ = range {
                sLoc.placeID = ""
                sLoc.CategoryId = 13
                sLoc.address = ""
                sLoc.name = x.name
                sLoc.location = x.location
                
                self.locAll.insert(sLoc, atIndex: ii)
                ii++

            }
            print(x.name)
        }
        
        if searchBar.text!.characters.count > 0 {
            dispatch_async(dispatch_get_main_queue()) {
                self.searchList.userInteractionEnabled = true
            }
            var params: Dictionary<String,String> = ["Action" : "4"]
            params["Keyword"] = searchBar.text
            do {
                let opt = try HTTP.PUT(mainhost + "/api/landmark", parameters: params)
                opt.start { response in
                    //do things...
                    if let obj: AnyObject =  response.data {
                    
                        var palces = JSON(data: obj as! NSData)
                        if let rStatus : String = palces["Status"].string {
                            print("Status = \(rStatus)");
                    
                            if(rStatus == "SUCCESS"){
                        
                                for (_,subJson):(String, JSON) in palces["SearchResults"] {
                                    //Do something you want
                                
                                    print(subJson)
                                
                                    sLoc.placeID = ""
                                    sLoc.CategoryId = Int(subJson["CategoryId"].string!)!
                                    sLoc.address = subJson["LocationAddress"].string!
                                    sLoc.name = subJson["LocationName"].string!
                                    sLoc.location = CLLocation(latitude: subJson["Lat"].double!, longitude: subJson["Lng"].double!)
                                
                                    self.locAll.append(sLoc)

                                }
                                dispatch_async(dispatch_get_main_queue()) {
                                    
                                    self.searchList.reloadData()
                                }
                        
                            } else if(rStatus == "FAIL") {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.searchList.userInteractionEnabled = false
                                }
                        
                            }
                        }
                    
                        //print(palces)
                    
                    }
                
                
                }
            } catch let error {
                print("got an error creating the request: \(error)")
            }
        } else if searchBar.text!.characters.count == 0{
            dispatch_async(dispatch_get_main_queue()) {
                self.locItems.removeAll(keepCapacity: false)
                self.locAll.removeAll(keepCapacity: false)
                
                self.searchList.reloadData()
                self.searchList.userInteractionEnabled = false
            }
        }

        /*
        
        let location = CLLocationCoordinate2D(
            latitude: localLat,
            longitude: localLon
        )
        
       // var sLoc : locDetail = locDetail()
        
        let sydney = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let northEast = CLLocationCoordinate2DMake(sydney.latitude + 1, sydney.longitude + 1)
        let southWest = CLLocationCoordinate2DMake(sydney.latitude - 1, sydney.longitude - 1)
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
        
        let sText = searchBar.text
        
        if sText!.characters.count > 0 {
            self.searchList.userInteractionEnabled = true
            print("Searching for '\(sText)'")
            placesClient?.autocompleteQuery(sText!, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                if error != nil {
                    print("Autocomplete error \(error) for query '\(sText)'")
                    
                } else {
                    
                    print("Populating results for query '\(sText)'")
                    //var data : [GMSAutocompletePrediction] = [GMSAutocompletePrediction]()
                    for result in results! {
                        if let result = result as? GMSAutocompletePrediction {
                            
                            sLoc.placeID = result.placeID
                            sLoc.address = result.attributedFullText.string
                            
                            self.locAll.append(sLoc)
                        }
                        
                    }
                   self.searchList.reloadData()
                }
                
            })
        } else {
            self.searchList.userInteractionEnabled = false
        }*/
        
        
    }
    
    
    @available(iOS 8.0, *)
    func presentSearchController(searchController: UISearchController){
        searchController.searchBar.showsCancelButton = true
        
    }
    

    
    
    //MARK: Collection view delegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carType.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("carType",forIndexPath:indexPath) as! carTypeViewCell
        //cell.carType.text? = "aa"
        
        cell.carType.text = carType[indexPath.row]
        cell.carImage.image = UIImage(named: carImage[indexPath.row])
        cell.carImage.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin ,
            UIViewAutoresizing.FlexibleWidth ,
            UIViewAutoresizing.FlexibleRightMargin ,
            UIViewAutoresizing.FlexibleTopMargin ,
            UIViewAutoresizing.FlexibleHeight ,
            UIViewAutoresizing.FlexibleBottomMargin]
        cell.carImage.contentMode = UIViewContentMode.ScaleAspectFit
        cell.carType.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        // Select operation
        //let allCells = collectionView.dequeueReusableCellWithReuseIdentifier("carType",forIndexPath:indexPath) as! carTypeViewCell
        
        let allCells = collectionView.indexPathsForVisibleItems()
        var ii = 0
        for x in allCells {
            let ecell = collectionView.cellForItemAtIndexPath(x) as! carTypeViewCell
            ecell.carType.textColor = UIColor.whiteColor()
            //ecell.carType.backgroundColor = UIColor.init(hexString: "191919")
            //ecell.backgroundColor = UIColor.init(hexString: "191919")
            ecell.carImage.image = UIImage(named: carImage[ii])
            ii++
        }
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! carTypeViewCell
        
        cell.carType.text = carType[indexPath.row]
        cell.carType.textColor = UIColor.lightGrayColor()
        //cell.carType.backgroundColor = UIColor.init(hexString: "5F5F5F")
        //cell.backgroundColor = UIColor.init(hexString: "5F5F5F")
        cell.carImage.image = UIImage(named: carImageActive[indexPath.row])
        
        print("selected + \(indexPath.row) \(carType[indexPath.row])")

    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let kWhateverHeightYouWant : CGFloat = 100.0
            let numcar = CGFloat(carType.count)
            return CGSizeMake(collectionView.bounds.size.width/numcar, kWhateverHeightYouWant)
    }

    
    //MARK: Util functions
    
    func extractWords(w:String, count:Int) -> String {
        var r = ""
        let fullNameArr = w.componentsSeparatedByString(" ")
        print("%%%%%%%%%%%%%%%%%%%%%")
        print(fullNameArr)
        var i:Int
        var CC = count
        if fullNameArr.count <= count {
            CC = fullNameArr.count
        }
        for(i = 0;i < CC;i++){
            r = r + " " + fullNameArr[i]
        }
        print("R = %%%%%%%%%%%%%%%%%%%%%")

        print(r)
        return r
    }
    
    func statusBarHeight() -> CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.size.height
        //let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
        //return Swift.min(statusBarSize.width, statusBarSize.height)
    }
  
    
    func animateBoundsNorth(southWestLat: Double, southWestLon: Double, northEastLat: Double, northEastLon: Double){
        let southWest = CLLocationCoordinate2DMake(southWestLat - 0.1,southWestLon - 0.1)
        let northEast = CLLocationCoordinate2DMake(northEastLat + 0.1,northEastLon + 0.1)
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        print(bounds)
        let camera = map.cameraForBounds(bounds, insets:UIEdgeInsetsZero)
        map.camera = camera;
        

    }
    
    
    
    func calPrice() -> String{
        var price:String = ""
        
        var params: Dictionary<String,AnyObject> = ["SelectedCarType":""]
        
        params["StartLat"] = "\(fromPlace.location.coordinate.latitude)"
        params["StartLng"] = "\(fromPlace.location.coordinate.longitude)"
        params["EndLat"] = "\(toPlace.location.coordinate.latitude)"
        params["EndLng"] = "\(toPlace.location.coordinate.longitude)"
        params["SelectedCarType"] = "tax"
        params["PickupDateTime"] = "2015-09-01 09:10"
        params["AdditionalLocationString"] = ""
        
        do {
            let opt = try HTTP.POST(mainhost + "/api/pricing", parameters: params)
            opt.start { response in
                //do things...
                if let obj: AnyObject =  response.data {
                    
                    let json = JSON(data: obj as! NSData)
                    print(json)
                    
                    if let price1 = json["SelectedPrice"].double {
                        price = String(price1)
                        
                        self.tPrice = price
                        dispatch_async(dispatch_get_main_queue()){
                            
                            self.mainPrice.text = "THB " + price
                        }
                        
                    }

                }
                
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }

        
      
        return price
    }
    
    func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: NSString) -> Bool {
        return UIDevice.currentDevice().systemVersion.compare(version as String,
            options: NSStringCompareOptions.NumericSearch) != NSComparisonResult.OrderedAscending
    }
    
    
    func simplifyName(name: String) -> String {
        var out: String = "";
        let myArray = name.componentsSeparatedByString(" ")
        print(myArray)
        var cc = 0;
        
        for x in myArray {
            
                if cc < 2 {
                    out = out + " " + x
                    
                }
                
          
            
            cc = cc + 1;
            
            
        }
        
        print(out)
        return out;

    }
    
    func simplifyAddress(name: String, address: String) -> String {
        var out: String = "";
        let myArray = address.componentsSeparatedByString(",")
        print(myArray)
        var cc = 0;
        
            for x in myArray {
                if x != name{
                    if cc < 3 {
                        out = out  + x + " "
                         
                    }
                  
                }
                
                cc = cc + 1;
             
                
            }
        
        print(out)
        return out;
    }
    

    
}


extension UIView {
    
    func centerInSuperview() {
        self.centerHorizontallyInSuperview()
        self.centerVerticallyInSuperview()
    }
    
    func centerHorizontallyInSuperview(){
        let c: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: self.superview, attribute: .CenterX, multiplier: 1, constant: 0)
        self.superview?.addConstraint(c)
    }
    
    func centerVerticallyInSuperview(){
        let c: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: self.superview, attribute: .CenterY, multiplier: 1, constant: 0)
        self.superview?.addConstraint(c)
    }
    
    
    func BottomToButom(){
        let c: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: self.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        self.superview?.addConstraint(c)
    }
    
    func equalWidth(){
        let c: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: self.superview, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        self.superview?.addConstraint(c)
    }
    
}


extension UIColor {
    convenience init(hexString:String) {
        let hexString:NSString = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let scanner            = NSScanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}

