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
class VDG_COO_ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
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
    var str_QR_String: String!
    var arrInfoColums  = [String]()
    var arrInfoValues  = [String]()
    var isValidMobile: Bool!
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
    var str_G_FirstName = String()
    var str_G_Email = String()
    var str_Mobile = String()
    var index_FirstName = Int()
    var index_Email = Int()
    var index_Country = Int()
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
        let nib_CountryCode_Cell = UINib.init(nibName: "CountryCode_Cell", bundle: nil)
        tbl_COSDATA.register(nib_CountryCode_Cell, forCellReuseIdentifier: "CountryCode_Cell")
        let nib_Email_Data_Cell = UINib.init(nibName: "Email_Data_Cell", bundle: nil)
        tbl_COSDATA.register(nib_Email_Data_Cell, forCellReuseIdentifier: "Email_Data_Cell")
        let nib_FirstName_Cell = UINib.init(nibName: "FirstName_Cell", bundle: nil)
        tbl_COSDATA.register(nib_FirstName_Cell, forCellReuseIdentifier: "FirstName_Cell")
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange, replacementString string: String) -> Bool {
        var kActualText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        kActualText = kActualText.trimmingCharacters(in: .whitespaces)
        if textField.tag == 11
        {
            str_G_FirstName = kActualText
        }
        else if textField.tag == 22
        {
            str_G_Email = kActualText
        }
        else{
            print("It is nothing")
        }
        return true;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrInfoColums.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let str_RowType =  arrInfoColums[indexPath.row]
        if str_RowType == "mobile" {
            let identifier = "CountryCode_Cell"
            var cell: CountryCode_Cell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? CountryCode_Cell
            if cell == nil {
                tableView.register(UINib(nibName: "CountryCode_Cell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CountryCode_Cell
                cell.phoneNumberTextField.text = nil
            }
            cell.phoneNumberTextField.delegate = self
            cell.phoneNumberTextField.layer.cornerRadius = 6.0
            cell.phoneNumberTextField.parentViewController = self
            cell.phoneNumberTextField.flagPhoneNumberDelegate =  self
            cell.phoneNumberTextField.flagSize = CGSize(width: 38, height: 38)
            cell.phoneNumberTextField.flagButtonEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 5)
            cell.phoneNumberTextField.hasPhoneNumberExample = true
            cell.phoneNumberTextField.textColor = UIColor.black
            cell.phoneNumberTextField.keyboardType = .numberPad
            index_Country = indexPath.row
            return cell
        }else  if str_RowType == "email" {
            let identifier = "Email_Data_Cell"
            var cell: Email_Data_Cell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? Email_Data_Cell
            if cell == nil {
                tableView.register(UINib(nibName: "Email_Data_Cell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? Email_Data_Cell
                cell.txt_Email.text = nil
            }
             index_Email = indexPath.row
            cell.txt_Email.textColor = UIColor.black
            cell.txt_Email.delegate = self
            return cell
        }else  if str_RowType == "firstname" {
            let identifier = "FirstName_Cell"
            var cell: FirstName_Cell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? FirstName_Cell
            if cell == nil {
                tableView.register(UINib(nibName: "FirstName_Cell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FirstName_Cell
                cell.txt_FirstName.text = nil
            }
            index_FirstName = indexPath.row
            cell.txt_FirstName.delegate = self
            cell.txt_FirstName.textColor = UIColor.black
            return cell
        }else {
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
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let str_RowType =  arrInfoColums[indexPath.row]
        if str_RowType == "mobile" {
            return 60
        }else if str_RowType == "email" {
            return 76
        }else if str_RowType == "firstname" {
            return 76
        }else {
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
           return 100
    }
    @IBAction func btn_Cos_Confirm(_ sender: UIButton) {
        if Connectivity.isConnectedToInternet {
            let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
            let userID = userDetail!["customerguid"] as! String
            let user_Email = userDetail!["email"] as! String
            let user_C_Mobile = userDetail!["contact"] as! String
            let isEmailAddressValid = isValidEmailAddress(emailAddressString: str_G_Email)
            print(str_Mobile)
            if (str_G_FirstName.isEmpty){
                Toast(text: "Please enter firstname").show()
            }else if (str_G_Email.isEmpty){
                Toast(text: "Please enter email").show()
            }else if !(isEmailAddressValid){
                Toast(text: "Please enter valid email").show()
            }else if (str_Mobile.isEmpty){
                Toast(text: "Please enter mobile number").show()
            }else if (str_Mobile == user_C_Mobile){
                Toast(text: "   You can't assign to \(str_Mobile) mobile number.   \n\n   \(str_Mobile) mobile number is already registered with your \(user_Email) account.   ", delay: 0.0, duration: 5.0).show()
            }else if isValidMobile == false{
                Toast(text: "Please enter valid mobile number").show()
            }else {
                RequestCoSAPI(requestdatapublicGuid: str_requestdatapublicGuid)
            }
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
    }
    func OpenCamera() {
        let scanner = QR_COO_Scanning_Camera(cameraImage: UIImage(named: "camera"),  galleryImage: UIImage(named: "icn_galleryqr"), cancelImage: UIImage(named: "icn_camera_back"), flashOnImage: UIImage(named: "flash-on"), flashOffImage: UIImage(named: "flash-off"))
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
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            if results.count == 0
            {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return  returnValue
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension VDG_COO_ViewController: FPNTextFieldDelegate {
    func didSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
    func didValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        print(isValid)
        isValidMobile = isValid
    }
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = UITextField.ViewMode.always
        print(
            isValid,
            textField.getFormattedPhoneNumber(format: .E164),
            textField.getFormattedPhoneNumber(format: .International),
            textField.getFormattedPhoneNumber(format: .National),
            textField.getFormattedPhoneNumber(format: .RFC3966),
            textField.getRawPhoneNumber()
        )
        isValidMobile = isValid
        str_Mobile = textField.getFormattedPhoneNumber(format: .E164)  as! String
    }
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
}
extension VDG_COO_ViewController: QR_COO_Scanning_CameraDelegate {
    func qrCodeScanningDidCompleteWithResult(result: String) {
    }
    func qrCodeScanningFailedWithError(error: String) {
        Toast(text: error).show()
    }
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        str_QR_String = result
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
                    str_QR_String = result
                    checktheCoSVisible()
                }else {
                    Toast(text: "No Valid QR Code Found!!!").show()
                }
            }else {
                Toast(text: "No Valid QR Code Found!!!").show()
            }
        }else {
            Toast(text: "No Valid QR Code Found!!!").show()
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
                            }else {
                                self.isFindAddress = false
                                print(addressString)
                                self.str_CurrentAddress = addressString
                                self.lbl_Cos_location.text = self.str_CurrentAddress
                                self.lbl_Cos_location.textColor = UIColor.lightGray
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
                 Toast(text: "\n\nLocation is unavailable.\n\nPlease try again\n\nor\n\nPlease check the location setting.\n\n").show()
            }else {
                HUD.show(HUDContentType.labeledRotatingImage(image: UIImage(named: "icn_spinner_icon"), title: "   Checking Permission ...   ", subtitle: nil))
                let userInfo: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
                let dictParams: [String: AnyObject] = ["customerguid" : userInfo!["customerguid"] as AnyObject, "requestdatapublicGuid" : str_requestdatapublicGuid  as AnyObject ]
                Webservices_Alamofier.LoginStatus(serverlink: ConstantsModel.WebServiceUrl.API_checkcooaccess, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
                    PKHUD.sharedHUD.hide()
                    if bool == true {
                        print(dictionary)
                        let userDetailTmp = dictionary as! Dictionary<String,Any>
                        userDetailTmp.mapValues { $0 is NSNull ? nil : $0 }
                        let returnCode = dictionary["returncode"] as! Int
                        if returnCode == 1 {
                            let is_owner = dictionary["isowner"] as! Bool
                            let is_claim = dictionary["isclaim"] as! Bool
                            self.arrInfoColums = [String]()
                            self.arrInfoValues = [String]()
                            let now = Date()
                            let formatter = DateFormatter()
                            formatter.timeZone = TimeZone.current
                            formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                            let dateString = formatter.string(from: now)
                            if dateString.count > 0 {
                                self.lbl_Cos_Timestamp.text = dateString
                                self.lbl_Cos_Timestamp.textColor = UIColor.black
                            }
                            if self.str_CurrentAddress.count > 3 {
                                self.lbl_Cos_location.text = self.str_CurrentAddress
                                self.lbl_Cos_location.textColor = UIColor.black
                            }
                            if is_owner == true {
                                self.arrInfoColums.append("firstname")
                                self.arrInfoValues.append("firstname")
                                self.arrInfoColums.append("email")
                                self.arrInfoValues.append("email")
                                self.arrInfoColums.append("mobile")
                                self.arrInfoValues.append("mobile")
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
                                self.str_G_Email = ""
                                self.str_G_FirstName = ""
                                self.str_Mobile = ""
                                self.isValidMobile = false
                                let index = IndexPath(row: self.index_FirstName, section: 0)
                                let cell: FirstName_Cell = self.tbl_COSDATA.cellForRow(at: index) as! FirstName_Cell
                                cell.txt_FirstName.text = nil
                                let index1 = IndexPath(row: self.index_Email, section: 0)
                                let cell1: Email_Data_Cell = self.tbl_COSDATA.cellForRow(at: index1) as! Email_Data_Cell
                                cell1.txt_Email.text = nil
                                let index2 = IndexPath(row: self.index_Country, section: 0)
                                let cell2: CountryCode_Cell = self.tbl_COSDATA.cellForRow(at: index2) as! CountryCode_Cell
                                cell2.phoneNumberTextField.text = nil
                            }else if is_claim == true {
                                self.RequestCoSAPI(requestdatapublicGuid: self.str_requestdatapublicGuid)
                            }else {
                                 Toast(text: dictionary["returnmessage"] as! String).show()
                            }
                        }else if returnCode == 2 {
                            self.CustomAlert_VerifyPhone(str_Title: "Error", str_Msg: dictionary["returnmessage"] as! String)
                        }else {
                             self.CustomAlert(str_Title: "Error", str_Msg: dictionary["returnmessage"] as! String)
                        }
                    }else {
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
            print("Address : ",str_CurrentAddress)
            if str_CurrentAddress.count == 0 {
                Toast(text: "\n\nLocation is unavailable.\n\nPlease try again\n\nor\n\nPlease check the location setting.\n\n").show()
            }else {
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
                let dictParams: [String: AnyObject] = ["customerguid" : userInfo!["customerguid"] as AnyObject,"requestdatapublicGuid" : requestdatapublicGuid as AnyObject, "timestamp" : dateString as AnyObject, "scanaddress" : str_CurrentAddress as AnyObject, "scannedby" : modelName as AnyObject, "phoneuniqueid": deviceID as AnyObject, "email": str_G_Email as AnyObject, "name" : str_G_FirstName as AnyObject, "phonenumber" : str_Mobile as AnyObject ]
                Webservices_Alamofier.LoginStatus(serverlink: ConstantsModel.WebServiceUrl.API_addcoodata, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
                    activityIndicatorView.stopAnimating()
                    activityIndicatorView.removeFromSuperview()
                    vw_Load_BK.removeFromSuperview()
                    if bool == true {
                        self.vw_Cos_BK.isHidden = true
                        print(dictParams)
                        let returnCode = dictionary["returncode"] as! Int
                        if returnCode == 1 {
                            if dictionary["isowner"] as! Bool == true {
                                 self.CustomAlert(str_Title: "Assigned Successfully", str_Msg: dictionary["returnmessage"] as! String)
                            }else if dictionary["isclaim"] as! Bool == true {
                                self.CustomAlert_Claim(str_Title: "Claimed Successfully", str_Msg: dictionary["returnmessage"] as! String)
                            }else {
                                self.CustomAlert(str_Title: "Error", str_Msg: dictionary["returnmessage"] as! String)
                            }
                        }else {
                            self.CustomAlert(str_Title: "Error", str_Msg: dictionary["returnmessage"] as! String)
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
    func CustomAlert_VerifyPhone(str_Title: String, str_Msg: String) {
        self.vw_Cos_BK.isHidden = true
        let attributedString = NSAttributedString(string: str_Title, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                  NSAttributedString.Key.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
        let alert = UIAlertController(title: "", message: "\n\n\(str_Msg)\n\n",  preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.view.tintColor = UIColor.black
        let btn_Change_Phone_Number  = UIAlertAction(title: "Change Phone Number",
                                       style: .default) { (action: UIAlertAction!) -> Void in
                                        self.dismiss(animated: false, completion: nil)
                                        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Phone_ViewController") as! VDG_Phone_ViewController
                                        secondViewController.is_FromCoO = true
                                        secondViewController.img_BK_screeen = self.takeScreenshot(false)
                                        self.navigationController?.present(secondViewController, animated: true)
        }
        btn_Change_Phone_Number.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
        alert.addAction(btn_Change_Phone_Number)
        let btn_Go_Back  = UIAlertAction(title: "Go Back",
                                                     style: .default) { (action: UIAlertAction!) -> Void in
                                                        self.dismiss(animated: false, completion: nil)
        }
        btn_Go_Back.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
        alert.addAction(btn_Go_Back)
        self.present(alert, animated: true,
                     completion: nil)
    }
    func CustomAlert(str_Title: String, str_Msg: String) {
        self.vw_Cos_BK.isHidden = true
        let attributedString = NSAttributedString(string: str_Title, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                                  NSAttributedString.Key.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
        let alert = UIAlertController(title: "", message: "\n\n\(str_Msg)\n\n",  preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.view.tintColor = UIColor.black
        let LOGINAGAIN = UIAlertAction(title: "OK",
                                       style: .default) { (action: UIAlertAction!) -> Void in
                                    self.dismiss(animated: false, completion: nil)
        }
        LOGINAGAIN.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
        alert.addAction(LOGINAGAIN)
        self.present(alert, animated: true,
                     completion: nil)
    }
    func CustomAlert_Claim(str_Title: String, str_Msg: String) {
        self.vw_Cos_BK.isHidden = true
        let attributedString = NSAttributedString(string: str_Title, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                  NSAttributedString.Key.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
        let alert = UIAlertController(title: "", message: "\n\n\(str_Msg)\n\n",  preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.view.tintColor = UIColor.black
        let LOGINAGAIN = UIAlertAction(title: "OK",
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
}
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
