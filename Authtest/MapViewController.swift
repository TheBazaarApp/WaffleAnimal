

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    
    // MARK: VARIABLES AND OUTLETS
    
    
    var mapTasks = MapTasks()
    var locationMarker: GMSMarker!
    
    @IBOutlet weak var bbFindAddress: UIBarButtonItem!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var defaultLocation: UIBarButtonItem!
    @IBOutlet weak var mapToolbar: UIToolbar!
    
    enum TravelModes: Int {
        case driving
        case walking
        case bicycling
    }
    
    
    
    var coordinate: CLLocationCoordinate2D!
    
    var address: String!
    var lat: Double?
    var long: Double?
    var segueLoc: String?
    var defaultLoc: String?
    var latDefault: Double?
    var longDefault: Double?
    
    
    
    
    
    
    
    // MARK: SETUP FUNCTIONS
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        var camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(12.345, longitude: 67.89, zoom: 8.0)
        viewMap.camera = camera
        viewMap.delegate = self
        
        //Do different things depending on which view you came from
        
        //If you came from closeup, only show the Terrain (Map) button.
        //Pin the user's default location and the item's location on the map
        if segueLoc == "CloseUp" {
            var items = [UIBarButtonItem]()
            items = items + mapToolbar.items!
            items.removeAtIndex(0)
            items.removeAtIndex(1)
            items.removeAtIndex(2)
            mapToolbar.items = items
            saveButton = nil
            camera = GMSCameraPosition.cameraWithLatitude(self.lat!, longitude: self.long!, zoom: 8.0)
            pinLocationOnMap(self.lat!, long: self.long!)
            pinLocationOnMap(latDefault!, long: longDefault!)
        }
        //If you came from AddNewItem, show the all three taskbar items
        if segueLoc == "AddNewItem" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(savePressed))
        }
        //If you came from EditProfile, show only the Address and Terrain buttons
        if segueLoc == "EditProfile" {
            var items = [UIBarButtonItem]()
            items = items + mapToolbar.items!
            items.removeAtIndex(2)
            mapToolbar.items = items
            items[0].title = "Default Location"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(savePressed))
            if defaultLoc! != "no default location set" {
                pinLocationOnMap(0.0, long: 0.0)
            }
        }
        self.hideKeyboardWhenTappedAround()
    }
    
    
    
    
    
    // MARK: PINNING LOCATIONS ONTO A MAP
    
    
    //Move to the right area on the map, put a pin there.
    func pinLocationOnMap(lat: Double, long: Double) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        self.viewMap.camera = GMSCameraPosition.cameraWithTarget(self.coordinate, zoom: 16.0)
        self.setupLocationMarker(self.coordinate)
    }
    
    
    //Mark pin on map
    func setupLocationMarker(coordinate: CLLocationCoordinate2D) {
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = viewMap
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        if coordinate.latitude == latDefault && coordinate.longitude == longDefault {
            locationMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            locationMarker.title = "your default location"
        }
        else {
            locationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        }
        locationMarker.opacity = 0.75
    }
    
    
    
    
    
    // MARK: BUTTON ACTIONS AND ALERTS
    
    
    //See terrain and other map types
    @IBAction func changeMapType(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type", preferredStyle: .ActionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: .Default) { (alertAction) -> Void in
            self.viewMap.mapType = kGMSTypeNormal
        }
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: .Default) { (alertAction) -> Void in
            self.viewMap.mapType = kGMSTypeTerrain
        }
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: .Default) { (alertAction) -> Void in
            self.viewMap.mapType = kGMSTypeHybrid
        }
        let cancelAction = UIAlertAction(title: "Close", style: .Cancel, handler: nil)
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    
    
    
    //When you click the address button, show an alert letting you choose the location, then pin it on the map.
    @IBAction func findAddress(sender: AnyObject) {
        let addressAlert = UIAlertController(title: "Address Finder", message: "Type the address you want to find:", preferredStyle: .Alert)
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Address?"
        }
        let findAction = UIAlertAction(title: "Find Address", style: .Default) { (alertAction) -> Void in
            self.address = (addressAlert.textFields![0] as UITextField).text! as String
            self.mapTasks.geocodeAddress(self.address, withCompletionHandler: { (status, success) -> Void in
                if !success {
                    if status == "ZERO_RESULTS" {
                        self.showAlertWithMessage("The location could not be found.", title: "Location Issue!")
                    }
                }
                else {
                    if self.segueLoc == "EditProfile" {
                        self.defaultLoc = self.address
                    }
                    self.coordinate = CLLocationCoordinate2D(latitude: self.mapTasks.fetchedAddressLatitude, longitude: self.mapTasks.fetchedAddressLongitude)
                    self.viewMap.camera = GMSCameraPosition.cameraWithTarget(self.coordinate, zoom: 16.0)
                    self.setupLocationMarker(self.coordinate)
                }
            })
        }
        let closeAction = UIAlertAction(title: "Close", style: .Cancel, handler: nil)
        addressAlert.addAction(findAction)
        addressAlert.addAction(closeAction)
        presentViewController(addressAlert, animated: true, completion: nil)
    }
    
    
    
    
    //When the "Default Location" button is pressed, pin it to the task bar
    @IBAction func didPressDefaultLocation(sender: AnyObject) {
        address = defaultLoc
        pinLocationOnMap(latDefault!, long: longDefault!)
        
    }
    
    
    
    
    //Called when Save button is pressed
    func savePressed(){
        if let stack = self.navigationController?.viewControllers {
            if let previousViewController = stack[stack.count-2] as? AddNewItem { //Called when you're going back to the AddNewItem viewcontroller
                if coordinate == nil {
                    showAlertWithMessage("Must choose location before saving", title: "Whoops")
                }
                else {
                    previousViewController.lat = coordinate.latitude
                    previousViewController.long = coordinate.longitude
                    previousViewController.locationDetails.text = address
                }
            } else {
                if let previousViewController = stack[stack.count-2] as? EditProfile { //Called when you're going back to the EditProfile viewcontroller
                    previousViewController.locationLabel.text = defaultLoc
                    previousViewController.latDefault = coordinate.latitude
                    previousViewController.longDefault = coordinate.longitude
                } else {
                    print("something's wrong here")
                }
            }
            
        }
        navigationController!.popViewControllerAnimated(true)
    }
    
    
    
    
    
    
    func showAlertWithMessage(message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        alertController.addAction(closeAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    //MARK: FUNCTIONALITY WE AREN'T USING AT THE BOTTOM
    
    //ORIGINALLY AT TOP OF CLASS
    // var didFindMyLocation = false
    // var originMarker: GMSMarker!
    //    var destinationMarker: GMSMarker!
    //    var routePolyline: GMSPolyline!
    //    var travelMode = TravelModes.driving
    //    var markersArray: Array<GMSMarker> = []
    //    var waypointsArray: Array<String> = []
    //    var locationManager = CLLocationManager()
    //
    
    
    //ORIGINALLY IN VIEWDIDLOAD
    //        viewMap.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
    //    locationManager.delegate = self
    //    locationManager.requestWhenInUseAuthorization()
    
    
    //ORIGINALLY THEIR OWN FUNCTIONS
    
    //    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    //        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
    //            viewMap.myLocationEnabled = true
    //        }
    //    }
    
    
    //    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    //        count += 1
    //        print("called it \(count) times")
    //        if !didFindMyLocation {
    //            let myLocation : CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
    //            viewMap.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
    //            viewMap.settings.myLocationButton = true
    //
    //            didFindMyLocation = true
    //        }
    //    }
    
    //    @IBAction func createRoute(sender: AnyObject) {
    //        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
    //
    //        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
    //            textField.placeholder = "Origin?"
    //        }
    //
    //        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
    //            textField.placeholder = "Destination?"
    //        }
    //
    //
    //        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
    //            let origin = (addressAlert.textFields![0] ).text! as String
    //            let destination = (addressAlert.textFields![1] ).text! as String
    //            _ = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
    //                if self.routePolyline != nil {
    //                    self.clearRoute()
    //                    self.waypointsArray.removeAll(keepCapacity: false)
    //                }
    //            }
    //            self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
    //                if success {
    //                    self.configureMapAndMarkersForRoute()
    //                    self.drawRoute()
    //                    self.displayRouteInfo()
    //                }
    //                else {
    //                    print(status)
    //                }
    //            })
    //        }
    //
    //        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
    //
    //        }
    //
    //        addressAlert.addAction(createRouteAction)
    //        addressAlert.addAction(closeAction)
    //
    //        presentViewController(addressAlert, animated: true, completion: nil)
    //    }
    
    //    func configureMapAndMarkersForRoute() {
    //        viewMap.camera = GMSCameraPosition.cameraWithTarget(mapTasks.originCoordinate, zoom: 9.0)
    //        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
    //        originMarker.map = self.viewMap
    //        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
    //        originMarker.title = self.mapTasks.originAddress
    //
    //        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
    //        destinationMarker.map = self.viewMap
    //        destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
    //        destinationMarker.title = self.mapTasks.destinationAddress
    //
    //        if waypointsArray.count > 0 {
    //            for waypoint in waypointsArray {
    //                let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
    //                let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
    //
    //                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
    //                marker.map = viewMap
    //                marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
    //
    //                markersArray.append(marker)
    //            }
    //        }
    //    }
    //
    //    func drawRoute() {
    //        let route = mapTasks.overviewPolyline["points"] as! String
    //
    //        let path: GMSPath = GMSPath(fromEncodedPath: route)!
    //        routePolyline = GMSPolyline(path: path)
    //        routePolyline.map = viewMap
    //    }
    //
    //    func displayRouteInfo() {
    //        lblInfo.text = mapTasks.totalDistance + "\n" + mapTasks.totalDuration
    //    }
    //
    //    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    //        if routePolyline != nil {
    //            let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
    //            waypointsArray.append(positionString)
    //
    //            recreateRoute()
    //        }
    //    }
    //
    //    func clearRoute() {
    //        originMarker.map = nil
    //        destinationMarker.map = nil
    //        routePolyline.map = nil
    //
    //        originMarker = nil
    //        destinationMarker = nil
    //        routePolyline = nil
    //
    //        if markersArray.count > 0 {
    //            for marker in markersArray {
    //                marker.map = nil
    //            }
    //
    //            markersArray.removeAll(keepCapacity: false)
    //        }
    //    }
    //
    //
    //
    //
    //
    //    @IBAction func changeTravelMode(sender: AnyObject) {
    //        let actionSheet = UIAlertController(title: "Travel Mode", message: "Select travel mode:", preferredStyle: UIAlertControllerStyle.ActionSheet)
    //
    //        let drivingModeAction = UIAlertAction(title: "Driving", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
    //            self.travelMode = TravelModes.driving
    //            self.recreateRoute()
    //        }
    //
    //        let walkingModeAction = UIAlertAction(title: "Walking", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
    //            self.travelMode = TravelModes.walking
    //            self.recreateRoute()
    //        }
    //
    //        //        let bicyclingModeAction = UIAlertAction(title: "Bicycling", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
    //        //            self.travelMode = TravelModes.bicycling
    //        //            self.recreateRoute()
    //        //        }
    //        //
    //        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
    //
    //        }
    //
    //        actionSheet.addAction(drivingModeAction)
    //        actionSheet.addAction(walkingModeAction)
    //        //actionSheet.addAction(bicyclingModeAction)
    //        actionSheet.addAction(closeAction)
    //
    //        presentViewController(actionSheet, animated: true, completion: nil)
    //    }
    //
    //    func recreateRoute() {
    //        if routePolyline != nil {
    //            clearRoute()
    //
    //            mapTasks.getDirections(mapTasks.originAddress, destination: mapTasks.destinationAddress, waypoints: waypointsArray, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
    //                
    //                if success {
    //                    self.configureMapAndMarkersForRoute()
    //                    self.drawRoute()
    //                    self.displayRouteInfo()
    //                }
    //                else {
    //                    print(status)
    //                }
    //            })
    //        }
    //    }
    
    //    deinit {
    //        viewMap.removeObserver(self, forKeyPath: "myLocation")
    //    }
    
    
}





