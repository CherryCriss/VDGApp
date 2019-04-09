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
class VDG_EditFullName_ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var lbl_FirstName: UITextField!
    @IBOutlet var lbl_LastName: UITextField!
    @IBOutlet var btn_Save: UIButton!
    @IBOutlet var btn_Back: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        btn_Save.layer.cornerRadius = 8
        btn_Save.clipsToBounds = true
    }
    override func viewDidAppear(_ animated: Bool) {
        get_Scratches_Info()
    }
    @IBAction func btn_Save(_ sender: UIButton){
        if Connectivity.isConnectedToInternet {
             let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
            let oldfirstname = userDetail!["firstname"] as! String
            let oldlastname = userDetail!["lastname"] as! String
            let oldfullname = oldfirstname+" "+oldlastname
            let newfirstname = lbl_FirstName.text
            let newlastname = lbl_LastName.text
            let newfullname = newfirstname!+" "+newlastname!
                if  (lbl_FirstName.text?.removingWhitespaces(lbl_FirstName.text).isEmpty)! {
                    Toast(text: "Please enter firstname").show()
                }else if (lbl_LastName.text?.removingWhitespaces(lbl_LastName.text).isEmpty)! {
                    Toast(text: "Please enter lastname").show()
                }else if oldfullname == newfullname {
                    Toast(text: "Please change your details").show()
                }else {
                    API_UpdateContact()
                }
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @IBAction func btn_Back(_ sender: UIButton){
         _ = navigationController?.popToRootViewController(animated: false) 
    }
    func get_Scratches_Info() {
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userfirstname = userDetail!["firstname"] as! String
        let userlastname = userDetail!["lastname"] as! String
        lbl_FirstName.text = userfirstname
        lbl_LastName.text = userlastname
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
        let userfirstname = lbl_FirstName.text
        let userlastname = lbl_LastName.text
        let useremail = userDetail!["email"] as! String
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
                let saveSuccessful: Bool = KeychainWrapper.standard.set(dictionary, forKey: ConstantsModel.KeyDefaultUser.userData)
                print("Save was successful: \(saveSuccessful)")
                if bool == true {
                    let returnCode = dictionary["returncode"] as! Int
                    if returnCode == 1{
                        self.btn_Back(self.btn_Back)
                    }else {
                        Toast(text: (dictionary["returnmessage"] as! String)).show()
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
