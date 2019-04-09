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
class VDG_EditPassword_ViewController: UIViewController, UITextFieldDelegate {
    var window: UIWindow?
    @IBOutlet var txt_OldPassword: PasswordTextField!
    @IBOutlet var txt_NewPassword: PasswordTextField!
    @IBOutlet var txt_ConmfirmPassword: PasswordTextField!
    @IBOutlet var btn_Save: UIButton!
    @IBOutlet var btn_Back: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_Save.layer.cornerRadius = 8
        btn_Save.clipsToBounds = true
        btn_Save.layer.cornerRadius = 8
        btn_Save.clipsToBounds = true
    }
    @IBAction func btn_Save(_ sender: UIButton){
        if Connectivity.isConnectedToInternet {
        let retrievedPassword: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let str_OldPassword = UserDefaults.standard.string(forKey: "password")
        if (txt_OldPassword.text?.removingWhitespaces(txt_OldPassword.text).isEmpty)! {
            Toast(text: "Please enter old password").show()
        }else if (txt_OldPassword.text?.removingWhitespaces(txt_OldPassword.text) != str_OldPassword) {
            Toast(text: "Incorrect old password!").show()
        }else if (txt_NewPassword.text?.removingWhitespaces(txt_NewPassword.text).isEmpty)! {
            Toast(text: "Please enter new password").show()
        }else if (txt_OldPassword.text?.removingWhitespaces(txt_OldPassword.text).isEmpty)! {
            Toast(text: "Please enter confirm password").show()
        }else if (txt_OldPassword.text?.removingWhitespaces(txt_OldPassword.text).count)! <= 5 {
            Toast(text: "Old Password Should be at least 6 character long (without blank spaces before/after").show()
        }else if (txt_NewPassword.text?.removingWhitespaces(txt_NewPassword.text).count)! <= 5 {
            Toast(text: "New Passsword Should be at least 8 character long (without blank spaces before/after").show()
        }else if (txt_ConmfirmPassword.text?.removingWhitespaces(txt_ConmfirmPassword.text).count)! <= 5 {
            Toast(text: "Confirm Password Should be at least 8 character long (without blank spaces before/after").show()
        }else if !(txt_NewPassword.text == txt_ConmfirmPassword.text) {
            Toast(text: "Passwords do not match").show()
        }else {
            let dictParams: [String: AnyObject] = ["customerguid" : retrievedPassword!["customerguid"] as AnyObject ,
                                                   "password" : txt_OldPassword.text as AnyObject , "newpassword" : txt_NewPassword.text as AnyObject]
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
            Webservices_Alamofier.postWithURL(serverlink: ConstantsModel.WebServiceUrl.API_changepassword, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
                vw_Load_BK.removeFromSuperview()
                if bool == true {
                    let returnCode = dictionary["returncode"] as! Int
                    if returnCode == 1{
                        Toast(text: dictionary["returnmessage"] as? String).show()
                        UserDefaults.standard.set(Bool(false), forKey:"isLogin")
                        UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
                        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: ConstantsModel.KeyDefaultUser.userData)
                        self.dismiss(animated: true, completion: nil)
                        let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_Auth_ViewController")
                        self.window?.rootViewController = mainVcIntial
                    }else {
                        Toast(text: (dictionary["returnmessage"] as! String)).show()
                    }
                }
            }
        }
     }else{
        Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
     }
    }
    @IBAction func btn_Back(_ sender: UIButton){
           self.dismiss(animated: false, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
