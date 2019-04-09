import UIKit
import SwiftKeychainWrapper
import MessageUI
class VDG_AboutUS_ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet var vw_BK_Aboutus: UIView!
    @IBOutlet weak var lbl_version: UILabel!
    @IBOutlet weak var lbl_version1: UILabel!
    var window: UIWindow?
    override func viewDidLoad() {
        super.viewDidLoad()
       self.navigationController?.navigationBar.isHidden = true
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let dictionary = Bundle.main.infoDictionary!
            let version = dictionary["CFBundleShortVersionString"] as! String
            let build = dictionary["CFBundleVersion"] as! String
            lbl_version.text =  "Version \(version)"
            lbl_version1.text =  "Version \(version)"
        }
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
