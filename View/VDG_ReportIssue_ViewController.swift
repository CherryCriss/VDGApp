import UIKit
import SwiftKeychainWrapper
import MessageUI
import NVActivityIndicatorView
class VDG_ReportIssue_ViewController: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    var window: UIWindow?
    @IBOutlet var txt_Name: UITextField!
    @IBOutlet var txt_Phone: UITextField!
    @IBOutlet var txt_Description: UITextView!
    @IBOutlet var btn_Submit: UIButton!
    @IBOutlet var vw_BK_ContactUs: UIView!
    @IBOutlet var vw_BK_Aboutus: UIView!
    @IBOutlet weak var lbl_version: UILabel!
    var keyboardH = 0 as Int
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.title = "Report Isssue"
        vw_BK_ContactUs.layer.cornerRadius = 1
        vw_BK_ContactUs.clipsToBounds = true
        txt_Description.layer.cornerRadius = 6
        txt_Description.layer.borderColor = UIColor.lightGray.cgColor
        txt_Description.layer.borderWidth = 0.5
        btn_Submit.layer.cornerRadius = 6
        txt_Description.text = "Type your message here"
        txt_Description.textColor = UIColor.lightGray
        txt_Description.delegate = self
        txt_Phone.delegate = self
        txt_Name.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        vw_BK_ContactUs.addGestureRecognizer(tap)
        vw_BK_ContactUs.isUserInteractionEnabled = true
        btn_Submit.layer.cornerRadius = 8
        btn_Submit.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHideShow), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        txt_Name.borderStyle = .none
        txt_Name.layer.backgroundColor = UIColor.clear.cgColor
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: txt_Name.frame.size.height - width, width:  txt_Description.frame.size.width*2, height: txt_Phone.frame.size.height)
        border.borderWidth = width
        txt_Name.layer.addSublayer(border)
        txt_Name.layer.masksToBounds = true
        let border1 = CALayer()
        let width1 = CGFloat(0.5)
        txt_Phone.borderStyle = .none
        txt_Phone.layer.backgroundColor = UIColor.clear.cgColor
        border1.borderColor = UIColor.lightGray.cgColor
        border1.frame = CGRect(x: 0, y: txt_Phone.frame.size.height - width1, width:  txt_Description.frame.size.width*2, height: txt_Phone.frame.size.height)
        border1.borderWidth = width1
        txt_Phone.layer.addSublayer(border1)
        txt_Phone.layer.masksToBounds = true
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            print(keyboardHeight)
            keyboardH = Int(keyboardHeight)
        }
    }
    @objc func keyboardHideShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            print(keyboardHeight)
            keyboardH = 0
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        self.view.frame.origin.y -= CGFloat(keyboardH)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type your message here"
            textView.textColor = UIColor.lightGray
        }
        self.view.endEditing(true)
        self.view.frame.origin.y = 0
    }
    @IBAction func btn_Menu(_ sender: UIButton){
        sideMenuVC.toggleMenu()
    }
    @IBAction func btn_BackButton(_ sender: UIButton)  {
        sideMenuVC.toggleMenu()
    }
    @IBAction func btn_OpenFindUs(_ sender: UIButton) {
        let url = NSURL(string: (sender.titleLabel?.text)!)!
        UIApplication.shared.openURL(url as URL)
    }
    @IBAction func btn_OpenEmailView(_ sender: UIButton) {
        let email = Constant.GlobalConstants.str_Mail
        let subject = ""
        let bodyText = "Please provide information that will help us to serve you better"
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([email])
            mailComposerVC.setSubject(subject)
            mailComposerVC.setMessageBody(bodyText, isHTML: true)
            mailComposerVC.navigationBar.tintColor = UIColor.white
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            let coded = "mailto:\(email)?subject=\(subject)&body=\(bodyText)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let emailURL = URL(string: coded!)
            {
                if UIApplication.shared.canOpenURL(emailURL)
                {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(emailURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (result) in
                            if !result {
                            }
                        })
                    } else {
                    }
                }
            }
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
    @IBAction func btn_Send_Message(_ sender: UIButton) {
        if Connectivity.isConnectedToInternet {
        let providedEmailAddress = txt_Phone.text!
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: providedEmailAddress)
        if (txt_Name.text?.removingWhitespaces(txt_Name.text).isEmpty)!{
            Toast(text: "Please enter name").show()
        }else if (txt_Phone.text?.removingWhitespaces(txt_Phone.text).isEmpty)!{
            Toast(text: "Please enter email").show()
        }else if !(isEmailAddressValid){
            Toast(text: "Please enter valid email").show()
        }else if (txt_Description.text == "Type your message here") {
            Toast(text: "Please enter message").show()
        }else if (txt_Description.text?.removingWhitespaces(txt_Description.text).isEmpty)!{
            Toast(text: "Please enter message").show()
        }else{
            let retrievedPassword: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
            let dictParams: [String: AnyObject] = ["customerguid" : retrievedPassword!["customerguid"] as AnyObject ,
                                                   "name" : txt_Name.text as AnyObject ,
                                                   "email" : retrievedPassword!["email"] as AnyObject ,
                                                   "phone" : txt_Phone.text as AnyObject ,
                                                   "message" : txt_Description.text as AnyObject,
                                                   "AppType" : 1 as AnyObject,
                                                   "ContactType": 2 as AnyObject
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
            Webservices_Alamofier.postWithURL(serverlink: ConstantsModel.WebServiceUrl.API_contactus, methodname: "", param:dictParams as NSDictionary, key: "key") { (bool, dictionary) in
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
                vw_Load_BK.removeFromSuperview()
                if bool == true {
                    self.txt_Name.text = nil
                    self.txt_Phone.text = nil
                    self.txt_Description.text = "Type your message here"
                    self.txt_Description.textColor = UIColor.lightGray
                    Toast(text: (dictionary["returnmessage"] as! String)).show()
                }
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
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
