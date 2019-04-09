import UIKit
import MessageUI
import SwiftKeychainWrapper
import PasswordTextField
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import Branch
import FirebaseMessaging
import PKHUD
import AVFoundation
import NVActivityIndicatorView
class VDG_MyProfile_ViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     var window: UIWindow?
    @IBOutlet var vw_Bk1 : UIView!
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var img_Profile : UIImageView!
    @IBOutlet var lbl_HeaderName: UILabel!
    @IBOutlet var lbl_email: UILabel!
    @IBOutlet var lbl_Contact: UILabel!
    @IBOutlet var lbl_FirstName: UILabel!
    @IBOutlet var lbl_LastName: UILabel!
    @IBOutlet  var btn_changepassword: UIButton!
    @IBOutlet  var btn_Address: UIButton!
    @IBOutlet var btn_firstNameEdit: UIButton!
    @IBOutlet var btn_lastNameEdit: UIButton!
    @IBOutlet var img_Trans: UIImageView!
    @IBOutlet var vw_ChangePass_BK: UIView!
    @IBOutlet var txt_OldPassword: UITextField!
    @IBOutlet var txt_NewPassword: UITextField!
    @IBOutlet var txt_ConmfirmPassword: UITextField!
    @IBOutlet var btn_Save: UIButton!
    @IBOutlet var btn_Cancel: UIButton!
    @IBOutlet weak var lbl_version: UILabel!
    @IBOutlet weak var txt_Address: UITextView!
    @IBOutlet var vw_ProfileImage_BK: UIView!
    let imagePicker =  UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
       self.navigationController?.navigationBar.isHidden = true
        self.title = "My Profile"
        imagePicker.delegate = self
        img_Profile.layer.cornerRadius = img_Profile.frame.size.width / 2
        img_Profile.clipsToBounds = true
        img_Profile.layer.borderColor = UIColor.white.cgColor
        img_Profile.layer.borderWidth = 3.0
        lbl_email.layer.cornerRadius = 8
        lbl_email.layer.cornerRadius = 8
        lbl_email.clipsToBounds = true
        img_Trans.isHidden = true
        vw_ChangePass_BK.isHidden = true
        vw_ChangePass_BK.layer.cornerRadius = 8
        vw_ChangePass_BK.clipsToBounds = true
        btn_Save.layer.cornerRadius = 8
        btn_Cancel.layer.cornerRadius = 8
        btn_Save.clipsToBounds = true
        btn_Cancel.clipsToBounds = true
        txt_NewPassword.isSecureTextEntry = true
        txt_OldPassword.isSecureTextEntry = true
        txt_ConmfirmPassword.isSecureTextEntry = true
          let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
           img_Profile.addGestureRecognizer(tap)
            img_Profile.isUserInteractionEnabled = true
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let dictionary = Bundle.main.infoDictionary!
            let version = dictionary["CFBundleShortVersionString"] as! String
            let build = dictionary["CFBundleVersion"] as! String
            lbl_version.text =  "Version \(version)"
        }
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        if userDetail!["contact"] != nil {
            let trimmedString = (userDetail!["contact"] as? String)?.trimmingCharacters(in: .whitespaces)
            if let actionString = userDetail!["contact"] as? String  {
                lbl_Contact.text = actionString
            }else {
                if UserDefaults.standard.string(forKey: "ContactNo") != nil {
                    lbl_Contact.text = UserDefaults.standard.string(forKey: "ContactNo")
                }else {
                    lbl_Contact.text = "No Contact Number"
                }
            }
        }else {
            if UserDefaults.standard.string(forKey: "ContactNo") != nil {
                lbl_Contact.text = UserDefaults.standard.string(forKey: "ContactNo")
            }else {
                lbl_Contact.text = "No Contact Number"
            }
        }
        let userfirstname = userDetail!["firstname"] as! String
        let userlastname = userDetail!["lastname"] as! String
        let useremail = userDetail!["email"] as! String
        lbl_FirstName.text = userfirstname+" "+userlastname
        lbl_HeaderName.text = userfirstname+" "+userlastname
        lbl_email.text = useremail
    }
    override func viewDidAppear(_ animated: Bool) {
        self.vw_ProfileImage_BK.addSubview(imageView)
        imageView.backgroundColor = Constant.GlobalConstants.kColor_Theme
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2.0
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ChangeUserData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.messagereceived(notification:)), name: NSNotification.Name(rawValue: "ChangeUserData"), object: nil)
         let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userfirstname = userDetail!["firstname"] as! String
        let userlastname = userDetail!["lastname"] as! String
        let useremail = userDetail!["email"] as! String
        lbl_FirstName.text = userfirstname+" "+userlastname
        lbl_HeaderName.text = userfirstname+" "+userlastname
        lbl_email.text = useremail
        getProfile()
    }
    @objc func messagereceived(notification: Notification) {
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if isLogin == true {
            if Connectivity.isConnectedToInternet {
                self.getProfile()
            }else {
                self.img_Profile.image = UIImage(named: "img_placeholder")
            }
        }
    }
    func getProfile() {
        var ref = Database.database().reference() 
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userID = userDetail!["customerguid"] as! String
        ref = Database.database().reference().child("profile").child(userID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                print(snapshot.value as Any)
                let dic_Info = snapshot.value as! String
                print(dic_Info)
                if dic_Info != nil {
                    var str_profile = dic_Info
                    if dic_Info  != nil
                    {
                        str_profile = dic_Info
                    }else{
                        str_profile = ""
                    }
                    UserDefaults.standard.set(str_profile, forKey: "profile")
                    UserDefaults.standard.synchronize()
                    if str_profile.count > 0 {
                        let url = URL(string: str_profile)
                        let vw_Load_BK = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                        vw_Load_BK.backgroundColor = UIColor.black
                        vw_Load_BK.alpha = 0.4
                        self.img_Profile.addSubview(vw_Load_BK)
                        let frame = CGRect(x: (self.img_Profile.frame.width/2)-10, y: (self.img_Profile.frame.height/2)-10, width: 20, height: 20)
                        let activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                                            type: NVActivityIndicatorType.ballRotateChase)
                        activityIndicatorView.color = UIColor.white
                        self.img_Profile.addSubview(activityIndicatorView)
                        activityIndicatorView.startAnimating()
                        SDWebImageManager.shared().loadImage(
                            with: URL(string: str_profile),
                            options: .highPriority,
                            progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                                print(isFinished)
                                if activityIndicatorView != nil {
                                    activityIndicatorView.stopAnimating()
                                    activityIndicatorView.removeFromSuperview()
                                    vw_Load_BK.removeFromSuperview()
                                }
                                if error == nil {
                                    self.img_Profile.image = image
                                }else {
                                    self.img_Profile.image = UIImage(named: "img_placeholder")
                                }
                        }
                    }else {
                        self.img_Profile.image = UIImage(named: "img_placeholder")
                    }
                }
            }
        })
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .denied:
                print("Denied, request permission from settings")
                self.presentCameraSettings()
            case .restricted:
                print("Restricted, device owner must approve")
            case .authorized:
                print("Authorized, proceed")
                self.openCamera()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { success in
                    if success {
                        self.openCamera()
                    } else {
                        print("Permission denied")
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = img_Profile
            alert.popoverPresentationController?.sourceRect = img_Profile.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
    }
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        NSLog("\(info)")
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        imagePickerController(picker, pickedImage: image)
        dismiss(animated: true, completion: nil)
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
         img_Profile.image = pickedImage
        let fullNameArr = lbl_FirstName.text?.components(separatedBy: " ")
        let firstN = fullNameArr![0]
        let lastN = fullNameArr![1]
        updateHistory(str_FirsrName: firstN, str_LastName: lastN)
    }
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
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
    @objc func backAction(){
        sideMenuVC.toggleMenu()
    }
    @IBAction func btn_Menu(_ sender: UIButton)  {
        sideMenuVC.toggleMenu()
    }
    @IBAction func btn_BackButton(_ sender: UIButton)  {
         sideMenuVC.toggleMenu()
    }
    @IBAction func btn_ChangePassword(_ sender: UIButton)  {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_EditPassword_ViewController") as! VDG_EditPassword_ViewController
        self.navigationController?.present(secondViewController, animated: true)
    }
    @IBAction func btn_FirstName(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VDG_EditFullName_ViewController") as? VDG_EditFullName_ViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func btn_LastName(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VDG_EditEmail_ViewController") as? VDG_EditEmail_ViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func btn_ChangeMobile(_ sender: UIButton) {
        if Connectivity.isConnectedToInternet {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Phone_ViewController") as! VDG_Phone_ViewController
            secondViewController.is_SideMenu = true
            secondViewController.img_BK_screeen = self.takeScreenshot(false)
            self.present(secondViewController, animated: false)
        }else{
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
    }
    func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
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
    @IBAction func btn_Save(_ sender: UIButton)  {
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
            Toast(text: "New Passsword Should be at least 6 character long (without blank spaces before/after").show()
        }else if (txt_ConmfirmPassword.text?.removingWhitespaces(txt_ConmfirmPassword.text).count)! <= 5 {
            Toast(text: "Confirm Password Should be at least 6 character long (without blank spaces before/after").show()
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
                    self.img_Trans.isHidden = true
                    self.vw_ChangePass_BK.isHidden = true
                    Toast(text: dictionary["returnmessage"] as? String).show()
                    UserDefaults.standard.set(Bool(false), forKey:"isLogin")
                    UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
                    let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: ConstantsModel.KeyDefaultUser.userData)
                    let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_Auth_ViewController")
                    self.window?.rootViewController = mainVcIntial
                }
            }
        }
    }else{
    Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
    }
    }
    func get_Scratches_Info() {
     if Connectivity.isConnectedToInternet {
        var ref = Database.database().reference() 
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userID = userDetail!["customerguid"] as! String
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
        ref = Database.database().reference().child("profile").child(userID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            vw_Load_BK.removeFromSuperview()
            if snapshot.exists() {
                print(snapshot.value as Any)
                let dic_Info = snapshot.value as! String
                print(dic_Info)
                if dic_Info != nil {
                    var str_profile = dic_Info
                    if dic_Info  != nil
                    {
                        str_profile = dic_Info
                    }else{
                        str_profile = ""
                    }
                UserDefaults.standard.set(str_profile, forKey: "profile")
                UserDefaults.standard.synchronize()
                if str_profile.count > 0 {
                    let url = URL(string: str_profile)
                    SDWebImageManager.shared().loadImage(
                        with: URL(string: str_profile),
                        options: .highPriority,
                        progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                            print(isFinished)
                            if error == nil {
                                self.img_Profile.image = image
                            }else {
                                self.img_Profile.image = UIImage(named: "img_placeholder")
                            }
                    }
                }else {
                    self.img_Profile.image = UIImage(named: "img_placeholder")
                }
                }
            }
        })
     }else{
        Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
     }
    }
    func updateHistory(str_FirsrName: String, str_LastName: String) {
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        let userID = userDetail!["customerguid"] as! String
        let vw_Load_BK = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        vw_Load_BK.backgroundColor = UIColor.black
        vw_Load_BK.alpha = 0.4
        img_Profile.addSubview(vw_Load_BK)
        let frame = CGRect(x: (img_Profile.frame.width/2)-25, y: (img_Profile.frame.height/2)-25, width: 50, height: 50)
        let activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                        type: NVActivityIndicatorType.ballRotateChase)
        activityIndicatorView.color = UIColor.white
        img_Profile.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        var data = Data()
        data = img_Profile.image!.jpegData(compressionQuality: 0.8)!
        let imageRef = Storage.storage().reference().child(userID).child("images/ProfileImage.png")
        let uploadPict = imageRef.putData(data, metadata: nil){  (metadata, error) in
            metadata!.contentType = "image/png"
            if activityIndicatorView != nil {
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
                vw_Load_BK.removeFromSuperview()
            }
            self.view.isUserInteractionEnabled = true
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
                    refT.child("profile").child(userID).setValue(urlString)
                    self.lbl_FirstName.text = str_FirsrName+" "+str_LastName
                    self.lbl_HeaderName.text = str_FirsrName+" "+str_LastName
                }else {
                    Toast(text: error?.localizedDescription).show()
                }
            }
        }
    }
    @IBAction func btn_Cancel(_ sender: UIButton)  {
        img_Trans.isHidden = true
        vw_ChangePass_BK.isHidden = true
        txt_NewPassword.text = nil
        txt_ConmfirmPassword.text = nil
        txt_OldPassword.text = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
