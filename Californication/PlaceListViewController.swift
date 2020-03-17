/**
 * Copyright (c) 2016 Ivan Magda
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MBProgressHUD
import Mixpanel
import SpotSense
import CoreLocation
import UserNotifications // required if sending notifications with SpotSense
let spotsense = SpotSense(clientID: "W3BRX4mMAMD9aO9TkNfWYLYNE0EZCJif", clientSecret: "aTlXwGy3RhZAjTZWG8VRI-CvcFZK4q4F42sq08G1xVkyujVXFrSo_iyjmG1XXtA_")

// MARK: Constants

private let kSortingTypeIdentifier = "sortType"

// MARK: Types

private enum SortType: Int {
  case name, rating
}

// MARK: - PlaceListViewController: UIViewController
let locationManager : CLLocationManager = CLLocationManager()
let notificationCenter = UNUserNotificationCenter.current()

override func viewDidLoad() {
    super.viewDidLoad()

    txtLog = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
    txtLog.isScrollEnabled = true
    txtLog.textColor = UIColor.white
    txtLog.backgroundColor = UIColor.black
    txtLog.isEditable = false
    self.view.addSubview(txtLog)
    txtLog.translatesAutoresizingMaskIntoConstraints = false
    txtLog.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
    txtLog.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 55).isActive = true
    txtLog.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
    txtLog.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -55).isActive = true
                    
            // get notification permission, only required if sending notifications with SpotSense
    notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        spotsense.notificationStatus(enabled: granted);
        }
            
            // get location permissions
            locationManager.delegate = self
            locationManager.activityType = .automotiveNavigation
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 5.0
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            spotsense.delegate = self; // attach spotsense delegate to self
            
            if (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
                if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) { // Make sure region monitoring is supported.
                }
            }

    
     let logg = Logger()
     logg.log("App started")
            if let fileURL = logg.logFile {
           
                do{
                  self.txtLog.text = try String(contentsOf: fileURL, encoding: .utf8)
                }
                catch {/* error handling here */}
            }
    spotsense.delegate = self
}

 func ruleDidTrigger(response: NotifyResponse, ruleID: String) {
        
     if let segueID = response.segueID { // performs screenchange
                performSegue(withIdentifier: segueID, sender: nil)
            } else if (response.getActionType() == "http") {
                _ = response.getHTTPResponse()
            }
 }
 
 func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

     spotsense.handleRegionState(region: region, state: .inside)
         
         let logg = Logger()
         
         if let fileURL = logg.logFile {
                        do {
                       //  self.txtLog.text = try String(contentsOf: fileURL, encoding: .utf8)
                        }
                        //catch {/* error handling here */}
         }
     }
     
     func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
         
         spotsense.handleRegionState(region: region, state: .outside)

         let logg = Logger()
                logg.log("didExitRegion : \(region.identifier)")

                if let fileURL = logg.logFile {
                    //reading
                               do {
                                self.txtLog.text = try String(contentsOf: fileURL, encoding: .utf8)
                               }
                               catch {/* error handling here */}
                }
     }


 func didUpdateBeacon(beaconScanner: SpotSense, beaconInfo: BeaconInfo, data: NSDictionary) {
     
 }
 
 func didFindBeacon(beaconScanner: SpotSense, beaconInfo: BeaconInfo, data: NSDictionary) {

     NSLog("FIND: %@", beaconInfo.description)
     
     spotsense.handleBeaconEnterState(beaconScanner: beaconScanner, beaconInfo: beaconInfo, data: data)
     
     DispatchQueue.main.async {

          let logg = Logger()
               logg.log("FIND : \(beaconInfo.description)")
                       if let fileURL = logg.logFile {
               do {
                       self.txtLog.text = try String(contentsOf: fileURL, encoding: .utf8)
                       }
               catch {/* error handling here */}
                       }
     }
   
  }
  func didLoseBeacon(beaconScanner: SpotSense, beaconInfo: BeaconInfo, data: NSDictionary) {

     NSLog("LOST: %@", beaconInfo.description)
     
     spotsense.handleBeaconExitState(beaconScanner: beaconScanner, beaconInfo: beaconInfo, data: data)
     
     DispatchQueue.main.async {

     let logg = Logger()
     logg.log("LOST : \(beaconInfo.description)")
     if let fileURL = logg.logFile {
     do {
         self.txtLog.text = try String(contentsOf: fileURL, encoding: .utf8)
     }
     catch {/* error handling here */}
     }
         }

  }
  func didUpdateBeacon(beaconScanner: SpotSense, beaconInfo: BeaconInfo) {
    //NSLog("UPDATE: %@", beaconInfo.description)
  }
  func didObserveURLBeacon(beaconScanner: SpotSense, URL: NSURL, RSSI: Int) {
    //NSLog("URL SEEN: %@, RSSI: %d", URL, RSSI)
  }
  
  class Logger {

       var logFile: URL? {
          
          guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
          let formatter = DateFormatter()
          formatter.dateFormat = "dd-MM-yyyy"
          let dateString = formatter.string(from: Date())
          let fileName = "\(dateString).log"
          return documentsDirectory.appendingPathComponent(fileName)
      }

       func log(_ message: String) {
          guard let logFile = logFile else {
              return
          }

          let formatter = DateFormatter()
          formatter.dateFormat = "h:mm a"
          let timestamp = formatter.string(from: Date())
          guard let data = (timestamp + ": " + message + "\n").data(using: String.Encoding.utf8) else { return }

          if FileManager.default.fileExists(atPath: logFile.path) {
              if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                  fileHandle.seekToEndOfFile()
                  fileHandle.write(data)
                  fileHandle.closeFile()
              }
          } else {
              try? data.write(to: logFile, options: .atomicWrite)
          }
      }
  }
  extension UIViewController {

    func presentAlert(withTitle title: String, message : String) {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let OKAction = UIAlertAction(title: "OK", style: .default) { action in
          print("You've pressed OK Button")
      }
      alertController.addAction(OKAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }

/* final class PlaceListViewController: UIViewController,CLLocationManagerDelegate, UNUserNotificationCenterDelegate, SpotSenseDelegate {
    let locationManager : CLLocationManager = CLLocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    
    // spotsense delegate method that fires whenever a rule is triggered
    func ruleDidTrigger(response: NotifyResponse, ruleID: String) {
        // custom code that executes for every rule
        if (ruleID == "rule-id-here") {
            // custom code that executes for the rule only
        }
    }
    // required so spotsense knows which geofences are being triggered
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        spotsense.handleRegionState(region: region, state: state)
    }
    
    // Not required: Prints which rules are being monitored for, helpful for debugging
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started monitoring for \(region.identifier)")
    }
   */
  // MARK: Outlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var sortingButton: UIBarButtonItem!
  
  // MARK: Properties
  
  var didSelect: (Place) -> () = { _ in }
  var placeDirector: PlaceDirectorFacade!
  
  private var sortType: SortType {
    get {
      let value = UserDefaults.standard.integer(forKey: kSortingTypeIdentifier)
      return SortType(rawValue: value) ?? .rating
    }
    
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: kSortingTypeIdentifier)
    }
  }
  
  fileprivate let tableViewDataSource = PlaceListTableViewDataSource()
  fileprivate let refreshControl = UIRefreshControl()
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        spotsense.notificationStatus(enabled: granted);
    }
    
    // request location permissions and update location manager
    locationManager.requestAlwaysAuthorization()
    locationManager.delegate = self
    locationManager.startUpdatingLocation()
    
    spotsense.delegate = self; // attach spotsense delegate to self
    if (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) { // Make sure region monitoring is supported.
            spotsense.getRules {} // fetches rules/geofences from spotsense and initializes the listeners
        }
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: Actions
  
  @IBAction func sortDidPressed(_ sender: AnyObject) {
    func sort(by type: SortType) {
      guard type != sortType else { return }
      sortType = type
      reloadData()
    }
    
    let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    actionController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    actionController.addAction(UIAlertAction(title: "By name", style: .default, handler: { _ in
      sort(by: .name)
    }))
    actionController.addAction(UIAlertAction(title: "By rating", style: .default, handler: { _ in
      sort(by: .rating)
    }))
    
    present(actionController, animated: true, completion: nil)
  }
  
  // MARK: Configure
  
  private func setup() {
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 120
    tableView.dataSource = tableViewDataSource
    tableView.delegate = self
    
    tableView.addSubview(refreshControl)
    refreshControl.addTarget(self, action: #selector(loadPlaces), for: .valueChanged)
    
    if let places = placeDirector.persisted() {
      update(with: places)
    }
  }
  
  // MARK: Data
  
  @objc private func loadPlaces() {
    startLoading()
    
    placeDirector.all({ [weak self] places in
      guard let strongSelf = self else { return }
      strongSelf.stopLoading()
      strongSelf.placeDirector.save(places)
      strongSelf.update(with: places)
    }) { [weak self] error in
      guard let strongSelf = self else { return }
      guard error == nil else {
        strongSelf.stopLoading()
        strongSelf.presentAlertWithTitle("Error", message: error!.localizedDescription)
        return
      }
    }
  }
  
  private func update(with newPlaces: [Place]) {
    tableViewDataSource.places = newPlaces
    reloadData()
  }
  
  private func reloadData() {
    tableViewDataSource.places = sortedPlaces()
    tableView.reloadData()
  }
  
  private func sortedPlaces() -> [Place] {
    func sortedByName() -> [Place] {
      return tableViewDataSource.places!.sorted { $0.name < $1.name }
    }
    
    func sortedByRating() -> [Place] {
      return sortedByName().sorted { $0.rating > $1.rating }
    }
    
    guard let _ = tableViewDataSource.places else { return [] }
    
    switch sortType {
    case .name:
      return sortedByName()
    case .rating:
      return sortedByRating()
    }
  }
  
}

// MARK: - PlaceListViewController (UI Functions) -

extension PlaceListViewController {
  
  fileprivate func startLoading() {
    let progressHud = MBProgressHUD.showAdded(to: view, animated: true)
    progressHud.label.text = "Loading"
    sortingButton.isEnabled = false
  }
  
  fileprivate func stopLoading() {
    MBProgressHUD.hide(for: view, animated: true)
    refreshControl.endRefreshing()
    sortingButton.isEnabled = true
  }
  
}

// MARK: - PlaceListViewController: UITableViewDelegate -

extension PlaceListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // this code executes when the item is selected
    guard let selectedPlace = tableViewDataSource.place(for: indexPath) else { return }
    didSelect(selectedPlace)
    let placeName = selectedPlace.name
    let mixpanelAction = "Selected \(placeName)"
    
    Mixpanel.mainInstance().track(event: mixpanelAction)

    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}
