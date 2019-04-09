import UIKit
import WebKit
class ABWebViewController: UIViewController, UIScrollViewDelegate {
    var isWebloaded: Bool!
    var timer = Timer()
    let scrollView = UIScrollView()
    let label = UILabel()
    var counter = 1
    @IBOutlet var vw_BK_Error: UIView!
    @IBOutlet var lbl_SorryMsg: UILabel!
    fileprivate let keyLoading = "loading"
    fileprivate let keyEstimateProgress = "estimatedProgress"
    var str_Text: String!
    open var URLToLoad: String = ""
    open var progressTintColor : UIColor?
    open var trackTintColor : UIColor?
    var webView: WKWebView
    @IBOutlet fileprivate weak var loadingProgress: UIProgressView!
    @IBOutlet fileprivate weak var webViewContainer: UIView!
    required init?(coder aDecoder: NSCoder) {
        webView = WKWebView()
        super.init(coder: aDecoder)
        webView.navigationDelegate = self
    }
    public var elementsToRemove: [String] = [
        "header",
        "app-footer",
        "footer",
        "top-bar-main"
    ]
    public var internalHosts: [String] = ["agostini.tech"]
    public var favourites: [String] = []
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        webView = WKWebView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        webView.navigationDelegate = self
    }
    func loadingWeb(){
        viewConfigurations()
        registerObservers()
        isWebloaded = true
        vw_BK_Error.isHidden =  true
        webViewContainer.isHidden = false
        loadingProgress.isHidden = false
    }
    @objc func timerAction() {
        if Network.reachability?.isReachable == true {
            loadingWeb()
        }else{
            isWebloaded = false
            vw_BK_Error.isHidden =  false
            webViewContainer.isHidden = true
            loadingProgress.isHidden = true
            timer.invalidate() 
            timer = Timer.scheduledTimer(timeInterval: 0.10, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
         print(URLToLoad)
        if str_Text.count>0 {
            let isURL = canOpenURL(string: str_Text)
            vw_BK_Error.isHidden =  true
            webViewContainer.isHidden = false
            loadingProgress.isHidden = false
            if isURL == true {
                if Network.reachability?.isReachable == true {
                    loadingWeb()
                }else{
                    vw_BK_Error.isHidden =  false
                    webViewContainer.isHidden = true
                    loadingProgress.isHidden = true
                    timer.invalidate() 
                    timer = Timer.scheduledTimer(timeInterval: 0.10, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
                }
            }else{
                isWebloaded = false
                loadingProgress.isHidden = true
                let Text_height = heightForView(text: str_Text, font: UIFont.systemFont(ofSize: 17), width: 300)
                print(Text_height)
                let yPosition = (scrollView.frame.size.height / 2) - (Text_height/2)
               print(yPosition)
                let H_textview = CGFloat(self.view.frame.size.height-90)
                var textView = UITextView()
                if Text_height > H_textview {
                     textView = UITextView(frame: CGRect(x: 10, y:80, width: self.view.frame.size.width-20, height: self.view.frame.size.height-90))
                }else {
                     let yPosition = ((self.view.frame.size.height+80) / 2) - (Text_height/2)
                      textView = UITextView(frame: CGRect(x: 10, y:yPosition, width: self.view.frame.size.width-20, height: Text_height+20))
                }
                textView.textAlignment = NSTextAlignment.justified
                textView.textColor = UIColor.black
                textView.font = UIFont.systemFont(ofSize: 17.0)
                textView.textAlignment = .center
                textView.backgroundColor = UIColor.clear
                textView.text = URLToLoad
                self.view.addSubview(textView)
                textView.layer.borderWidth = 1.0
                textView.layer.cornerRadius = 8
                textView.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
                textView.layer.masksToBounds = true
                textView.isEditable = false
                textView.dataDetectorTypes =  .phoneNumber
                textView.dataDetectorTypes =  .address
            }
        }else {
            isWebloaded = false
            vw_BK_Error.isHidden =  false
            webViewContainer.isHidden = true
            loadingProgress.isHidden = true
            if let currentToast = ToastCenter.default.currentToast {
            }else {
                Toast(text: "No Valid QR Code Found!!!").show()
            }
            self.navigationController?.navigationBar.isHidden = true
            _ = navigationController?.popViewController(animated: false)
        }
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationController?.navigationBar.isHidden = true
        vw_BK_Error.isHidden =  true
        webViewContainer.isHidden = true
        loadingProgress.isHidden = true
        lbl_SorryMsg.textColor = Constant.GlobalConstants.kColor_Theme
    }
    func canOpenURL(string: String?) -> Bool {
        var str_Main = string
        let str_tmp = str_Main?.last
        if str_tmp == "/" {
            str_Main = String((str_Main?.dropLast())!)  
        }
        guard let urlString = str_Main else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url as URL) {return false}
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: str_Main)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    deinit {
        let isURL = canOpenURL(string: URLToLoad)
        if isURL == true {
            removeObservers()
            visibleActivityIndicator(false)
        }else{
        }
    }
    fileprivate func viewConfigurations() {
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = false
        automaticallyAdjustsScrollViewInsets = false
        loadingProgress.trackTintColor = trackTintColor
        loadingProgress.progressTintColor = progressTintColor
        webViewContainer.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [.top, .bottom, .right, .left]
        NSLayoutConstraint.activate(attributes.map {
            NSLayoutConstraint(item: webView, attribute: $0, relatedBy: .equal, toItem: webViewContainer, attribute: $0, multiplier: 1, constant: 0)
        })
        guard let url = URL(string: URLToLoad) else {
            print("Couldn't load create NSURL from: " + URLToLoad)
            let height = heightForView(text: "Couldn't load create NSURL from: " + URLToLoad, font: UIFont.systemFont(ofSize: 17), width: 300)
            print(height)
            let yPosition = (self.view.frame.size.height / 2) - (height/2)
            print(yPosition)
            let proNameLbl = UILabel(frame: CGRect(x: 10, y: yPosition, width: self.view.frame.size.width-20, height: height+8))
            proNameLbl.text = URLToLoad
            proNameLbl.font = UIFont.systemFont(ofSize: 17)
            proNameLbl.numberOfLines = 0
            proNameLbl.textColor = UIColor.black
            proNameLbl.textAlignment = .center
            proNameLbl.lineBreakMode = .byWordWrapping
            self.view.addSubview(proNameLbl)
            proNameLbl.layer.borderWidth = 1.0
            proNameLbl.layer.cornerRadius = 8
            proNameLbl.layer.borderColor = Constant.GlobalConstants.kColor_Theme.cgColor
            proNameLbl.layer.masksToBounds = true
            return
        }
        webView.load(URLRequest(url: url))
    }
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    @IBAction func btn_back(_ sender: UIButton) {
         self.navigationController?.navigationBar.isHidden = true
    _ = navigationController?.popViewController(animated: false)
    }
    fileprivate func registerObservers() {
        webView.addObserver(self, forKeyPath: keyLoading, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: keyEstimateProgress, options: .new, context: nil)
    }
    fileprivate func removeObservers() {
           let isURL = canOpenURL(string: str_Text)
            if isURL == true {
               if Network.reachability?.isReachable == true {
                if isWebloaded == true {
                    webView.removeObserver(self, forKeyPath: keyLoading)
                    webView.removeObserver(self, forKeyPath: keyEstimateProgress)
                }
              }
            }
    }
    fileprivate func visibleActivityIndicator(_ visible: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = visible
    }
    fileprivate func showAlert(_ title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title,
                                                                   message: message,
                                                                   preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == keyEstimateProgress) {
            loadingProgress.isHidden = webView.estimatedProgress == 1
            loadingProgress.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
}
extension ABWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        visibleActivityIndicator(true)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        visibleActivityIndicator(false)
        showAlert("", message: error.localizedDescription)
    }
    func removeElements(fromWebView webView: WKWebView) {
        self.elementsToRemove.forEach { self.removeElement(elementID: $0, fromWebView: webView) }
    }
    func removeElement(elementID: String, fromWebView webView: WKWebView) {
        let removeElementClassScript = "document.getElementsByClassName('\(elementID)')[0].style.display=\"none\";"
        webView.evaluateJavaScript(removeElementClassScript) { (removeElementIdScript, error) in
            if error != nil {
                print(removeElementIdScript)
            }
            else{
                print(error?.localizedDescription)
            }
        }
    }
   func isExternalHost(forURL url: URL) -> Bool {
        if let host = url.host, internalHosts.contains(host) {
            return false
        }
        return true
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        visibleActivityIndicator(false)
        loadingProgress.setProgress(0.0, animated: false)
        self.removeElements(fromWebView: webView)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            let url = navigationAction.request.url
            let shared = UIApplication.shared
            if shared.canOpenURL(url!) {
                shared.openURL(url!)
            }else{
                print("errrrrrr")
            }
            decisionHandler(WKNavigationActionPolicy.cancel)
        }else{
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
}
