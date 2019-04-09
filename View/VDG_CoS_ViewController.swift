import UIKit
import FlagPhoneNumber
import MessageUI
import SwiftKeychainWrapper
import PasswordTextField
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
import Branch
import FirebaseMessaging
import PKHUD
import AVFoundation
import NVActivityIndicatorView
import Toast_Swift
class VDG_CoS_ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    var locationManager = CLLocationManager()
    var currentCoordinate =  CLLocationCoordinate2D()
    var lati_global: Double!
    var long_global: Double!
    @IBOutlet var btn_SmartLogin: UIButton!
    @IBOutlet var btn_QR: UIButton!
    @IBOutlet var btn_ScanNow: UIButton!
    @IBOutlet var vw_QR: UIView!
    @IBOutlet var lbl_QR_Title: UILabel!
     @IBOutlet var tbl_COSDATA: UITableView!
    var str_OldFCMToken: String!
    var str_NewFCMToken: String!
    var str_InviterName: String = ""
    var arrInfoColums  = [String]()
    var arrInfoValues  = [String]()
    @IBOutlet var btn_ScratchHand: UIButton!
    @IBOutlet var vw_Main_BK: UIView!
    @IBOutlet var vw_Cos_BK: UIView!
    @IBOutlet var vw_Cos_Bk1: UIView!
    @IBOutlet var btn_Cos_Confirm: UIButton!
    @IBOutlet var btn_Cos_Cancel: UIButton!
    @IBOutlet var lbl_Cos_SerialNumber: UILabel!
    @IBOutlet var lbl_Cos_BusinessName: UILabel!
    @IBOutlet var lbl_Cos_Timestamp: UILabel!
    @IBOutlet var lbl_Cos_location: UILabel!
    @IBOutlet var lbl_Cos_Description: UILabel!
    var currnetViewIndex: Int!
    var str_GUD_InviterUser: String!
    var str_QR_String: String!
    var dic_SignUp: NSDictionary!
    var isFromSignUp: Bool! = false
    var isFromSignIn: Bool!
    var vw_Load_BK: UIView!
    var activityIndicatorView: NVActivityIndicatorView!
    var isCosPermissionDone: Bool! = false
    var isFindAddress: Bool! = false
    var str_CurrentAddress = ""
    var str_requestdatapublicGuid: String!
    var str_QrFullString: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        vw_Cos_BK.isHidden = true
        vw_Cos_Bk1.layer.cornerRadius = 8
        vw_Cos_Bk1.clipsToBounds = true
        btn_Cos_Confirm.layer.cornerRadius = 8
        btn_Cos_Confirm.clipsToBounds = true
        let nib = UINib.init(nibName: "CoS_Data_Cell", bundle: nil)
        tbl_COSDATA.register(nib, forCellReuseIdentifier: "CoS_Data_Cell")
         if Connectivity.isConnectedToInternet {
                var gameTimer: Timer!
                gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(checkingLocationSetting), userInfo: nil, repeats: false)
                var timerAddress: Timer!
                timerAddress = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(gettingAddress), userInfo: nil, repeats: false)
         }else {
                Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
         }
        tbl_COSDATA.rowHeight = UITableView.automaticDimension
        tbl_COSDATA.estimatedRowHeight = 200
    }
    @objc func gettingAddress() {
         if Connectivity.isConnectedToInternet {
            if str_CurrentAddress.count > 3 {
            }else {
                if lati_global != nil && long_global != nil {
                    isFindAddress = false
                    getAddressFromLatLon(pdblLatitude: String(lati_global), withLongitude: String(long_global))
                }
                var timerAddress: Timer!
                timerAddress = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(gettingAddress), userInfo: nil, repeats: false)
            }
        }else {
           Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
    }
    @objc func checkingLocationSetting() {
        let isLocationOn = hasLocationPermission() as Int
        if isLocationOn == 1 {
            let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                self.dismiss(animated: false, completion: nil)
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            var gameTimer: Timer!
            gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(checkingLocationSetting), userInfo: nil, repeats: false)
        }else if isLocationOn == 2 {
            let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                 self.dismiss(animated: false, completion: nil)
                if let bundleId = Bundle.main.bundleIdentifier,
                    let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)")
                {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            var gameTimer: Timer!
            gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(checkingLocationSetting), userInfo: nil, repeats: false)
        }else if isLocationOn == 3 {
            self.locationManager.delegate = self
            self.locationManager.requestLocation()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }else {
            self.locationManager.delegate = self
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            var gameTimer: Timer!
            gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(checkingLocationSetting), userInfo: nil, repeats: false)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        FirstTimeVerifyNumber()
    }
    func FirstTimeVerifyNumber() {
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        print(userDetail as Any)
        var userDetailTmp = userDetail as! Dictionary<String,Any>
        userDetailTmp.mapValues { $0 is NSNull ? nil : $0 }
        print(userDetailTmp)
        if userDetailTmp["contact"] != nil {
            if var actionString = userDetailTmp["contact"] as? String  {
                actionString = ((userDetailTmp["contact"] as? String)?.trimmingCharacters(in: .whitespaces))!
                let isMobileVerified = UserDefaults.standard.value(forKey:"isMobileVerified") as! Bool
                if actionString.count > 0 {
                    if isMobileVerified == false {
                        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(OpenPhoneVerificationScreen), userInfo: nil, repeats: false)
                    }else {
                         let isLocationOn = hasLocationPermission() as Int
                        if isLocationOn == 1 {
                            let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
                            let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                                 self.dismiss(animated: false, completion: nil)
                                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                            })
                            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                            alertController.addAction(cancelAction)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }else if isLocationOn == 2 {
                            let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
                            let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                                 self.dismiss(animated: false, completion: nil)
                                if let bundleId = Bundle.main.bundleIdentifier,
                                    let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)")
                                {
                                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                                }
                            })
                            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                            alertController.addAction(cancelAction)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }else {
                            self.locationManager.delegate = self
                            self.locationManager.requestAlwaysAuthorization()
                            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                            self.locationManager.startUpdatingLocation()
                        }
                    }
                } else {
                    _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(OpenPhoneVerificationScreen), userInfo: nil, repeats: false)
                }
            }else {
                _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(OpenPhoneVerificationScreen), userInfo: nil, repeats: false)
            }
        }else {
            _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(OpenPhoneVerificationScreen), userInfo: nil, repeats: false)
        }
    }
    @objc func OpenPhoneVerificationScreen() {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Phone_ViewController") as! VDG_Phone_ViewController
        secondViewController.img_BK_screeen = self.takeScreenshot(false)
         self.navigationController?.present(secondViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrInfoColums.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CoS_Data_Cell"
        var cell: CoS_Data_Cell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? CoS_Data_Cell
        if cell == nil {
            tableView.register(UINib(nibName: "CoS_Data_Cell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CoS_Data_Cell
        }
        let str_Key =  arrInfoColums[indexPath.row]
        let str_Value = arrInfoValues[indexPath.row]
        let trimmedString = str_Key.trimmingCharacters(in: .whitespacesAndNewlines)
        cell.lbl_Title.text = trimmedString
        if str_Value.count > 0 {
            let trimmedString = str_Value.trimmingCharacters(in: .whitespacesAndNewlines)
            cell.lbl_Value.text = trimmedString
        }else {
             let trimmedString = str_Key.trimmingCharacters(in: .whitespacesAndNewlines)
            cell.lbl_Value.text = trimmedString
            cell.lbl_Value.textColor = UIColor.lightGray
        }
        cell.lbl_Title.sizeToFit()
        cell.lbl_Title.numberOfLines = 0
        cell.lbl_Value.sizeToFit()
        cell.lbl_Value.numberOfLines = 0
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
    @IBAction func btn_Cos_Confirm(_ sender: UIButton) {
        if Connectivity.isConnectedToInternet {
            RequestCoSAPI(requestdatapublicGuid: str_QrFullString)
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
    }
    @IBAction func btn_Cos_Cancel(_ sender: UIButton) {
        vw_Cos_BK.isHidden = true
        kConstantObj.SetIntialMainViewController("VDG_QRScanner_ViewController")
    }
    @IBAction func btn_LeftMenu(_ sender: UIButton) {
        sideMenuVC.toggleMenu()
    }
    @IBAction func btn_ScanNow(_ sender: UIButton) {
        self.vw_Cos_BK.isHidden = true
        self.dismiss(animated: false, completion: nil)
        if Connectivity.isConnectedToInternet {
            let isLocationOn = hasLocationPermission() as Int
            if isLocationOn == 1 {
                let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                     self.dismiss(animated: false, completion: nil)
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }else if isLocationOn == 2 {
                let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                     self.dismiss(animated: false, completion: nil)
                    if let bundleId = Bundle.main.bundleIdentifier,
                        let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)")
                    {
                        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }else {
                self.locationManager.delegate = self
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
                if Connectivity.isConnectedToInternet {
                        if lati_global != nil && long_global != nil {
                            isFindAddress = false
                            getAddressFromLatLon(pdblLatitude: String(lati_global), withLongitude: String(long_global))
                        }
                        var timerAddress: Timer!
                        timerAddress = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(gettingAddress), userInfo: nil, repeats: false)
                            switch AVCaptureDevice.authorizationStatus(for: .video) {
                            case .denied:
                                print("Denied, request permission from settings")
                                presentCameraSettings()
                            case .restricted:
                                print("Restricted, device owner must approve")
                            case .authorized:
                                print("Authorized, proceed")
                                OpenCamera()
                            case .notDetermined:
                                AVCaptureDevice.requestAccess(for: .video) { success in
                                    if success {
                                        self.OpenCamera()
                                    } else {
                                        print("Permission denied")
                                    }
                                }
                            }
                    }else{
                        Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
                    }
           }
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
    }
    func hasLocationPermission() -> Int {
        var hasPermission = 0
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                hasPermission = 2
            case .authorizedAlways, .authorizedWhenInUse:
                hasPermission = 3
            }
        } else {
            hasPermission = 1
        }
        return hasPermission
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentCoordinate == nil {
            currentCoordinate = (locations.last?.coordinate)!
            locationManager.stopMonitoringSignificantLocationChanges()
            let locationValue:CLLocationCoordinate2D = manager.location!.coordinate
            print("locations = \(locationValue)")
            locationManager.stopUpdatingLocation()
        }else {
            lati_global = locations.last?.coordinate.latitude
            long_global = locations.last?.coordinate.longitude
            print(lati_global)
            print(long_global)
            if isFindAddress == false {
                if lati_global != nil && long_global != nil {
                    getAddressFromLatLon(pdblLatitude: String(lati_global), withLongitude: String(long_global))
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
        str_CurrentAddress = ""
    }
    func OpenCamera() {
                let scanner = QR_Cos_Scanning_Camera(cameraImage: UIImage(named: "camera"),  galleryImage: UIImage(named: "icn_galleryqr"), cancelImage: UIImage(named: "icn_camera_back"), flashOnImage: UIImage(named: "flash-on"), flashOffImage: UIImage(named: "flash-off"))
                scanner.delegate = self
                scanner.restorationIdentifier = "CoSScanner"
                scanner.str_CurrentAddress = str_CurrentAddress
                self.present(scanner, animated: true, completion: nil)
    }
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Permissions Required",
                                                message: "Please grant camera permission from your phone's settings.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { _ in
                })
            }
        })
        present(alertController, animated: true)
    }
    func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return screenshotImage
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension VDG_CoS_ViewController: QR_Cos_Scanning_CameraDelegate {
    func qrCodeScanningDidCompleteWithResult(result: String) {
    }
    func qrCodeScanningFailedWithError(error: String) {
         Toast(text: error).show()
    }
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        str_QrFullString = result
        self.vw_Cos_BK.isHidden = true
           str_QR_String = result
           let isURL = canOpenURL(string: result)
            if isURL == true {
                print("No SmartLogin")
                let substring = "veridocglobal.com"
                if result.contains(substring) {
                    print("I found: \(substring)")
                    let arr_StringofQr = result.components(separatedBy: "/")
                    if arr_StringofQr.count > 0 {
                        str_requestdatapublicGuid = arr_StringofQr.last
                            let now = Date()
                            let formatter = DateFormatter()
                            formatter.timeZone = TimeZone.current
                            formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                            let dateString = formatter.string(from: now)
                            if dateString.count > 0 {
                                lbl_Cos_Timestamp.text = dateString
                                lbl_Cos_Timestamp.textColor = UIColor.black
                            }
                            if str_CurrentAddress.count > 3 {
                                lbl_Cos_location.text = str_CurrentAddress
                                lbl_Cos_location.textColor = UIColor.black
                            }
                             checktheCoSVisible()
                    }else {
                        Toast(text: "No Valid QR Code Found!!!").show()
                    }
                }else {
                      Toast(text: "No Valid QR Code Found!!!").show()
                }
            }else {
                let substring_Veridoc_ = "Veridoc"
                if result.contains(substring_Veridoc_) {
                    print("I found: \(substring_Veridoc_)")
                    let arr_StringofQr = result.components(separatedBy: "_")
                    print(arr_StringofQr.count)
                    if arr_StringofQr.count > 0 {
                        if arr_StringofQr.count == 2 {
                            str_requestdatapublicGuid = arr_StringofQr.last
                            let now = Date()
                            let formatter = DateFormatter()
                            formatter.timeZone = TimeZone.current
                            formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                            let dateString = formatter.string(from: now)
                            if dateString.count > 0 {
                                lbl_Cos_Timestamp.text = dateString
                                lbl_Cos_Timestamp.textColor = UIColor.black
                            }
                            if str_CurrentAddress.count > 3 {
                                lbl_Cos_location.text = str_CurrentAddress
                                lbl_Cos_location.textColor = UIColor.black
                            }
                            checktheCoSVisible()
                        }else {
                            if let currentToast = ToastCenter.default.currentToast {
                            }else {
                                Toast(text: "No Valid QR Code Found!!!").show()
                            }
                        }
                        }else {
                            if let currentToast = ToastCenter.default.currentToast {
                            }else {
                                Toast(text: "No Valid QR Code Found!!!").show()
                            }
                        }
                    }else {
                        if let currentToast = ToastCenter.default.currentToast {
                        }else {
                            Toast(text: "No Valid QR Code Found!!!").show()
                        }
                    }
           }
    }
    func canOpenURL(string: String?) -> Bool {
        var str_Main = string
        let str_tmp = str_Main?.last
        if str_tmp == "/" {
            str_Main = String((str_Main?.dropLast())!)  
        }
        guard let urlString = str_Main else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url as URL) {return false}
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: str_Main)
    }
    func qrScannerDidFail(_ controller: UIViewController, error: String) {
        print("error:\(error)")
    }
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("SwiftQRScanner did cancel")
    }
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
       if Connectivity.isConnectedToInternet {
                var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
                let lat: Double = Double("\(pdblLatitude)")!
                let lon: Double = Double("\(pdblLongitude)")!
                let ceo: CLGeocoder = CLGeocoder()
                center.latitude = lat
                center.longitude = lon
                let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
                ceo.reverseGeocodeLocation(loc, completionHandler:
                    {(placemarks, error) in
                        if (error != nil)
                        {
                            print("reverse geodcode fail: \(error!.localizedDescription)")
                        }else {
                            let pm = placemarks! as [CLPlacemark]
                            if pm.count > 0 {
                                let pm = placemarks![0]
                                print(pm.country)
                                print(pm.locality)
                                print(pm.subLocality)
                                print(pm.thoroughfare)
                                print(pm.postalCode)
                                print(pm.subThoroughfare)
                                var addressString : String = ""
                                if pm.locality != nil {
                                    addressString = addressString + pm.locality! + ", "
                                }
                                if pm.country != nil {
                                    addressString = addressString + pm.country! + ", "
                                }
                                if pm.postalCode != nil {
                                    addressString = addressString + pm.postalCode! + ""
                                }
                                if addressString.count > 2 {
                                    self.isFindAddress = true
                                    print(addressString)
                                    self.str_CurrentAddress = addressString
                                    self.lbl_Cos_location.text = self.str_CurrentAddress
                                    self.lbl_Cos_location.textColor = UIColor.black
                                }
                            }
                        }
                })
       }else{
        Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
    }
    func checktheCoSVisible() {
       if Connectivity.isConnectedToInternet {
        print("Address : ",str_CurrentAddress)
        if str_CurrentAddress.count == 0 {
                Toast(text: "Location does not found.\nPlease try again\nor\nplease check the location setting.").show()
        }else {
        HUD.show(HUDContentType.labeledRotatingImage(image: UIImage(named: "icn_spinner_icon"), title: "  Checking Permission ...  ", subtitle: nil))
          let userInfo: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let dateString = formatter.string(from: now)
            arrInfoColums  = [String]()
            arrInfoValues  = [String]()
        let dictParams: [String: AnyObject] = ["customerguid" : userInfo!["customerguid"] as AnyObject, "requestdatapublicGuid" : str_QrFullString  as AnyObject, "scanaddress": str_CurrentAddress as AnyObject, "timestamp": dateString as AnyObject, "verifyurl": str_requestdatapublicGuid as AnyObject]
                    Webservices_Alamofier.LoginStatus(serverlink: ConstantsModel.WebServiceUrl.API_checkcustomeraccess, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
                        PKHUD.sharedHUD.hide()
                        if bool == true {
                            print(dictionary)
                            let userDetailTmp = dictionary as! Dictionary<String,Any>
                            userDetailTmp.mapValues { $0 is NSNull ? nil : $0 }
                            let returnCode = dictionary["returncode"] as! Int
                            if returnCode == 1 {
                                self.isCosPermissionDone = true
                                let saveSuccessful: Bool = KeychainWrapper.standard.set(dictionary, forKey: ConstantsModel.KeyDefaultUser.CosDetail)
                                if saveSuccessful == true {
                                    print("Cos Details is saved successfully")
                                }
                                var str_infoColums:  String!
                                var str_infovalues:  String!
                                var str_delimator:  String!
                                if userDetailTmp["infocolumns"] != nil {
                                    str_infoColums = userDetailTmp["infocolumns"] as? String
                                }
                                if dictionary["infovalues"] != nil {
                                     str_infovalues = userDetailTmp["infovalues"] as? String
                                }
                                if dictionary["delimator"] != nil {
                                     str_delimator = userDetailTmp["delimator"] as? String
                                }
                                print(self.arrInfoColums.count)
                                print(self.arrInfoValues.count)
                                let isPublic = dictionary["ispublicqr"] as! Int
                                if isPublic == 0 {
                                        let modelName = UIDevice.modelName
                                        self.arrInfoColums.append("Scanned By")
                                        if modelName.count > 2 {
                                            self.arrInfoValues.append(modelName)
                                        }else {
                                            self.arrInfoValues.append("")
                                        }
                                        let deviceID = UIDevice.current.identifierForVendor?.uuidString
                                        self.arrInfoColums.append("Device Unique Id")
                                        if deviceID!.count > 2 {
                                            self.arrInfoValues.append(deviceID!)
                                        }else {
                                            self.arrInfoValues.append("")
                                        }
                                }
                                var arr_tmp_Key = [String]()
                                var arr_tmp_Value = [String]()
                                if str_infoColums != nil {
                                     arr_tmp_Key = str_infoColums.components(separatedBy: str_delimator)
                                }
                                if str_infovalues != nil {
                                    arr_tmp_Value = str_infovalues.components(separatedBy: str_delimator)
                                }
                                self.arrInfoColums.append(contentsOf: arr_tmp_Key.filter {$0 != ""})
                                self.arrInfoValues.append(contentsOf: arr_tmp_Value.filter {$0 != ""}) 
                                self.arrInfoColums.append("Location")
                                if self.str_CurrentAddress.count > 2 {
                                    self.arrInfoValues.append(self.str_CurrentAddress)
                                }else {
                                    self.arrInfoValues.append("")
                                }
                                self.arrInfoColums.append("TimeStamp")
                                if dateString.count > 2 {
                                    self.arrInfoValues.append(dateString)
                                }else {
                                    self.arrInfoValues.append("")
                                }
                                print(self.arrInfoColums)
                                print(self.arrInfoValues)
                                self.vw_Cos_BK.isHidden = false
                                self.tbl_COSDATA.reloadData()
                            }else if returnCode == 2 {
                                self.isCosPermissionDone = false
                                self.PermissionAlert(str_Message: "\nYou Don't have permission to \n Access CoS Scanner.\n")
                            }else if returnCode == 4{
                                self.isCosPermissionDone = false
                                self.PermissionAlert(str_Message: (dictionary["returnmessage"] as! String))
                            }else if returnCode == 16{
                                Toast(text: (dictionary["returnmessage"] as! String)).show()
                            }
                        }else {
                            Toast(text: "Something went to wrong").show()
                        }
                    }
         }
        }else {
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
     }
    func PermissionAlert(str_Message: String) {
        let attributedString = NSAttributedString(string: "Permission Require", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                            NSAttributedString.Key.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
        let alert = UIAlertController(title: "", message: "\n \(str_Message) \n",  preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.view.tintColor = UIColor.black
        let LOGINAGAIN = UIAlertAction(title: "   Contact Us  ",
                                       style: .default) { (action: UIAlertAction!) -> Void in
                    kConstantObj.SetIntialMainViewController("VDG_MySettings_ViewController")
        }
        LOGINAGAIN.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
        let NotNow = UIAlertAction(title: "   Cancel  ",
                                   style: .default) { (action: UIAlertAction!) -> Void in
                 self.vw_Cos_BK.isHidden = true
        }
        NotNow.setValue(UIColor.init(red: 11/255.0, green: 162/255.0, blue: 227/255.0, alpha: 1.0), forKey: "titleTextColor")
        alert.addAction(LOGINAGAIN)
        alert.addAction(NotNow)
        self.present(alert, animated: true,
                                            completion: nil)
    }
    func RequestCoSAPI(requestdatapublicGuid: String) {
        if Connectivity.isConnectedToInternet {
            let vw_Load_BK = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            vw_Load_BK.backgroundColor = UIColor.white
            vw_Load_BK.alpha = 0.6
            self.view.addSubview(vw_Load_BK)
            let frame = CGRect(x: (self.view.frame.width/2)-30, y: (self.view.frame.height/2)-30, width: 60, height: 60)
            let activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                                type: NVActivityIndicatorType.ballScale)
            activityIndicatorView.color = UIColor.darkGray
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            let now = Date()
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            let dateString = formatter.string(from: now)
            let modelName = UIDevice.modelName
            let deviceID = UIDevice.current.identifierForVendor?.uuidString
            let userInfo: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
            let dictParams: [String: AnyObject] = ["customerguid" : userInfo!["customerguid"] as AnyObject,"requestdatapublicGuid" : requestdatapublicGuid as AnyObject, "timestamp" : dateString as AnyObject, "scanaddress" : str_CurrentAddress as AnyObject, "scannedby" : modelName as AnyObject, "phoneuniqueid": deviceID as AnyObject]
            Webservices_Alamofier.LoginStatus(serverlink: ConstantsModel.WebServiceUrl.API_addcosdetails, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
                vw_Load_BK.removeFromSuperview()
                if bool == true {
                    self.vw_Cos_BK.isHidden = true
                    print(dictParams)
                    let returnCode = dictionary["returncode"] as! Int
                    if returnCode == 1 {
                        self.str_QR_String = dictionary["verifyurl"] as! String
                        let webViewController = ABWebViewController()
                        print(self.str_QR_String)
                        webViewController.title = " "
                        webViewController.URLToLoad = self.str_QR_String
                        webViewController.str_Text = self.str_QR_String
                        webViewController.progressTintColor = Constant.GlobalConstants.kColor_Theme
                        webViewController.trackTintColor = UIColor.white
                        webViewController.webView.navigationDelegate = webViewController
                        self.navigationController?.pushViewController(webViewController, animated: true)
                    }else {
                        Toast(text: (dictionary["returnmessage"] as! String)).show()
                    }
                }else {
                    Toast(text: "Something went to wrong").show()
                }
            }
        }else {
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
    }
    func SuccessAlert(str_Msg: String) {
        self.vw_Cos_BK.isHidden = true
        let attributedString = NSAttributedString(string: "Submitted\nSuccessfully", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                 NSAttributedString.Key.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
        let alert = UIAlertController(title: "", message: "\n\(str_Msg)\n",  preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.view.tintColor = UIColor.black
        let LOGINAGAIN = UIAlertAction(title: "    OK    ",
                                       style: .default) { (action: UIAlertAction!) -> Void in
                   self.dismiss(animated: false, completion: nil)
                                        let webViewController = ABWebViewController()
                                        print(self.str_QR_String)
                                        webViewController.title = " "
                                        webViewController.URLToLoad = self.str_QR_String
                                        webViewController.str_Text = self.str_QR_String
                                        webViewController.progressTintColor = Constant.GlobalConstants.kColor_Theme
                                        webViewController.trackTintColor = UIColor.white
                                        webViewController.webView.navigationDelegate = webViewController
                                        self.navigationController?.pushViewController(webViewController, animated: true)
        }
        LOGINAGAIN.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
        alert.addAction(LOGINAGAIN)
        self.present(alert, animated: true,
                     completion: nil)
    }
}
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
