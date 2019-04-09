import UIKit
class VDG_FAQ_ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var window: UIWindow?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbl_version: UILabel!
    var dataSource = LyricsGenerator.getLyrics()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
         setupUI()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let dictionary = Bundle.main.infoDictionary!
            let version = dictionary["CFBundleShortVersionString"] as! String
            let build = dictionary["CFBundleVersion"] as! String
            lbl_version.text =  "Version \(version)"
        }
    }
    func DeviceDetect() -> String {
        var str_DeviceType: String!
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone1")
                str_DeviceType = "iPhone1"
            case 1334:
                print("iPhone 6/6S/7/8")
                str_DeviceType = "iPhone2"
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                str_DeviceType = "iPhone3"
            case 2436:
                print("iPhone X, Xs")
                str_DeviceType = "iPhone4"
            case 2688:
                print("iPhone Xs Max")
                str_DeviceType = "iPhone5"
            case 1792:
                print("iPhone Xr")
                str_DeviceType = "iPhone6"
            default:
                print("unknown")
            }
        }
        return str_DeviceType
    }
    @IBAction func btn_Menu(_ sender: UIButton)  {
        sideMenuVC.toggleMenu()
    }
    @IBAction func btn_BackButton(_ sender: UIButton)  {
         sideMenuVC.toggleMenu()
    }
    override func viewDidAppear(_ animated: Bool) {
        let image = Constant.GradientImage() as UIImage?
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    func setupUI() {
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        cell.setValues(dataSource[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lyrics = dataSource[indexPath.row]
        let lyricsShown = dataSource[indexPath.row].lyricsShown
        lyrics.lyricsShown = !lyricsShown
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
