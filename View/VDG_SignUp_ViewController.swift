import UIKit
import PasswordTextField
import FlagPhoneNumber
import SwiftKeychainWrapper
import NVActivityIndicatorView
class VDG_SignUp_ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var phoneNumberTextField: FPNTextField!
    @IBOutlet var txt_FirstName: UITextField!
    @IBOutlet var txt_LastName: UITextField!
    @IBOutlet var txt_Email: UITextField!
    @IBOutlet var txt_MobileNumber: UITextField!
    @IBOutlet var txt_Password: PasswordTextField!
    @IBOutlet var txt_ConPassword: PasswordTextField!
    @IBOutlet var btn_Submit: UIButton!
    @IBOutlet var vw_SignUp: UIView!
    var isValidMobile: Bool!
    var str_Mobile: String!
    override func viewDidAppear(_ animated: Bool) {
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register"
        self.navigationController?.navigationBar.barTintColor = Constant.GlobalConstants.kColor_Theme
        btn_Submit.setTitleColor(Constant.GlobalConstants.kColor_TextTheme , for: .normal)
        btn_Submit.layer.cornerRadius = 8
        btn_Submit.clipsToBounds = true
        txt_Email.layer.cornerRadius  = 6.0
        txt_FirstName.layer.cornerRadius = 6.0
        txt_LastName.layer.cornerRadius = 6.0
        txt_Password.layer.cornerRadius = 6.0
        txt_ConPassword.layer.cornerRadius = 6.0
        phoneNumberTextField.layer.cornerRadius = 6.0
        txt_Email.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
        txt_FirstName.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
        txt_LastName.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
        txt_Password.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
        txt_ConPassword.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
        phoneNumberTextField.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
        txt_Email.layer.borderWidth = 0.7
        txt_FirstName.layer.borderWidth = 0.7
        txt_LastName.layer.borderWidth = 0.7
        txt_Password.layer.borderWidth = 0.7
        txt_ConPassword.layer.borderWidth = 0.7
        phoneNumberTextField.layer.borderWidth = 0.7
        txt_Email.delegate = self
        txt_FirstName.delegate = self
        txt_LastName.delegate = self
        txt_Password.delegate = self
        txt_ConPassword.delegate = self
        let imgBK = self.view.viewWithTag(20) as! UIImageView
        let tapGestureRecognizerimgBK = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imgBK.isUserInteractionEnabled = true
        imgBK.addGestureRecognizer(tapGestureRecognizerimgBK)
        let tapGestureRecognizervw_SignUp = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        vw_SignUp.isUserInteractionEnabled = true
        vw_SignUp.addGestureRecognizer(tapGestureRecognizervw_SignUp)
        phoneNumberTextField.parentViewController = self
        phoneNumberTextField.flagPhoneNumberDelegate =  self
        phoneNumberTextField.flagSize = CGSize(width: 35, height: 35)
        phoneNumberTextField.flagButtonEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        phoneNumberTextField.hasPhoneNumberExample = true
        phoneNumberTextField.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
        phoneNumberTextField.layer.borderWidth = 1.0
    }
    private func getCustomTextFieldInputAccessoryView(with items: [UIBarButtonItem]) -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.items = items
        toolbar.sizeToFit()
        return toolbar
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
         self.view.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    @IBAction func btn_LeftMenu(_ sender: UIBarButtonItem) {
       sideMenuVC.toggleMenu()
    }
    @IBAction func btn_Submit(_ sender: UIButton) {
        if Connectivity.isConnectedToInternet {
        let providedEmailAddress = txt_Email.text
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: providedEmailAddress!)
        if (txt_FirstName.text?.removingWhitespaces(txt_FirstName.text).isEmpty)!{
            Toast(text: "Please enter firstname").show()
        }else if (txt_LastName.text?.removingWhitespaces(txt_LastName.text).isEmpty)!{
            Toast(text: "Please enter lastname").show()
        }else if (txt_Email.text?.removingWhitespaces(txt_Email.text).isEmpty)!{
            Toast(text: "Please enter email").show()
        }else if !(isEmailAddressValid){
            Toast(text: "Please enter valid email").show()
        }else if (phoneNumberTextField.text?.removingWhitespaces(phoneNumberTextField.text).isEmpty)!{
            Toast(text: "Please enter mobile number").show()
        }else if isValidMobile == false{
            Toast(text: "Please enter valid mobile number").show()
        }else if (txt_Password.text?.removingWhitespaces(txt_Password.text).isEmpty)!{
            Toast(text: "Please enter password").show()
        }else if (txt_ConPassword.text?.removingWhitespaces(txt_ConPassword.text).isEmpty)!{
            Toast(text: "Please enter confirm password").show()
        }else if !(txt_Password.text == txt_ConPassword.text) {
            Toast(text: "Passwords do not match").show()
        }else if (txt_Password.text?.count)! <= 5 {
            Toast(text: "Password Should be at least 6 character long (without blank spaces before/after").show()
        }else{
            let str_NewFCMToken = UserDefaults.standard.value(forKey: "FCMToken")
            let dictParams: [String: AnyObject] = ["firstname" : txt_FirstName.text as AnyObject ,
                                                   "email" : txt_Email.text as AnyObject , 
                "password" : txt_Password.text as AnyObject ,
                "lastname" : txt_LastName.text as AnyObject ,
                "username" : txt_Email.text as AnyObject,
                "ApplicationToken" :  str_NewFCMToken as AnyObject,
                "contact" : str_Mobile as AnyObject
            ]
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
            Webservices_Alamofier.postWithURL(serverlink: ConstantsModel.WebServiceUrl.API_Register, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
                vw_Load_BK.removeFromSuperview()
                UserDefaults.standard.set(Bool(false), forKey:"isLogin")
                UserDefaults.standard.setValue(self.txt_Password.text, forKey:"password")
                UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
                UserDefaults.standard.synchronize()
                let returncode = dictionary["returncode"] as! NSInteger
                 if returncode == 8 {
                    Toast(text: (self.txt_Email.text!) + " is already a VeriDoc Global account. Try another email or sign in now").show()
                 }else {
                    if bool == true {
                        let saveSuccessful: Bool = KeychainWrapper.standard.set(dictionary, forKey: ConstantsModel.KeyDefaultUser.userData)
                        print("Save was successful: \(saveSuccessful)")
                        let returncode = dictionary["returncode"] as! NSInteger
                        if returncode == 1 {
                            Toast(text: (dictionary["returnmessage"] as! String)).show()
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
                            UserDefaults.standard.set(String(self.str_Mobile), forKey: "ContactNo")
                            UserDefaults.standard.synchronize()
                            self.txt_ConPassword.text = nil
                            self.txt_Password.text = nil
                            self.txt_LastName.text = nil
                            self.txt_FirstName.text = nil
                            self.txt_Email.text = nil
                            self.phoneNumberTextField.text = nil
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Continue_ViewController") as? VDG_Continue_ViewController
                            vc?.dic_SignUp = dictionary
                            vc?.isFromSignUp = true
                            self.navigationController?.pushViewController(vc!, animated: true)
                        }else {
                            Toast(text: (dictionary["returnmessage"] as! String)).show()
                        }
                    }
                }
            }
        }
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
extension VDG_SignUp_ViewController: FPNTextFieldDelegate {
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
        str_Mobile = textField.getFormattedPhoneNumber(format: .E164)
    }
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
}
