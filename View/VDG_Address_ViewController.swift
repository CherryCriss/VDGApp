import UIKit
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import PKHUD
class VDG_Address_ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var btn_Back: UIButton!
    @IBOutlet var btn_Edit: UIButton!
    @IBOutlet var txt_Address: UITextView!
    @IBOutlet var txt_Contact: UITextView!
    @IBOutlet weak var lbl_version: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        txt_Contact.delegate = self
        txt_Address.delegate = self
         self.navigationController?.navigationBar.isHidden = true
        get_Scratches_Info()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == txt_Address {
            if textView.text == "Please enter address" {
                textView.text = nil
                self.txt_Address.textAlignment = NSTextAlignment.left
                self.txt_Address.textColor = UIColor.black
            }else {
                self.txt_Address.textAlignment = NSTextAlignment.center
                self.txt_Address.textColor = UIColor.black
            }
        }
        if textView == txt_Contact {
            if textView.text == "Please enter contact" {
                textView.text = nil
                self.txt_Contact.textAlignment = NSTextAlignment.left
                self.txt_Contact.textColor = UIColor.black
            }else {
                self.txt_Contact.textAlignment = NSTextAlignment.center
                self.txt_Contact.textColor = UIColor.black
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == txt_Address {
            if textView.text == "Please enter address" {
                textView.text = nil
                self.txt_Address.textAlignment = NSTextAlignment.center
                self.txt_Address.textColor = UIColor.black
            }else {
                self.txt_Address.textAlignment = NSTextAlignment.left
                self.txt_Address.textColor = UIColor.black
            }
        }
        if textView == txt_Contact {
            if textView.text == "Please enter contact" {
                textView.text = nil
                self.txt_Contact.textAlignment = NSTextAlignment.center
                self.txt_Contact.textColor = UIColor.black
            }else {
                self.txt_Contact.textAlignment = NSTextAlignment.left
                self.txt_Contact.textColor = UIColor.black
            }
        }
    }
    @IBAction func btn_Edit(_ sender: UIButton) {
        if txt_Address.isEditable == true {
            let str_add = txt_Address.text.trimmingCharacters(in: .whitespaces)
            let str_con = txt_Contact.text.trimmingCharacters(in: .whitespaces)
            if str_add.count == 0 || str_add == "Please enter address" {
               Toast(text: "Please enter address").show()
            }else if str_con.count == 0 || str_con == "Please enter contact"  {
               Toast(text: "Please enter contact").show()
            }else {
               updateHistory()
            }
        }else {
            txt_Address.isEditable = true
            txt_Contact.isEditable = true
            btn_Edit.setTitle("Save", for: .normal)
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.05
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: txt_Address.center.x - 5, y: txt_Address.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: txt_Address.center.x + 5, y: txt_Address.center.y))
            txt_Address.layer.add(animation, forKey: "position")
            let animation1 = CABasicAnimation(keyPath: "position")
            animation1.duration = 0.05
            animation1.repeatCount = 4
            animation1.autoreverses = true
            animation1.fromValue = NSValue(cgPoint: CGPoint(x: txt_Contact.center.x - 5, y: txt_Contact.center.y))
            animation1.toValue = NSValue(cgPoint: CGPoint(x: txt_Contact.center.x + 5, y: txt_Contact.center.y))
            txt_Contact.layer.add(animation1, forKey: "position")
        }
    }
    @IBAction func btn_Close(_ sender: UIButton) {
        _ = navigationController?.popToRootViewController(animated: false)
    }
    func updateHistory() {
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userID = userDetail!["customerguid"] as! String
         var dic_Histrory: Dictionary = [String: AnyObject]()
        dic_Histrory["contactInfo"] = txt_Contact.text as AnyObject
        dic_Histrory["address"] = txt_Address.text as AnyObject
        let refT = Database.database().reference()
                refT.child("VeridocMainApp").child(userID).child((userID)+"-user_info_mainapp").updateChildValues(dic_Histrory)
        txt_Address.isEditable = false
        txt_Contact.isEditable = false
        btn_Edit.setTitle("Edit", for: .normal)
    }
    func get_Scratches_Info() {
        var ref = Database.database().reference() 
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userID = userDetail!["customerguid"] as! String
        let str_Date = UserDefaults.standard.object(forKey: "C_D") as! String
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
        ref = Database.database().reference().child("VeridocMainApp").child(userID).child(userID+"-user_info_mainapp")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
            if snapshot.exists() {
                print(snapshot.value as Any)
                let dic_Info = snapshot.value as! NSDictionary
                let str_Addresss = dic_Info["address"] as! String
                let str_ContactInfo = dic_Info["contactInfo"] as! String
                if str_Addresss.count > 0 {
                    self.txt_Address.text = str_Addresss
                    self.txt_Address.textAlignment = NSTextAlignment.left
                    self.txt_Address.textColor = UIColor.black
                }else {
                    self.txt_Address.text = "Please enter address"
                    self.txt_Address.textAlignment = NSTextAlignment.center
                    self.txt_Address.textColor = UIColor.lightGray
                }
                if str_ContactInfo.count > 0 {
                    self.txt_Contact.text = str_ContactInfo
                    self.txt_Contact.textAlignment = NSTextAlignment.left
                    self.txt_Contact.textColor = UIColor.black
                }else {
                    self.txt_Contact.text = "Please enter contact"
                    self.txt_Contact.textAlignment = NSTextAlignment.center
                    self.txt_Contact.textColor = UIColor.lightGray
                }
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
