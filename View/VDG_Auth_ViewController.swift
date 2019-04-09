import UIKit
import PasswordTextField
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import NVActivityIndicatorView
class VDG_Auth_ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var lbl_Title_Welcome: UILabel!
    @IBOutlet var txt_Email: UITextField!
    @IBOutlet var txt_Password: PasswordTextField!
    @IBOutlet var btn_LogIn: UIButton!
    var str_NewFCMToken: String!
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        let color1 = UIColor(red: 37.0/255.0, green: 152.0/255.0, blue: 77.0/255.0, alpha: 1.0)
        let color2 = UIColor(red: 94.0/255.0, green: 177.0/255.0, blue: 71.0/255.0, alpha: 1.0)
        let color3 = UIColor(red: 94.0/255.0, green: 177.0/255.0, blue: 71.0/255.0, alpha: 1.0)
        btn_LogIn.layer.cornerRadius = 8
        btn_LogIn.clipsToBounds = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       ToastView.appearance().bottomOffsetPortrait = self.view.frame.size.height/2
        self.navigationController?.navigationBar.isHidden = true
        lbl_Title_Welcome.textColor = Constant.GlobalConstants.kColor_Theme
        btn_LogIn.layer.cornerRadius = 8
        btn_LogIn.setTitleColor(Constant.GlobalConstants.kColor_TextTheme , for: .normal)
        txt_Email.layer.cornerRadius  = 6.0
        txt_Password.layer.cornerRadius = 6.0
        txt_Email.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
        txt_Password.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
        txt_Email.layer.borderWidth = 1.0
        txt_Password.layer.borderWidth = 0.7
        txt_Email.delegate = self
        txt_Password.delegate = self
        txt_Email.delegate = self
        txt_Password.delegate = self
        let imgBK = self.view.viewWithTag(20) as! UIView
        let tapGestureRecognizerimgBK = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imgBK.isUserInteractionEnabled = true
        imgBK.addGestureRecognizer(tapGestureRecognizerimgBK)
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            UserDefaults.standard.setValue(refreshedToken, forKey:"FCMToken")
            UserDefaults.standard.synchronize()
        }
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("FCMToken"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.GettingFCMToken), name: Notification.Name("FCMToken"), object: nil)
    }
    func connectToFcm() {
        Messaging.messaging().disconnect()
        Messaging.messaging().connect { (error) in
            if error != nil {
                print("FCM: Unable to connect with FCM. \(error.debugDescription)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    @objc func GettingFCMToken(notfication: NSNotification) {
        let dicInfo = notfication.userInfo
        str_NewFCMToken = dicInfo?["token"] as! String
        print(str_NewFCMToken)
        UserDefaults.standard.setValue(dicInfo?["token"], forKey:"FCMToken")
        UserDefaults.standard.synchronize()
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.view.endEditing(true)
    }
    @IBAction func btn_Forgot(_ sender: UIButton) {
         share_URL()
    }
    @IBAction func btn_Register(_ sender: UIButton) {
        self.navigationController?.navigationBar.isHidden = false
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VDG_SignUp_ViewController") as? VDG_SignUp_ViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    func removeNullFromDict (dict : NSDictionary) -> NSDictionary
    {
        let dic = dict;
        for (key, value) in dict {
            let val : NSObject = value as! NSObject;
            if(val.isEqual(NSNull()))
            {
                dic.setValue("", forKey: (key as? String)!)
            }
            else
            {
                dic.setValue(value, forKey: key as! String)
            }
        }
        return dic;
    }
    @IBAction func btn_Login(_ sender: UIButton) {
         if Connectivity.isConnectedToInternet {
        let providedEmailAddress = txt_Email.text
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: providedEmailAddress!)
        if (txt_Email.text?.removingWhitespaces(txt_Email.text).isEmpty)! {
            Toast(text: "Please enter username/email").show()
        }else if !(isEmailAddressValid){
            Toast(text: "Please enter valid email").show()
        }else if (txt_Password.text?.removingWhitespaces(txt_Password.text).isEmpty)!{
            Toast(text: "Please enter password").show()
        }else if (txt_Password.text?.count)! <= 5 {
            Toast(text: "Password Should be at least 6 character long (without blank spaces before/after").show()
        }
        else{
            let str_NewFCMToken = UserDefaults.standard.value(forKey: "FCMToken")
            let dictParams: [String: AnyObject] = ["ApplicationToken" :  str_NewFCMToken as AnyObject,"password" : txt_Password.text as AnyObject ,
                                                   "email" : txt_Email.text as AnyObject, "username" : txt_Email.text as AnyObject ]
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
           Webservices_Alamofier.postWithURLVerify(serverlink: ConstantsModel.WebServiceUrl.API_Login, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
                if bool == true {
                    UserDefaults.standard.setValue(self.txt_Password.text, forKey:"password")
                    let saveSuccessful: Bool = KeychainWrapper.standard.set(dictionary, forKey: ConstantsModel.KeyDefaultUser.userData)
                    print("Save was successful: \(saveSuccessful)")
                    if bool == true {
                        let returnCode = dictionary["returncode"] as! Int
                        if returnCode == 1{
                            self.txt_Password.text = nil
                            self.txt_Email.text = nil
                            self.navigationController?.navigationBar.isHidden = false
                            UserDefaults.standard.set(Bool(true), forKey:"isLogin")
                            UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
                            if dictionary["API_Salt"] != nil {
                             UserDefaults.standard.set(String(dictionary["API_Salt"] as! String), forKey:"API_Salt")
                             }else {
                                UserDefaults.standard.set(String(""), forKey:"API_Salt")
                            }
                            if dictionary["BrowserDetail"] != nil {
                                let str_b = dictionary["BrowserDetail"] as Any
                                if str_b is NSNull {
                                    UserDefaults.standard.set(String(""), forKey:"BrowserDetail")
                                }else {
                                    UserDefaults.standard.set(String(str_b as! String), forKey:"BrowserDetail")
                                }
                            }
                            UserDefaults.standard.synchronize()
                            let userDetailTmp = dictionary as! Dictionary<String,Any>
                            userDetailTmp.mapValues { $0 is NSNull ? nil : $0 }
                            if userDetailTmp["IsWebLogin"] != nil {
                                if (userDetailTmp["IsWebLogin"] as? Int) == 1 {
                                    self.MakeSmartLoginFormate(dictionary as! [String:AnyObject])
                                }
                            }
                            UserDefaults.standard.set(Bool(true), forKey:"loginfrom")
                            UserDefaults.standard.synchronize()
                            kConstantObj.SetIntialMainViewController("VDG_QRScanner_ViewController")
                        }else  if returnCode == 15 {
                            if dictionary["BrowserDetail"] != nil {
                                let str_b = dictionary["BrowserDetail"] as Any
                                if str_b is NSNull {
                                    UserDefaults.standard.set(String(""), forKey:"BrowserDetail")
                                }else {
                                    UserDefaults.standard.set(String(str_b as! String), forKey:"BrowserDetail")
                                }
                            }
                            Toast(text: "Please Verify your email id first.").show()
                            UserDefaults.standard.set(Bool(false), forKey:"isLogin")
                            UserDefaults.standard.synchronize()
                            let userDetailTmp = dictionary as! Dictionary<String,Any>
                            userDetailTmp.mapValues { $0 is NSNull ? nil : $0 }
                            if userDetailTmp["IsWebLogin"] != nil {
                                if (userDetailTmp["IsWebLogin"] as? Int) == 1 {
                                    self.MakeSmartLoginFormate(dictionary as! [String:AnyObject])
                                }
                            }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Continue_ViewController") as? VDG_Continue_ViewController
                            vc?.dic_SignUp = dictionary
                            self.navigationController?.pushViewController(vc!, animated: true)
                        } else if returnCode == 13 {
                            Toast(text: (dictionary["returnmessage"] as! String)).show()
                            UserDefaults.standard.set(Bool(false), forKey:"isLogin")
                            UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
                            UserDefaults.standard.synchronize()
                        }
                    }else {
                        Toast(text: "Something went to wrong").show()
                    }
                }
            }
        }
    }else{
    Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
    }
    }
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func MakeSmartLoginFormate(_ userDetail: [String:AnyObject]) {
        UserDefaults.standard.set(Bool(true), forKey:"isSmartLogin")
        UserDefaults.standard.synchronize()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm:ss"
        let result = formatter.string(from: date)
        UserDefaults.standard.set(result, forKey: "smartloginsession")
        UserDefaults.standard.synchronize()
        let str_App_Salt = UserDefaults.standard.string(forKey: "API_Salt")
        print(userDetail)
        var str_Hash1 = (userDetail["customerguid"] as! String) + "login" + (str_App_Salt!)
        str_Hash1 = str_Hash1.lowercased()
        var strReturn = ""
        if userDetail["webtoken"] != nil {
            strReturn = (userDetail["Webtoken"] as! String) + "\n" + (userDetail["BrowserDetail"] as! String)
        }
        print(str_Hash1)
        let data = str_Hash1.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        let str_Hash2 = hexBytes.joined()
        let str_NewFCMToken = UserDefaults.standard.value(forKey: "FCMToken")
        var str_To = ""
        if userDetail["webtoken"] != nil {
          str_To = userDetail["Webtoken"] as! String
        }
        let parameters: [String: AnyObject] = ["to" : str_To as AnyObject ,
                                               "priority": "high" as AnyObject,
                                               "content_available": true as AnyObject, "data": ["hash": str_Hash2 as AnyObject, "uid": userDetail["customerguid"] as AnyObject, "token": str_NewFCMToken as AnyObject,"title": userDetail["customerguid"] as AnyObject, "action": "login" as AnyObject,"returntoken": strReturn as AnyObject, "text": userDetail["email"] as AnyObject] as AnyObject]
        print(parameters)
        UserDefaults.standard.set(parameters, forKey: ConstantsModel.KeyDefaultUser.smartlogindetail)
        UserDefaults.standard.synchronize()
    }
    func share_URL(){
        if let requestUrl = NSURL(string: ConstantsModel.WebServiceUrl.url_ForgotPassword)
        {
            self.view.endEditing(true)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(requestUrl as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(requestUrl as URL)
            }
        }else {
            Toast(text: "Invalid URl").show()
        }
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
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
