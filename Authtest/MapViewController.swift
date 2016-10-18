

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    
    // MARK: VARIABLES AND OUTLETS
    
    
    var mapTasks = MapTasks()
    
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var mapToolbar: UIToolbar!
    
    enum TravelModes: Int {
        case driving
        case walking
        case bicycling
    }
    
    
    enum LocationType: String {
        case AlbumLocation
        case ItemLocation
        case DefaultLocation
    }
    
    
    var lat: Double?
    var long: Double?
    var locationDescription: String?
    
    var segueLoc: String?
    var defaultLoc: String?
    var latDefault: Double?
    var longDefault: Double?
    var preexistingLocation = false
    var tapEnabled = false
    var currentMarker: GMSMarker?
    
    
    
    
    
    
    
    // MARK: SETUP FUNCTIONS
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
        tabBarController?.tabBar.hidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var camera: GMSCameraPosition!
        self.navigationController?.navigationBarHidden = false
        if let coords = mainClass.collegeLocation {
            camera = GMSCameraPosition.cameraWithLatitude(coords[0], longitude: coords[1], zoom: 17)
        } else {
            camera = GMSCameraPosition.cameraWithLatitude(34.10608477629448, longitude: -117.71211175922524, zoom: 17)
        }
        
        viewMap.camera = camera
        viewMap.delegate = self
        
        //Do different things depending on which view you came from
        
        //If you came from closeup, hide Location Picker options.
        //Pin the user's default location and the item's location on the map
        if segueLoc == "CloseUp" {
            mapToolbar.items![0].enabled = false
            //var toolbarItems = mapToolbar.items!
            //toolbarItems.removeAtIndex(0)
            //mapToolbar.items = toolbarItems
            camera = GMSCameraPosition.cameraWithLatitude(self.lat!, longitude: self.long!, zoom: 17)
            if latDefault != nil {
                prepareToPin(latDefault!, long: longDefault!, type: .DefaultLocation, description: defaultLoc)
            }
            
            prepareToPin(lat!, long: long!, type: .ItemLocation, description: locationDescription)
        }
        
        //If you came from AddNewItem, show the all three taskbar items
        if segueLoc == "AddNewItem" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(savePressed))
            
            //If you have a location, show its pin
            if preexistingLocation {
                prepareToPin(lat!, long: long!, type: .AlbumLocation, description: locationDescription)
            }
        }
        //If you came from EditProfile, show only the Address and Terrain buttons
        if segueLoc == "EditProfile" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(savePressed))
            if latDefault != nil { //If we already have a default location, go there
                prepareToPin(latDefault!, long: longDefault!, type: .DefaultLocation, description: defaultLoc)
            }
        }
        self.hideKeyboardWhenTappedAround()
    }
    
    
    
    
    
    func prepareToPin(lat: Double, long: Double, type: LocationType, description: String?) {
        var color: UIColor?
        var labelText = ""
        
        switch type {
        case .AlbumLocation:
            color = .redColor()
            labelText = "Album Location"
            break
        case .ItemLocation:
            color = .redColor()
            labelText = "Item Location"
            break
        case .DefaultLocation:
            color = .blueColor()
            labelText = "Your Default Location"
            break
        }
        
        if !(type == .DefaultLocation && segueLoc == "CloseUp") {
            self.long = long
            self.lat = lat
            if (description != nil) && (description != "") {
                self.locationDescription = description!
                labelText += ": " + description!
                mapToolbar.items![0].title = description!
            } else {
                self.locationDescription = nil
            }
        }
        pinLocationOnMap(lat, long: long, label: labelText, color: color!)
        
    }
    
    
    
    
    @IBAction func didPressSelectLocation(sender: AnyObject) {
        let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        optionsMenu.addAction(UIAlertAction(title: "Tap to Pin", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
            self.pressedTapToPin()
        }))
        if segueLoc == "AddNewItem" {
            optionsMenu.addAction(UIAlertAction(title: "Pin to My Default Location", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
                self.pressedPinToDefaultLocation()
            }))
        }
        optionsMenu.addAction(UIAlertAction(title: "Type Address", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
            self.pressedTypeAddress()
        }))
        if lat != nil {
            optionsMenu.addAction(UIAlertAction(title: "Remove Location", style: .Default, handler: {  (alert: UIAlertAction!) -> Void in
                self.pressedRemoveLocation()
            }))
        }
        optionsMenu.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(optionsMenu, animated: true, completion: nil)
    }
    
    
    
    func pressedRemoveLocation() {
        lat = nil
        long = nil
        locationDescription = nil
        if currentMarker != nil {
            currentMarker!.map = nil
        }
    }
    
    
    
    
    func pressedTapToPin() {
        tapEnabled = true
    }
    
    
    func pressedPinToDefaultLocation () {
        if self.latDefault != nil {
            prepareToPin(latDefault!, long: longDefault!, type: .AlbumLocation, description: defaultLoc)
        } else {
            mainClass.simpleAlert("No Default Location Selected", message: "You can set a default location when you edit your profile.", viewController: self)
        }
    }
    
    
    
    func pressedTypeAddress() {
        let addressAlert = UIAlertController(title: "Address Finder", message: "Type the address you want to find:", preferredStyle: .Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Address?"
        }
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Address Description (optional)"
        }
        addressAlert.addAction(UIAlertAction(title: "Find Address", style: .Default) { (alertAction) -> Void in
            var description = (addressAlert.textFields![1] as UITextField).text! as String
            let address = (addressAlert.textFields![0] as UITextField).text! as String
            
            if description == "" {
                description = address
            }
            
            self.mapTasks.geocodeAddress(address, withCompletionHandler: { (status, success) -> Void in
                if !success {
                    mainClass.simpleAlert("Location Issue!", message: "The location could not be found.", viewController: self)
                }
                else {
                    var type: LocationType!
                    if self.segueLoc == "EditProfile" {
                        type = .DefaultLocation
                    } else {
                        type = .AlbumLocation
                    }
                    self.prepareToPin(self.mapTasks.fetchedAddressLatitude, long: self.mapTasks.fetchedAddressLongitude, type: type, description: description)
                }
            })
            })
        addressAlert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        presentViewController(addressAlert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    // MARK: PINNING LOCATIONS ONTO A MAP
    
    
    //Move to the right area on the map, put a pin there.
    func pinLocationOnMap(lat: Double, long: Double, label: String, color: UIColor) {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.viewMap.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 17.0)
        let locationMarker = GMSMarker(position: coordinate)
        if currentMarker != nil {
            currentMarker!.map = nil
        }
        locationMarker.map = viewMap
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.icon = GMSMarker.markerImageWithColor(color)
        locationMarker.title = label
        locationMarker.opacity = 0.75
        
        currentMarker = locationMarker
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
    
    
    
    
    
    
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if tapEnabled {
            let nameAddressAlert = UIAlertController(title: "Name Location", message: nil, preferredStyle: .Alert)
            nameAddressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "Location Name"
            }
            
            nameAddressAlert.addAction(UIAlertAction(title: "Create", style: .Default) { (alertAction) -> Void in
                self.tapEnabled = false
                let description = nameAddressAlert.textFields![0].text!
                if self.segueLoc == "EditProfile" {
                    self.prepareToPin(coordinate.latitude, long: coordinate.longitude, type: .DefaultLocation, description: description)
                } else {
                    self.prepareToPin(coordinate.latitude, long: coordinate.longitude, type: .AlbumLocation, description: description)
                }
                })
            nameAddressAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(nameAddressAlert, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
    
    func savePressed() {
        
        if let stack = self.navigationController?.viewControllers {
            if let previousViewController = stack[stack.count-2] as? AddNewItem { //Called when you're going back to the AddNewItem viewcontroller
                previousViewController.lat = lat
                previousViewController.long = long
                if locationDescription == "" || locationDescription == nil {
                    previousViewController.location = nil
                    if lat != nil {
                        previousViewController.locationDetails.text = "Album Location Selected"
                    } else {
                        previousViewController.locationDetails.text = ""
                    }
                } else {
                    previousViewController.locationDetails.text = locationDescription
                    previousViewController.location = locationDescription
                }
            }
            if let previousViewController = stack[stack.count-2] as? EditProfile { //Called when you're going back to the EditProfile viewcontroller
                previousViewController.latDefault = lat
                previousViewController.longDefault = long
                if locationDescription == "" || locationDescription == nil {
                    if lat == nil {
                        previousViewController.locationLabel.text = "no default location selected"
                        previousViewController.location = nil
                    } else {
                        previousViewController.locationLabel.text = "Default Coordinates: \(Double(round(1000*lat!)/1000)), \(Double(round(1000*long!)/1000))"
                        previousViewController.location = nil
                    }
                } else {
                    previousViewController.locationLabel.text = locationDescription!
                    previousViewController.location = locationDescription
                }
            }
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    
    

    
}
