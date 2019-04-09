import UIKit
protocol AlertViewControllerDelegate {
    func SubmitAlertViewResult(textValue : String)
}
class AlertViewController {
    static let sharedInstance = AlertViewController()
    private init(){}
    var delegate : AlertViewControllerDelegate?
    func SubmitAlertView(viewController : UIViewController,title : String, message : String){
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0]
            if(textField.text != "")
            {
                self.delegate?.SubmitAlertViewResult(textValue: textField.text!)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "enter any text value"
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(submitAction)
        alert.addAction(cancel)
        viewController.present(alert, animated: true, completion: nil)
    }
}
