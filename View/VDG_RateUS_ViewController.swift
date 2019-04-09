import UIKit
class VDG_RateUS_ViewController: UIViewController {
    var window: UIWindow?
    @IBOutlet var vw_Rate: UIView!
    @IBOutlet var btn_Submit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
     self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        print(vw_Rate.frame.width/2)
        let starRatingView = HCSStarRatingView(frame: CGRect(x: 0, y: 0, width: vw_Rate.frame.width, height: vw_Rate.frame.height))
        starRatingView.maximumValue = 5
        starRatingView.minimumValue = 0
        starRatingView.value = 0
        starRatingView.emptyStarImage = UIImage(named: "icn_rate_empty")
        starRatingView.filledStarImage = UIImage(named: "icn_rate_fill")
        vw_Rate.addSubview(starRatingView)
        print(starRatingView.frame.width)
        let X1 = starRatingView.frame.width/2 as CGFloat
        let X2 = vw_Rate.frame.width/2 as CGFloat
        let X3 = X2 - X1
        let yPosition = starRatingView.frame.origin.y
        let height = starRatingView.frame.size.height
        let width = starRatingView.frame.size.width
        UIView.animate(withDuration: 0.5, animations: {
        })
        btn_Submit.layer.cornerRadius = 8
        btn_Submit.clipsToBounds = true
    }
    @IBAction func btn_RateUs(_ sender: UIButton) {
        if let url = URL(string: "https://itunes.apple.com/us/app/veridoc-global/id1425726642?mt=8"),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:]) { (opened) in
                if(opened){
                    print("App Store Opened")
                }
            }
        } else {
            print("Can't Open URL on Simulator")
        }
    }
    @IBAction func btn_BackButton(_ sender: UIButton)  {
        sideMenuVC.toggleMenu()
    }
    @IBAction func btn_NotNow(_ sender: UIButton) {
       kConstantObj.SetIntialMainViewController("VDG_QRScanner_ViewController")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
