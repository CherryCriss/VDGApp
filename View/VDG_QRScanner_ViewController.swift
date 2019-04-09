import UIKit
import MessageUI
import SwiftKeychainWrapper
import PasswordTextField
import Firebase
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import CoreLocation
import Branch
import FirebaseMessaging
import PKHUD
import AVFoundation
class VDG_QRScanner_ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var btn_SmartLogin: UIButton!
    @IBOutlet var btn_QR: UIButton!
    @IBOutlet var btn_ScanNow: UIButton!
    @IBOutlet var vw_QR: UIView!
    @IBOutlet var lbl_QR_Title: UILabel!
    var vw_Load_BK: UIView!
    var activityIndicatorView : NVActivityIndicatorView!
    var locationManager = CLLocationManager()
    var currentCoordinate =  CLLocationCoordinate2D()
    var str_OldFCMToken: String!
    var str_NewFCMToken: String!
    var str_InviterName: String = ""
    @IBOutlet var btn_ScratchHand: UIButton!
    @IBOutlet var vw_Main_BK: UIView!
    var currnetViewIndex: Int!
    var str_GUD_InviterUser: String!
    var dic_SignUp: NSDictionary!
    var isFromSignUp: Bool! = false
    var isFromSignIn: Bool!
    var img_ScreenShot: UIImage!
    override func viewDidAppear(_ animated: Bool) {
        img_ScreenShot = self.takeScreenshot(false)
        let img_tmp = self.takeScreenshot(false) as! UIImage
        let userdefaults = UserDefaults.standard
        if userdefaults.string(forKey: "WebLoginContinue") != nil{
            let isSecondPage = UserDefaults.standard.bool(forKey: "WebLoginContinue")
            if isSecondPage == true {
                UserDefaults.standard.set(Bool(true), forKey:"isSmartLogin")
                UserDefaults.standard.synchronize()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyboard.instantiateViewController(withIdentifier: "VDG_SmartLogout_ViewController") as! VDG_SmartLogout_ViewController
                self.present(newViewController, animated: false, completion: nil)
            }
        }else {
        }
        UserDefaults.standard.set(false, forKey: "WebLoginContinue")
        UserDefaults.standard.synchronize()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false 
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.startUpdatingLocation()
        ToastView.appearance().bottomOffsetPortrait = self.view.frame.size.height/2
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("FCMToken"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.GettingFCMToken), name: Notification.Name("FCMToken"), object: nil)
      if Connectivity.isConnectedToInternet {
            let isLogin = UserDefaults.standard.object(forKey: "isLogin") as! Bool?
            if isLogin == true {
              self.checkUserExit()
            }
      }else{
        Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
      }
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        print(userDetail)
        if let str_App_Salt = UserDefaults.standard.string(forKey: "API_Salt") {
            if (str_App_Salt.count) > 0 {
            }else{
                let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Suggestion_ViewController") as! VDG_Suggestion_ViewController
                newViewController.img_ScreenShot = self.img_ScreenShot
                self.navigationController?.present(newViewController, animated: false, completion: nil)
            }
        }else {
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Suggestion_ViewController") as! VDG_Suggestion_ViewController
            newViewController.img_ScreenShot = self.img_ScreenShot
            self.navigationController?.present(newViewController, animated: false, completion: nil)
        }
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    @objc func GettingFCMToken(notfication: NSNotification) {
        let dicInfo = notfication.userInfo
        print(dicInfo)
        str_NewFCMToken = dicInfo?["token"] as! String
        print(str_NewFCMToken)
        UserDefaults.standard.setValue(dicInfo?["token"], forKey:"FCMToken")
        UserDefaults.standard.synchronize()
        self.UpdateUserInfo_Mainapp()
    }
    func checkUserExit(){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("VeridocMainApp").observeSingleEvent(of: .value, with: { (snapshot) in
         if KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData) != nil {
           let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
            let userID = userDetail!["customerguid"] as! String
            if snapshot.hasChild(userID){
                print("User Exit")
                self.UpdateFirebase(isUserExit: true)
                let dic_Info = snapshot.value as! NSDictionary
                self.LogOutFromOtherDevice(dic_Info: dic_Info)
            }else{
                print("User Not Exit")
                self.UpdateFirebase(isUserExit: false)
            }
          }
        })
    }
    func serverTimeReturn(completionHandler:@escaping (_ getResDate: Date?) -> Void){
        let url = URL(string: "http://www.google.com")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            if let contentType = httpResponse!.allHeaderFields["Date"] as? String {
                let dFormatter = DateFormatter()
                dFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
                let serverTime = dFormatter.date(from: contentType)
                completionHandler(serverTime)
            }
        }
        task.resume()
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                 print("Swiped right")
            case UISwipeGestureRecognizer.Direction.down:
                print("Swiped down")
            case UISwipeGestureRecognizer.Direction.left:
                print("Swiped left")
                let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
                    self.vw_Main_BK.transform = CGAffineTransform(translationX: -self.vw_Main_BK.frame.width, y: 0)
                    self.vw_Main_BK.alpha = 0.8
                })
                animator.startAnimation()
                animator.addCompletion { _ in
                    kConstantObj.SetIntialMainViewController("VDG_SmartLogin_ViewController")
                }
            case UISwipeGestureRecognizer.Direction.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    @IBAction func btn_LeftMenu(_ sender: UIButton) {
        sideMenuVC.toggleMenu()
    }
    @IBAction func btn_ScanNow(_ sender: UIButton) {
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
    }
    func OpenCamera() {
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        print(userDetail)
        if let str_App_Salt = UserDefaults.standard.string(forKey: "API_Salt") {
            if (str_App_Salt.count) > 0 {
                let isLogin = UserDefaults.standard.bool(forKey: "isSmartLogin")
                if isLogin == true {
                     let scanner = QRCodeScannerController(cameraImage: UIImage(named: "camera"), galleryImage: UIImage(named: "icn_galleryqr"), cancelImage: UIImage(named: "icn_camera_back"), flashOnImage: UIImage(named: "flash-on"), flashOffImage: UIImage(named: "flash-off"))
                    scanner.delegate = self
                    self.present(scanner, animated: true, completion: nil)
                }else {
                    let scanner = QRCodeScannerController(cameraImage: UIImage(named: "camera"), galleryImage: UIImage(named: "icn_galleryqr"), cancelImage: UIImage(named: "icn_camera_back"), flashOnImage: UIImage(named: "flash-on"), flashOffImage: UIImage(named: "flash-off"))
                    scanner.delegate = self
                    self.present(scanner, animated: true, completion: nil)
                }
            }else{
                let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Suggestion_ViewController") as! VDG_Suggestion_ViewController
                newViewController.img_ScreenShot = self.img_ScreenShot
                self.navigationController?.present(newViewController, animated: false, completion: nil)
            }
        }else {
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Suggestion_ViewController") as! VDG_Suggestion_ViewController
            newViewController.img_ScreenShot = self.img_ScreenShot
            self.navigationController?.present(newViewController, animated: false, completion: nil)
        }
    }
    func UpdateFirebase(isUserExit: Bool){
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            UserDefaults.standard.setValue(refreshedToken, forKey:"FCMToken")
            UserDefaults.standard.synchronize()
            let dataDict:[String: String] = ["token": refreshedToken]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        }
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
    func UpdateUserInfo_Mainapp(){
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userID = userDetail!["customerguid"] as! String
        let ref1 = Database.database().reference().child("VeridocMainApp").child(userID).child(userID+"-user_info_mainapp")
        ref1.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let ref = Database.database().reference() 
                let str_FCMToken = UserDefaults.standard.object(forKey: "FCMToken") as! String
                var ImageDataDictionary: Dictionary = [String: String]()
                ImageDataDictionary["emailID"] = (userDetail!["email"] as! String)
                ImageDataDictionary["fcmToken"] = str_FCMToken
                ref.child("VeridocMainApp").child(userID).child((userID)+"-user_info_mainapp").updateChildValues(ImageDataDictionary)
            }else {
                let ref = Database.database().reference() 
                let str_FCMToken = UserDefaults.standard.object(forKey: "FCMToken") as! String
                var ImageDataDictionary: Dictionary = [String: String]()
                ImageDataDictionary["emailID"] = (userDetail!["email"] as! String)
                ImageDataDictionary["fcmToken"] = str_FCMToken
                ref.child("VeridocMainApp").child(userID).child((userID)+"-user_info_mainapp").setValue(ImageDataDictionary)
                let ref2 = Database.database().reference().child("VeridocMainApp").child(userID).child(userID+"-user_info_mainapp")
                ref2.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        print(snapshot.value as Any)
                        if snapshot.hasChild("profileurl"){
                            print("true rooms exist")
                        }else{
                            var ImageDataDictionary: Dictionary = [String: String]()
                            ImageDataDictionary["profileurl"] = ""
                            UserDefaults.standard.set("", forKey: "profile")
                            UserDefaults.standard.synchronize()
                            var refUpdate = Database.database().reference()
                            refUpdate.child("VeridocMainApp").child(userID).child((userID)+"-user_info_mainapp").updateChildValues(ImageDataDictionary)
                        }
                    }
                })
            }
        })
    }
    func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = view.layer
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
    func updateHistory() {
        var ref = Database.database().reference() 
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userID = userDetail!["customerguid"] as! String
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
        var dic_Histrory: Dictionary = [String: AnyObject]()
        ref = Database.database().reference().child("VeridocMainApp").child(userID).child(userID+"-Scratch&Win_history")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                print(snapshot.value as Any)
                let dict = snapshot.value as! Dictionary<String, AnyObject>
                var arr_Days = Array<AnyObject>()
                dict.forEach { item in
                    print(item.value)
                    arr_Days.append(item.value)
                }
                let sortedResults = (arr_Days as NSArray).sortedArray(using: [NSSortDescriptor(key: "day", ascending: true)]) as! [[String:AnyObject]]
                let dic_LastDayInfo = sortedResults.last! as [String: AnyObject]
                print(arr_Days)
                print(sortedResults)
                print(dic_LastDayInfo)
                var PreviousDay = dic_LastDayInfo["day"]
                var tmp = Int(PreviousDay as! Int) + 1
                dic_Histrory["day"] = tmp as AnyObject
                dic_Histrory["totalDayScratch"] = Constant.GlobalConstants.str_TotalScratchesPerDay as AnyObject
                dic_Histrory["usedDayScratch"] = 0 as AnyObject
                dic_Histrory["winAmount"] = "" as AnyObject
                let str_Days = "Day"+String(tmp)
                let refT = Database.database().reference()
                refT.child("VeridocMainApp").child(userID).child((userID)+"-Scratch&Win_history").child(str_Days).setValue(dic_Histrory)
            }
        })
    }
    func FireBasePushNotification(str_InviterGUID: String){
        if str_InviterGUID.count  > 0 {
            var ref = Database.database().reference() 
            let userID = str_InviterGUID
            ref = Database.database().reference().child("VeridocMainApp").child(userID).child(userID+"-user_info_mainapp")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    print(snapshot.value as Any)
                    let dic_Info = snapshot.value as! NSDictionary
                    let str_Email = dic_Info["emailID"] as! String
                    let str_FCMToken = dic_Info["fcmToken"] as! String
                    print(str_Email)
                    print(str_FCMToken)
                    let strMsg = str_Email + " has install VeriDoc Global, so you get \(Constant.GlobalConstants.str_TotalScratchesPerInvited) scratches."
                    self.sendRequestPush(str_FCMToken: str_FCMToken, NotificationMsg: strMsg, guid: str_InviterGUID)
                }
            })
        }else {
            Toast(text: "GUID does not found from Inviter User.").show()
        }
    }
    func getProfile() {
        var ref = Database.database().reference() 
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userID = userDetail!["customerguid"] as! String
        ref = Database.database().reference().child("VeridocMainApp").child(userID).child(userID+"-user_info_mainapp")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            var str_Profile: String!
            if snapshot.exists() {
                print(snapshot.value as Any)
                let dic_Info = snapshot.value as! NSDictionary
                if dic_Info["profileurl"] != nil {
                        str_Profile = dic_Info["profileurl"] as! String
                        if dic_Info["profileurl"] != nil{
                            str_Profile = dic_Info["profileurl"] as! String
                               if let url = URL(string: str_Profile) {
                                }else {
                                        let image : UIImage = UIImage(named: "img_placeholder")!
                                        var data = Data()
                                        data = image.jpegData(compressionQuality: 0.8)!
                                        let imageRef = Storage.storage().reference().child(userID).child("images/ProfileImage.png")
                                        let uploadPict = imageRef.putData(data, metadata: nil){  (metadata, error) in
                                            metadata!.contentType = "image/png"
                                            guard let metadata = metadata else {
                                                return
                                            }
                                            let size = metadata.size
                                            imageRef.downloadURL { (url, error) in
                                                print(url)
                                                if error == nil {
                                                    var dic_Histrory: Dictionary = [String: AnyObject]()
                                                    url!.absoluteString
                                                    var directoryURL: NSURL
                                                    var urlString: String = url!.absoluteString
                                                    dic_Histrory["profileurl"] = urlString as AnyObject
                                                    UserDefaults.standard.set(urlString, forKey: "profile")
                                                    UserDefaults.standard.synchronize()
                                                    let refT = Database.database().reference()
                                                    refT.child("VeridocMainApp").child(userID).child((userID)+"-user_info_mainapp").updateChildValues(dic_Histrory)
                                                }else {
                                                    Toast(text: error?.localizedDescription).show()
                                                }
                                            }
                                        }
                                }
                        }else {
                            let image : UIImage = UIImage(named: "img_placeholder")!
                            var data = Data()
                            data = image.jpegData(compressionQuality: 0.8)!
                            let imageRef = Storage.storage().reference().child(userID).child("images/ProfileImage.png")
                            let uploadPict = imageRef.putData(data, metadata: nil){  (metadata, error) in
                                metadata!.contentType = "image/png"
                                guard let metadata = metadata else {
                                    return
                                }
                                let size = metadata.size
                                imageRef.downloadURL { (url, error) in
                                    print(url)
                                    if error == nil {
                                        var dic_Histrory: Dictionary = [String: AnyObject]()
                                        dic_Histrory["profileurl"] = url as AnyObject
                                        UserDefaults.standard.set(url, forKey: "profile")
                                        UserDefaults.standard.synchronize()
                                        let refT = Database.database().reference()
                                        refT.child("VeridocMainApp").child(userID).child((userID)+"-user_info_mainapp").updateChildValues(dic_Histrory)
                                    }else {
                                        Toast(text: error?.localizedDescription).show()
                                    }
                                }
                            }
                        }
                        UserDefaults.standard.set(str_Profile, forKey: "profile")
                        UserDefaults.standard.synchronize()
                }else {
                    let image : UIImage = UIImage(named: "img_placeholder")!
                    let imageData:NSData = image.pngData()! as NSData
                    str_Profile = imageData.base64EncodedString(options: .lineLength64Characters)
                    UserDefaults.standard.set("", forKey: "profile")
                    UserDefaults.standard.synchronize()
                }
            }else {
                let image : UIImage = UIImage(named: "img_placeholder")!
                let imageData:NSData = image.pngData()! as NSData
                str_Profile = imageData.base64EncodedString(options: .lineLength64Characters)
                UserDefaults.standard.set("", forKey: "profile")
                UserDefaults.standard.synchronize()
            }
        })
    }
    func sendRequestPush(str_FCMToken: String, NotificationMsg: String, guid: String)  {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("key=" + Constant.GlobalConstants.str_FCMserverKey, forHTTPHeaderField: "authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["to": str_FCMToken,
                          "priority": "high",
                          "notification": ["body":"VDG", "title":NotificationMsg, "sound":"default"],
                          "content_available": true,  "data":["uid":guid, "title": "Invitation scratches", "message" : "Please logout.."] as NSDictionary] as NSDictionary
        print(parameters)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) 
        } catch let error {
            print(error.localizedDescription)
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask = session.dataTask(with: request as URLRequest) { data,response,error in
            let httpResponse = response as? HTTPURLResponse
            if (error != nil) {
                print(error!)
            } else {
                print(httpResponse!)
                self.UpdateScratches_InvitationAccepted(str_guid: guid)
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            do {
                guard let responseDictionary = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                print("The responseDictionary is: " + responseDictionary.description)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            DispatchQueue.main.async {
            }
        }
        dataTask.resume()
    }
    func LogOutFromOtherDevice(dic_Info: NSDictionary) {
        var ref = Database.database().reference() 
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userID = userDetail!["customerguid"] as! String
        ref = Database.database().reference().child("VeridocMainApp").child(userID).child(userID+"-user_info_mainapp")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                print(snapshot.value as Any)
                let dic_Info = snapshot.value as! NSDictionary
                self.str_OldFCMToken = (dic_Info["fcmToken"] as! String)
                print(self.str_OldFCMToken)
                print(self.str_NewFCMToken)
                print(self.isFromSignIn)
                if self.str_NewFCMToken != nil {
                    print("NewFCMToken is not Null", self.str_NewFCMToken)
                    if self.str_OldFCMToken != self.str_NewFCMToken {
                        self.isFromSignIn = UserDefaults.standard.bool(forKey: "loginfrom")
                        if self.isFromSignIn == true {
                            self.sendRequestlogOutFromAnotherDevice(str_FCMToken: self.str_OldFCMToken)
                        }
                    }
                }else {
                    print("NewFCMToken is Null", self.str_NewFCMToken)
                }
            }
        })
    }
    func sendRequestlogOutFromAnotherDevice(str_FCMToken: String)  {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("key=" + Constant.GlobalConstants.str_FCMserverKey, forHTTPHeaderField: "authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let userInfo: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let dictParams: [String: AnyObject] = ["customerguid" : userInfo!["customerguid"] as AnyObject]
        let parameters = ["to": str_FCMToken,
                          "priority": "high",
                          "content_available": true,  "data":["uid": userInfo!["customerguid"] as! String,"action":"vdgmainapp", "title": "NewDeviceLoginForceLogout", "message" : "Please logout.."] as NSDictionary] as NSDictionary
        print(parameters)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) 
        } catch let error {
            print(error.localizedDescription)
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask = session.dataTask(with: request as URLRequest) { data,response,error in
            let httpResponse = response as? HTTPURLResponse
            if (error != nil) {
                print(error!)
            } else {
                print(httpResponse!)
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            do {
                guard let responseDictionary = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                print("The responseDictionary is: " + responseDictionary.description)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            DispatchQueue.main.async {
            }
        }
        dataTask.resume()
    }
    func UpdateScratches_InvitationAccepted(str_guid: String) {
        var ref = Database.database().reference() 
        let userID = str_guid
        ref = Database.database().reference().child("VeridocMainApp").child(userID).child(userID+"-Scratch&Win")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                print(snapshot.value as Any)
                var dic_Info = snapshot.value as! [String: AnyObject]
                let str_Tmp = dic_Info["today_date"] as! String
                print(str_Tmp)
                let old_TotalScratch = dic_Info["remaining_level_scratch"] as! Int
                let old_total_level_scratch = dic_Info["total_level_scratch"] as! Int
                let str_NewRemaining = Constant.GlobalConstants.str_TotalScratchesPerInvited + old_TotalScratch
                let str_Newold_total_level_scratch = Constant.GlobalConstants.str_TotalScratchesPerInvited +  old_total_level_scratch
                dic_Info["remaining_level_scratch"] = str_NewRemaining as AnyObject
                dic_Info["total_level_scratch"] = str_Newold_total_level_scratch as AnyObject
                Database.database().reference().child("VeridocMainApp").child(userID).child((userID)+"-Scratch&Win").updateChildValues(dic_Info){ (error, ref) -> Void in
                    if error != nil {
                        Toast(text: error?.localizedDescription).show()
                        return
                    }else {
                        let str_Msg =  "Thanks for downloading the VeriDoc Global QR code reading app. \(self.str_InviterName) has referred you will shortly receive their reward!"
                        let alert = UIAlertController(title: "Alert", message: str_Msg, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                            switch action.style{
                            case .default:
                                print("default")
                            case .cancel:
                                print("cancel")
                            case .destructive:
                                print("destructive")
                            }}))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        })
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentCoordinate == nil {
            currentCoordinate = (locations.last?.coordinate)!
            locationManager.stopMonitoringSignificantLocationChanges()
            let locationValue:CLLocationCoordinate2D = manager.location!.coordinate
            print("locations = \(locationValue)")
            locationManager.stopUpdatingLocation()
        }else {
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension VDG_QRScanner_ViewController: QRScannerCodeDelegate {
    func qrCodeScanningDidCompleteWithResult(result: String) {
    }
    func qrCodeScanningFailedWithError(error: String) {
        Toast(text: error).show()
    }
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        print(controller.restorationIdentifier as Any)
        if controller.restorationIdentifier == "smartlogin" {
            print("SmartLogin")
            print(result)
        }else {
            let isURL = canOpenURL(string: result)
            if isURL == true {
                print("No SmartLogin")
                let substring = "veridocglobal.com"
                if result.contains(substring) {
                    print(" veridocglobal.com is found: \(substring)")
                    let webViewController = ABWebViewController()
                    webViewController.title = " "
                    webViewController.URLToLoad = result
                    webViewController.str_Text = result
                    webViewController.progressTintColor = Constant.GlobalConstants.kColor_Theme
                    webViewController.trackTintColor = UIColor.white
                    webViewController.webView.navigationDelegate = webViewController
                    navigationController?.pushViewController(webViewController, animated: false)
                }else {
                    guard let url = URL(string: result) else { return }
                    UIApplication.shared.open(url)
                }
            }else {
                let webViewController = ABWebViewController()
                print(result)
                webViewController.title = " "
                webViewController.URLToLoad = result
                webViewController.str_Text = result
                webViewController.progressTintColor = Constant.GlobalConstants.kColor_Theme
                webViewController.trackTintColor = UIColor.white
                webViewController.webView.navigationDelegate = webViewController
                navigationController?.pushViewController(webViewController, animated: false)
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
         Toast(text: error).show()
    }
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("SwiftQRScanner did cancel")
    }
    func Smart_Login(_ strQr: String) {
        print(strQr)
        var str_WebFCMToken =  ""
        var str_WebName = ""
        let newArr = strQr.components(separatedBy: ["\n"])
        if newArr.count >= 1 {
            str_WebFCMToken = newArr[0]
        }
        if newArr.count >= 2 {
            str_WebName = newArr[1]
        }
        if str_WebFCMToken.count > 0 {
            if str_WebName.count > 0 {
                Login_PushNoti(str_WebFCMToken, str_WebName: str_WebName)
            }else {
                Toast(text: "Invalid QR code").show()
            }
        }else {
            Toast(text: "Invalid QR code").show()
        }
    }
    func Login_PushNoti(_ str_WebFCMToken: String, str_WebName: String) {
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let str_App_Salt = UserDefaults.standard.string(forKey: "API_Salt")
        var str_Hash1 = (userDetail!["customerguid"] as! String) + "login" + (str_App_Salt!)
        str_Hash1 = str_Hash1.lowercased()
        let strReturn = str_WebFCMToken + "\n" + str_WebName
        print(str_Hash1)
        let data = str_Hash1.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        let str_Hash2 = hexBytes.joined()
        print(str_NewFCMToken)
        let parameters: [String: AnyObject] = ["to" : str_WebFCMToken as AnyObject ,
                                               "priority": "high" as AnyObject,
                                               "content_available": true as AnyObject, "data": ["hash": str_Hash2 as AnyObject, "uid": userDetail!["customerguid"] as AnyObject,"token": str_NewFCMToken as AnyObject,"title": userDetail!["customerguid"] as AnyObject,"action": "login" as AnyObject,"returntoken": strReturn as AnyObject,"text": (userDetail!["email"] as! String)as AnyObject] as AnyObject]
        print(parameters)
        UserDefaults.standard.set(parameters, forKey: ConstantsModel.KeyDefaultUser.smartlogindetail)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constant.GlobalConstants.noti_Id_Login), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.messagereceived(notification:)), name: NSNotification.Name(rawValue: Constant.GlobalConstants.noti_Id_Login), object: nil)
        vw_Load_BK = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        vw_Load_BK.backgroundColor = UIColor.white
        vw_Load_BK.alpha = 0.6
        self.view.addSubview(vw_Load_BK)
        let frame = CGRect(x: (self.view.frame.width/2)-30, y: (self.view.frame.height/2)-30, width: 60, height: 60)
        activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                        type: NVActivityIndicatorType.ballScale)
        activityIndicatorView.color = UIColor.darkGray
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        API_FCMPUSH.pushNotification(parameters as NSDictionary) { (strRepose: String) in
            print(strRepose)
        }
    }
    @objc func messagereceived(notification: Notification) {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        vw_Load_BK.removeFromSuperview()
        print(notification.userInfo as Any)
        UserDefaults.standard.set(Bool(true), forKey:"isSmartLogin")
        UserDefaults.standard.synchronize()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "VDG_SmartLogout_ViewController") as! VDG_SmartLogout_ViewController
        self.navigationController?.present(newViewController, animated: false, completion: nil)
    }
}
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
