import UIKit
import MessageUI
import SwiftKeychainWrapper
import PasswordTextField
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Branch
import FirebaseMessaging
import PKHUD
import NVActivityIndicatorView
class VDG_EditEmail_ViewController: UIViewController, UITextFieldDelegate {
        var window: UIWindow?
    @IBOutlet var txt_email: UITextField!
    @IBOutlet var btn_Save: UIButton!
    @IBOutlet var btn_Back: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_Save.layer.cornerRadius = 8
        btn_Save.clipsToBounds = true
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userEmail = userDetail!["email"] as! String
        txt_email.text = userEmail
        btn_Save.layer.cornerRadius = 8
        btn_Save.clipsToBounds = true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @IBAction func btn_Back(_ sender: UIButton){
        _ = navigationController?.popToRootViewController(animated: false)
    }
    @IBAction func btn_Save(_ sender: UIButton){
        if Connectivity.isConnectedToInternet {
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userEmail = userDetail!["email"] as! String
        let providedEmailAddress = txt_email.text
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: providedEmailAddress!)
        if (txt_email.text?.removingWhitespaces(txt_email.text).isEmpty)! {
            Toast(text: "Please enter username/email").show()
        }else if !(isEmailAddressValid){
            Toast(text: "Please enter valid email").show()
        }else if userEmail == txt_email.text {
            Toast(text: "Please change your details").show()
        }else{
            API_UpdateContact()
        }
    }else{
    Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
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
    func API_UpdateContact(){
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userID = userDetail!["customerguid"] as! String
        let usercontact: String!
        if userDetail!["contact"] != nil {
            let str_tmp  = userDetail!["contact"] as? String
            if str_tmp == nil {
                usercontact = ""
            }else {
                usercontact = str_tmp
            }
        }else {
            usercontact = ""
        }
        let userfirstname = userDetail!["firstname"] as! String
        let userlastname = userDetail!["lastname"] as! String
        let useremail = txt_email.text
        let dictParams: [String: AnyObject] = ["customerguid" :  userID as AnyObject,"contact" : usercontact as AnyObject ,
                                               "firstname" : userfirstname as AnyObject, "lastname" : userlastname as AnyObject, "email" : useremail as AnyObject]
        print(dictParams)
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
        Webservices_Alamofier.postWithURLVerify(serverlink: ConstantsModel.WebServiceUrl.API_updatecustomer, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
            if bool == true {
                if bool == true {
                    let returnCode = dictionary["returncode"] as! Int
                    if returnCode == 1{
                        let saveSuccessful: Bool = KeychainWrapper.standard.set(dictionary, forKey: ConstantsModel.KeyDefaultUser.userData)
                        print("Save was successful: \(saveSuccessful)")
                        UserDefaults.standard.set(Bool(false), forKey:"isLogin")
                        UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
                        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: ConstantsModel.KeyDefaultUser.userData)
                        let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_Auth_ViewController")
                        self.window?.rootViewController = mainVcIntial
                    }else {
                        Toast(text: dictionary["returnmessage"] as! String).show()
                    }
                }else {
                    Toast(text: "Something went to wrong").show()
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
