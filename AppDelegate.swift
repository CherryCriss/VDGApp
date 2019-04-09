import UIKit
import Crashlytics
import Firebase
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreData
import Branch
import FirebaseMessaging
import UserNotifications
import FirebaseInstanceID
import SwiftKeychainWrapper
import PKHUD
import IQKeyboardManagerSwift
let kConstantObj = kConstant()
@UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    var window: UIWindow?
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            Branch.getInstance().application(app, open: url, options: options)
            return true
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let branchHandled = Branch.getInstance().application(application,
                                                             open: url,
                                                             sourceApplication: sourceApplication,
                                                             annotation: annotation
        )
        if (!branchHandled) {
        }
        return true
    }
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Branch.getInstance().handlePushNotification(userInfo)
        print(userInfo)
        let info = userInfo as! [String : AnyObject]
        let aps = info["title"] as? String
        print(info)
        print(aps as Any)
        let isLogin = UserDefaults.standard.object(forKey: "isLogin") as! Bool?
        if isLogin == true {
                                if aps == "EULAPending" {
                                   NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constant.GlobalConstants.noti_EULAPending),object: nil))
                                }else if aps == "Invite Scratches" {
                                    let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
                                    let userID = userDetail!["customerguid"] as! String
                                    let senderUID = (info["uid"] as? String)!
                                    if senderUID !=  userID {
                                        self.showAlertAppDelegate(title: (info["title"] as? String)!,message: (info["text"] as? String)!,buttonTitle: "OK",window: self.window!);
                                    }
                                }else if aps == "NewDeviceLoginForceLogout" {
                                    let action = info["action"] as? String
                                    if action == "vdgmainapp" {
                                    PKHUD.sharedHUD.hide()
                                    UserDefaults.standard.set(Bool(false), forKey:"isLogin")
                                    UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
                                    UserDefaults.standard.synchronize()
                                    let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: ConstantsModel.KeyDefaultUser.userData)
                                    print("Remove was successful: \(removeSuccessful)")
                                   NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constant.GlobalConstants.noti_Id_logout),object: info))
                                     self.showAlertAppDelegate(title: "Force Logout",message: "Other device has logged in using same account!!",buttonTitle: "OK",window: self.window!);
                                    }
                                    let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_Auth_ViewController")
                                    self.window?.rootViewController = mainVcIntial
                                }else if  aps == "web login" {
                                    let date = Date()
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "dd MMM yyyy, HH:mm:ss"
                                    let result = formatter.string(from: date)
                                    UserDefaults.standard.set(result, forKey: "smartloginsession")
                                    UserDefaults.standard.synchronize()
                                    PKHUD.sharedHUD.hide()
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constant.GlobalConstants.noti_Id_Login),object: info))
                                }else if aps == "regular login" {
                                    if info["webtoken"] != nil {
                                      let isLogin = UserDefaults.standard.object(forKey: "isLogin") as! Bool?
                                        if isLogin == true {
                                            MakeSmartLoginFormate(webtoken: info["webtoken"] as! String, email: info["email"] as! String, browser: info["browser"] as! String)
                                            let isMobileVerified = UserDefaults.standard.value(forKey:"isMobileVerified") as! Bool
                                            if isMobileVerified == false {
                                                    let attributedString = NSAttributedString(string: "VeriDoc Global Web Login", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                                                                        NSAttributedString.Key.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
                                                    let alert = UIAlertController(title: "", message: "You have successfully logged in. Please verify your mobile number to manage your web login activity using this application.",  preferredStyle: .alert)
                                                    alert.setValue(attributedString, forKey: "attributedTitle")
                                                    alert.view.tintColor = UIColor.black
                                                    let LOGINAGAIN = UIAlertAction(title: "VERIFY ME",
                                                                                   style: .default) { (action: UIAlertAction!) -> Void in
                                                                                    UserDefaults.standard.set(true, forKey: "VerifyMe")
                                                                                    UserDefaults.standard.synchronize()
                                                                                    kConstantObj.SetIntialMainViewController("VDG_SmartLogin_ViewController")
                                                    }
                                                    LOGINAGAIN.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
                                                    let NotNow = UIAlertAction(title: "Not Now",
                                                                               style: .default) { (action: UIAlertAction!) -> Void in
                                                    }
                                                    NotNow.setValue(UIColor.blue, forKey: "titleTextColor")
                                                    alert.addAction(LOGINAGAIN)
                                                    alert.addAction(NotNow)
                                                    window?.rootViewController?.dismiss(animated: false, completion: nil)
                                                    window?.rootViewController?.present(alert, animated: true,
                                                                                        completion: nil)
                                            }else {
                                                let attributedString = NSAttributedString(string: "VeriDoc Global Web Login", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                                                                    NSAttributedString.Key.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
                                                let alert = UIAlertController(title: "", message: "You have successfully logged in to your web account.",  preferredStyle: .alert)
                                                alert.setValue(attributedString, forKey: "attributedTitle")
                                                alert.view.tintColor = UIColor.black
                                                let LOGINAGAIN = UIAlertAction(title: "CONTINUE",
                                                                               style: .default) { (action: UIAlertAction!) -> Void in
                                                                                UserDefaults.standard.set(true, forKey: "WebLoginContinue")
                                                                                UserDefaults.standard.synchronize()
                                                                            kConstantObj.SetIntialMainViewController("VDG_QRScanner_ViewController")
                                                }
                                                LOGINAGAIN.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
                                                alert.addAction(LOGINAGAIN)
                                                 window?.rootViewController?.dismiss(animated: false, completion: nil)
                                                window?.rootViewController?.present(alert, animated: true,
                                                                                    completion: nil)
                                            }
                                        }
                                    }
                                }else if  aps == "web logout" {
                                    PKHUD.sharedHUD.hide()
                                    let isLogin = UserDefaults.standard.object(forKey: "isLogin") as! Bool?
                                    var isAlreadyLogin : Bool
                                    if info["message"] != nil {
                                        if (info["message"] as! String) == "You are already Logged in." {
                                            isAlreadyLogin = true
                                        }
                                        else {
                                           isAlreadyLogin = false
                                        }
                                    }else {
                                        isAlreadyLogin = false
                                    }
                                    if isAlreadyLogin == false {
                                            UserDefaults.standard.set(Bool(false), forKey:"isSmartLogin")
                                            UserDefaults.standard.synchronize()
                                            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constant.GlobalConstants.noti_Id_logout),object: info))
                                            print(info)
                                            if isLogin == true {
                                                if info["message"] != nil {
                                                    let attributedString = NSAttributedString(string: "Oops! There has been an error.", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                                                                                      NSAttributedString.Key.foregroundColor : UIColor.red])
                                                    let alert = UIAlertController(title: "", message: info["message"] as! String,  preferredStyle: .alert)
                                                    alert.setValue(attributedString, forKey: "attributedTitle")
                                                    alert.view.tintColor = UIColor.black
                                                    let cancelAction = UIAlertAction(title: "OK",
                                                                                     style: .default) { (action: UIAlertAction!) -> Void in
                                                    }
                                                    alert.addAction(cancelAction)
                                                    window?.rootViewController?.dismiss(animated: false, completion: nil)
                                                    window?.rootViewController?.present(alert, animated: true,
                                                                                        completion: nil)
                                                }else {
                                                     let isMobileVerified = UserDefaults.standard.value(forKey:"isMobileVerified") as! Bool
                                                    if isMobileVerified == false {
                                                        let attributedString = NSAttributedString(string: "VeriDoc Global Web Login", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                                                                            NSAttributedString.Key.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
                                                        let alert = UIAlertController(title: "", message: "You have successfully logged out. Please verify your mobile number to manage your web login activity using this application.",  preferredStyle: .alert)
                                                        alert.setValue(attributedString, forKey: "attributedTitle")
                                                        alert.view.tintColor = UIColor.black
                                                        let LOGINAGAIN = UIAlertAction(title: "VERIFY ME",
                                                                                       style: .default) { (action: UIAlertAction!) -> Void in
                                                                                        UserDefaults.standard.set(true, forKey: "VerifyMe")
                                                                                        UserDefaults.standard.synchronize()
                                                                                        kConstantObj.SetIntialMainViewController("VDG_SmartLogin_ViewController")
                                                        }
                                                        LOGINAGAIN.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
                                                        let NotNow = UIAlertAction(title: "Not Now",
                                                                                   style: .default) { (action: UIAlertAction!) -> Void in
                                                        }
                                                        NotNow.setValue(UIColor.blue, forKey: "titleTextColor")
                                                        alert.addAction(LOGINAGAIN)
                                                        alert.addAction(NotNow)
                                                         window?.rootViewController?.dismiss(animated: false, completion: nil)
                                                        window?.rootViewController?.present(alert, animated: true,
                                                                                            completion: nil)
                                                    }else {
                                                        let attributedString = NSAttributedString(string: "VeriDoc Global Web Login", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                                                                                          NSAttributedString.Key.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
                                                        let alert = UIAlertController(title: "", message: "You have successfully logged out. Login again any time using the Smart Login feature of this app.",  preferredStyle: .alert)
                                                        alert.setValue(attributedString, forKey: "attributedTitle")
                                                        alert.view.tintColor = UIColor.black
                                                        let LOGINAGAIN = UIAlertAction(title: "LOGIN AGAIN",
                                                                                         style: .default) { (action: UIAlertAction!) -> Void in
                                                                  UserDefaults.standard.set(true, forKey: "SecondPageController")
                                                                  UserDefaults.standard.synchronize()
                                                                  kConstantObj.SetIntialMainViewController("VDG_SmartLogin_ViewController")
                                                        }
                                                        LOGINAGAIN.setValue(Constant.GlobalConstants.kColor_Theme, forKey: "titleTextColor")
                                                        let NotNow = UIAlertAction(title: "Not Now",
                                                                                         style: .default) { (action: UIAlertAction!) -> Void in
                                                        }
                                                        NotNow.setValue(UIColor.blue, forKey: "titleTextColor")
                                                        alert.addAction(LOGINAGAIN)
                                                        alert.addAction(NotNow)
                                                         window?.rootViewController?.dismiss(animated: false, completion: nil)
                                                        window?.rootViewController?.present(alert, animated: true,
                                                                     completion: nil)
                                                    }
                                                }
                                           }
                                    }
                                 }
        }
    }
    func showAlertAppDelegate(title : String,message : String,buttonTitle : String,window: UIWindow){
        let attributedString = NSAttributedString(string: title , attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                                          NSAttributedString.Key.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
        let alert = UIAlertController(title: "", message: message,  preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.view.tintColor = UIColor.black
        let cancelAction = UIAlertAction(title: buttonTitle,
                                         style: .default) { (action: UIAlertAction!) -> Void in
        }
        alert.addAction(cancelAction)
        self.window?.rootViewController?.present(alert, animated: true,
                                            completion: nil)
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
                    }
                }
            }
        })
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            UserDefaults.standard.setValue(refreshedToken, forKey:"FCMToken")
            UserDefaults.standard.synchronize()
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      Messaging.messaging().shouldEstablishDirectChannel = false
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
           Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            Messaging.messaging().delegate = self
        }
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        connectToFcm()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .InstanceIDTokenRefresh,
                                               object: nil)
        if launchOptions != nil {
            var userInfo = launchOptions![UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : Any]
            if userInfo != nil {
                if let aKey = userInfo?["aps"] {
                    print("userInfo->\(aKey)")
                }
            }
        }
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(VDG_ReportIssue_ViewController.self)
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(VDG_MySettings_ViewController.self)
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(VDG_Continue_ViewController.self)
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
            if error == nil {
                print("params: %@", params as? [String: AnyObject] ?? {})
            }
        })
        UINavigationBar.appearance().barTintColor = UIColor.init(red: 12/255, green: 44/255, blue: 66/255, alpha: 1.0)
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.init(red: 12/255, green: 44/255, blue: 66/255, alpha: 1.0)
        }
        UIApplication.shared.statusBarStyle = .lightContent
        self.window = UIWindow(frame: UIScreen.main.bounds)
        var str_isIphone = String()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let isLogin = UserDefaults.standard.object(forKey: "isLogin") as! Bool?
        if isLogin == true {
            if isKeyPresentInUserDefaults(key: ConstantsModel.KeyDefaultUser.userData) == true {
                 LoginStatus()
            }
            let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_QRScanner_ViewController")
            self.window?.rootViewController = mainVcIntial
        }else {
            let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_Auth_ViewController")
            self.window?.rootViewController = mainVcIntial
        }
        do {
            Network.reachability = try Reachability(hostname: "www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        return true
    }
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    @objc func tokenRefreshNotification(notification: NSNotification) {
        guard let contents = InstanceID.instanceID().token()
            else {
                return
        }
        print("InstanceID token: \(contents)")
        UserDefaults.standard.setValue(contents, forKey:"FCMToken")
        UserDefaults.standard.synchronize()
        connectToFcm()
    }
    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    func applicationWillResignActive(_ application: UIApplication) {
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
         NotificationCenter.default.post(name: Notification.Name("ani"), object: nil)
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
        PKHUD.sharedHUD.hide()
        let isLogin = UserDefaults.standard.object(forKey: "isLogin") as! Bool?
        if isLogin == true {
        }else {
        }
    }
    func connectToFcm() {
        guard InstanceID.instanceID().token() != nil else {
            print("FCM: Token does not exist.")
            return
        }
    }
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Google_Contacts_Viewer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func clearCoreDataStore() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        for i in 0...delegate.persistentContainer.managedObjectModel.entities.count-1 {
            let entity = delegate.persistentContainer.managedObjectModel.entities[i]
            do {
                let query = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
                let deleterequest = NSBatchDeleteRequest(fetchRequest: query)
                try context.execute(deleterequest)
                try context.save()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
    func get_AllLimits() {
        var ref = Database.database().reference() 
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        ref = Database.database().reference().child("VeridocMainApp").child("AllLimits").child("LEVEL1")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                print(snapshot.value as Any)
                let dic_Info = snapshot.value as! NSDictionary
                let str_Tmp = dic_Info["DailyLimit"] as! String
                print(dic_Info)
                Constant.L_1_DailyLimit = str_Tmp
            }
        })
    }
    func LoginStatus() {
        let userInfo: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let dictParams: [String: AnyObject] = ["customerguid" : userInfo!["customerguid"] as AnyObject]
        Webservices_Alamofier.LoginStatus(serverlink: ConstantsModel.WebServiceUrl.API_IsWebLogin, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
            if bool == true {
                print(dictParams)
                let returnCode = dictionary["returncode"] as! Int
                if returnCode == 14 {
                    UserDefaults.standard.set(Bool(true), forKey:"isSmartLogin")
                    UserDefaults.standard.synchronize()
                }else if returnCode == 15 {
                    UserDefaults.standard.set(Bool(false), forKey:"isSmartLogin")
                    UserDefaults.standard.synchronize()
                }else {
                    Toast(text: (dictionary["returnmessage"] as! String)).show()
                }
            }else {
                Toast(text: "Something went to wrong").show()
            }
        }
    }
    func getSMTP() {
        let dictParam = [String: AnyObject]()
        Webservices_Alamofier.LoginStatus(serverlink: ConstantsModel.WebServiceUrl.API_smtpdetails, methodname: "", param:dictParam as NSDictionary, key: "key") { (bool, dictionary) in
            if bool == true {
                print(dictionary)
                let returnCode = dictionary["returncode"] as! Int
                if returnCode == 1 {
                    let saveSuccessful: Bool = KeychainWrapper.standard.set(dictionary, forKey: ConstantsModel.KeyDefaultUser.smtpDetail)
                    print("Smtp Detail is save successful: \(saveSuccessful)")
                }else {
                    Toast(text: (dictionary["returnmessage"] as! String)).show()
                }
            }else {
                Toast(text: "Something went to wrong").show()
            }
        }
    }
    func MakeSmartLoginFormate(webtoken: String, email: String, browser: String) {
        UserDefaults.standard.set(Bool(true), forKey:"isSmartLogin")
        UserDefaults.standard.synchronize()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm:ss"
        let result = formatter.string(from: date)
        UserDefaults.standard.set(result, forKey: "smartloginsession")
        UserDefaults.standard.synchronize()
        let userInfo: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let str_App_Salt = UserDefaults.standard.string(forKey: "API_Salt")
        var str_Hash1 = (userInfo!["customerguid"] as! String) + "login" + (str_App_Salt!)
        str_Hash1 = str_Hash1.lowercased()
        let strReturn = webtoken + "\n" + browser
        print(str_Hash1)
        let data = str_Hash1.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        let str_Hash2 = hexBytes.joined()
        let str_NewFCMToken = UserDefaults.standard.value(forKey: "FCMToken")
        let str_To = webtoken
        let parameters: [String: AnyObject] = ["to" : str_To as AnyObject , "priority": "high" as AnyObject,
                                                          "content_available": true as AnyObject, "data": ["hash": str_Hash2 as AnyObject, "uid": userInfo!["customerguid"], "token": str_NewFCMToken as AnyObject,"title": userInfo!["customerguid"], "action": "login" as AnyObject,"returntoken": strReturn as AnyObject, "text": userInfo!["email"]] as AnyObject]
        print(parameters)
        UserDefaults.standard.set(parameters, forKey: ConstantsModel.KeyDefaultUser.smartlogindetail)
        UserDefaults.standard.synchronize()
    }
}
