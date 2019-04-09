import UIKit
import SwiftKeychainWrapper
import PKHUD
import NVActivityIndicatorView
class VDG_SmartLogout_ViewController: UIViewController {
    @IBOutlet var btn_LogOut: UIButton!
    @IBOutlet var lbl_Email: UILabel!
    @IBOutlet var lbl_Browser: UILabel!
    @IBOutlet var lbl_Session: UILabel!
    @IBOutlet var lbl_Title: UILabel!
    @IBOutlet var vw_BK: UIView!
    let vw_Load_BK: UIView! = nil
    var activityIndicatorView: NVActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_LogOut.layer.cornerRadius = 8
        btn_LogOut.clipsToBounds = true
        self.title = "Login Detail"
        let dicSmartLogin =   UserDefaults.standard.dictionary(forKey:  ConstantsModel.KeyDefaultUser.smartlogindetail)
        print(dicSmartLogin as! [String: AnyObject])
        let dic_Data = dicSmartLogin!["data"] as AnyObject
        lbl_Email.text = (dic_Data["text"] as! String)
        let str_Browser = (dic_Data["returntoken"] as! String)
        let newArr = str_Browser.components(separatedBy: ["\n"])
        var str_WebName = ""
        if newArr.count >= 2 {
            str_WebName = newArr[1]
        }
        let str_Session = UserDefaults.standard.value(forKey: "smartloginsession") as! String
        var str_BrowserDetail: String!
        if UserDefaults.standard.value(forKey: "BrowserDetail") != nil {
            str_BrowserDetail = UserDefaults.standard.value(forKey: "BrowserDetail") as! String
        }else {
            str_BrowserDetail = "" 
        }
        if str_WebName.count > 0 {
            lbl_Browser.text = str_WebName
        }else if str_BrowserDetail.count > 0 {
            lbl_Browser.text = str_BrowserDetail
        }else {
            lbl_Browser.text = "Unknown"
        }
        if str_Session.count > 0 {
            lbl_Session.text = str_Session
        }
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constant.GlobalConstants.noti_Id_logout), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.messagereceived(notification:)), name: NSNotification.Name(rawValue: Constant.GlobalConstants.noti_Id_logout), object: nil)
        vw_BK.layer.cornerRadius = 8
        vw_BK.clipsToBounds = true
        vw_BK.layer.borderColor = ConstantsModel.ColorCode.kColor_Theme.cgColor
        vw_BK.layer.borderWidth = 0.6
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let str_Tmp = ",\nyou have securely logged in to your account!"
        lbl_Title.text = "Welcome \(userDetail!["firstname"] as! String)\(str_Tmp)"
    }
    @IBAction func btn_LogOut(_ sender: UIButton){
        self.AppLogOut()
    }
    @IBAction func btn_Close(_ sender: UIButton){
       self.dismiss(animated: false, completion: nil )
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
        LogOut_PushNoti(str_WebFCMToken, str_WebName: str_WebName)
    }
    func LogOut_PushNoti(_ str_WebFCMToken: String, str_WebName: String) {
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let str_App_Salt = UserDefaults.standard.string(forKey: "API_Salt")
        var str_Hash1 = (userDetail!["customerguid"] as! String) + "logout" + (str_App_Salt!)
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
        let str_NewFCMToken = UserDefaults.standard.value(forKey: "FCMToken")
        let parameters: [String: AnyObject] = ["to" : str_WebFCMToken as AnyObject ,
                                               "priority": "high" as AnyObject,
                                               "content_available": true as AnyObject, "data": ["hash": str_Hash2 as AnyObject, "uid": userDetail!["customerguid"] as AnyObject,"token": str_NewFCMToken as AnyObject,"title": userDetail!["customerguid"] as AnyObject,"action": "logout" as AnyObject,"returntoken": strReturn as AnyObject,"text": (userDetail!["email"] as! String)as AnyObject] as AnyObject]
         API_FCMPUSH.pushNotification(parameters as NSDictionary) { (strRepose: String) in
            print(strRepose)
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
        }
    }
    @objc func messagereceived(notification: Notification) {
        if activityIndicatorView != nil {
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
        }
        UserDefaults.standard.set(Bool(false), forKey:"isSmartLogin")
        UserDefaults.standard.synchronize()
        self.dismiss(animated: false, completion: nil)
    }
    func AppLogOut() {
       if Connectivity.isConnectedToInternet {
        let userInfo: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let dictParams: [String: AnyObject] = ["customerguid" : userInfo!["customerguid"] as AnyObject]
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
        Webservices_Alamofier.postWithURL(serverlink: ConstantsModel.WebServiceUrl.API_Applogout, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
            if bool == true {
                let returnCode = dictionary["returncode"] as! Int
                if returnCode == 1 {
                    let dicSmartLogin =   UserDefaults.standard.dictionary(forKey:  ConstantsModel.KeyDefaultUser.smartlogindetail)
                    let dic_Data = dicSmartLogin!["data"] as AnyObject
                    let str_Browser = (dic_Data["returntoken"] as! String)
                    self.Smart_Login(str_Browser)
                    UserDefaults.standard.set(Bool(false), forKey:"isSmartLogin")
                    UserDefaults.standard.synchronize()
                    self.dismiss(animated: false, completion: nil )
                }else if returnCode == 5 {
                    Toast(text: (dictionary["returnmessage"] as! String)).show()
                } 
            }else {
                Toast(text: "Something went to wrong").show()
            }
        }
    }else{
    Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
    }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
