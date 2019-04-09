import UIKit
class CustomAlertView: UIViewController {
    @IBOutlet weak var Img_title: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var SubmessageLabel: UILabel!
    @IBOutlet weak var alertTextField: UITextField!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var img_TitleView: UIImage!
    var str_TitleMsg: String!
    var str_SubTitleMsg: String!
    var str_SubTitleMsg2: String!
    var str_ButtonTitle: String!
    var delegate: CustomAlertViewDelegate?
    var selectedOption = "First"
    var screenId: Int = 0
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        Img_title.layer.borderWidth = 1
        Img_title.layer.masksToBounds = false
        Img_title.layer.borderColor = UIColor.white.cgColor
        Img_title.layer.cornerRadius = Img_title.frame.height/2
        Img_title.clipsToBounds = true
        Img_title.image = img_TitleView
        titleLabel.text = str_TitleMsg
        messageLabel.text = str_SubTitleMsg
        SubmessageLabel.text = str_SubTitleMsg2
        okButton.setTitle(str_ButtonTitle, for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        okButton.layer.cornerRadius = 8;
    }
    func setupView() {
        alertView.layer.cornerRadius = 8
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    @IBAction func onTapCancelButton(_ sender: Any) {
        alertTextField.resignFirstResponder()
            delegate?.cancelButtonTapped()
            self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onTapOkButton(_ sender: Any) {
        alertTextField.resignFirstResponder()
        delegate?.okButtonTapped(selectedOption: selectedOption, textFieldValue: alertTextField.text!)
            self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onTapSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("First option")
            selectedOption = "First"
            break
        case 1:
            print("Second option")
            selectedOption = "Second"
            break
        default:
            break
        }
    }
}
