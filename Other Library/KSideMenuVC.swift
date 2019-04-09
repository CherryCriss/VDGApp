import Foundation
import UIKit
class KSideMenuVC: UIViewController,UIGestureRecognizerDelegate {
    var mainContainer : UIViewController?
    var menuContainer : UIViewController?
    var menuViewController : UIViewController?
    var mainViewController : UIViewController?
    var bgImageContainer : UIImageView?
    var distanceOpenMenu : CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
       setUp()
    }
    func setUp(){
        self.distanceOpenMenu = self.view.frame.size.width-(self.view.frame.size.width/3);
        self.view.backgroundColor = Constant.GlobalConstants.kColor_Theme;
        self.menuContainer = UIViewController()
        self.menuContainer!.view.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5);
        self.menuContainer!.view.frame = self.view.bounds;
        self.menuContainer!.view.backgroundColor = Constant.GlobalConstants.kColor_Theme;
        self.addChild(self.menuContainer!)
        self.view.addSubview((self.menuContainer?.view)!)
        self.menuContainer?.didMove(toParent: self)
         self.mainContainer = UIViewController()
        self.mainContainer!.view.frame = self.view.bounds;
        self.mainContainer!.view.backgroundColor = UIColor.clear;
        self.addChild(self.mainContainer!)
        self.view.addSubview((self.mainContainer?.view)!)
        self.mainContainer?.didMove(toParent: self)
    }
    func menuViewController(_ menuVC : UIViewController)
    {
        if (self.menuViewController != nil) {
            self.menuViewController?.willMove(toParent: nil)
            self.menuViewController?.removeFromParent()
            self.menuViewController?.view.removeFromSuperview()
        }
        self.menuViewController = menuVC;
        self.menuViewController!.view.frame = self.view.bounds;
        self.menuContainer?.addChild(self.menuViewController!)
        self.menuContainer?.view.addSubview(menuVC.view)
        self.menuContainer?.didMove(toParent: self.menuViewController)
    }
    func mainViewController(_ mainVC : UIViewController)
    {
        closeMenu()
        if (self.mainViewController != nil) {
            self.mainViewController?.willMove(toParent: nil)
            self.mainViewController?.removeFromParent()
            self.mainViewController?.view.removeFromSuperview()
        }
        self.mainViewController = mainVC;
        self.mainViewController!.view.frame = self.view.bounds;
        self.mainContainer?.addChild(self.mainViewController!)
        self.mainContainer?.view.addSubview(self.mainViewController!.view)
        self.mainViewController?.didMove(toParent: self.mainContainer)
        if (self.mainContainer!.view.frame.minX == self.distanceOpenMenu) {
            closeMenu()
        }
    }
    func openMenu(){
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ChangeUserData"),object: nil))
        addTapGestures()
        var fMain : CGRect = self.mainContainer!.view.frame
        fMain.origin.x = self.distanceOpenMenu;
        UIView.animate(withDuration: 0.7, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: { () -> Void in
            let layerTemp : CALayer = (self.mainContainer?.view.layer)!
            layerTemp.zPosition = 1000
            var tRotate : CATransform3D = CATransform3DIdentity
            tRotate.m34 = 1.0/(-500)
            let aXpos: CGFloat = CGFloat(-20.0*(.pi/180))
            tRotate = CATransform3DRotate(tRotate,aXpos, 0, 1, 0)
            var tScale : CATransform3D = CATransform3DIdentity
            tScale.m34 = 1.0/(-500)
            tScale = CATransform3DScale(tScale, 1.0, 1.0, 1.0);
            layerTemp.transform = CATransform3DConcat(tScale, tRotate)
            self.mainContainer?.view.frame = fMain
            }) { (finished: Bool) -> Void in
        }
    }
    func closeMenu(){
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ChangeUserData"),object: nil))
        var fMain : CGRect = self.mainContainer!.view.frame
        fMain.origin.x = 0
        UIView.animate(withDuration: 0.7, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: { () -> Void in
            self.mainContainer?.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            let layerTemp : CALayer = (self.mainContainer?.view.layer)!
            layerTemp.zPosition = 1000
            var tRotate : CATransform3D = CATransform3DIdentity
            tRotate.m34 = 1.0/(-500)
            let aXpos: CGFloat = CGFloat(0.0*(M_PI/180))
            tRotate = CATransform3DRotate(tRotate,aXpos, 0, 1, 0)
              layerTemp.transform = tRotate
            var tScale : CATransform3D = CATransform3DIdentity
            tScale.m34 = 1.0/(-500)
            tScale = CATransform3DScale(tScale,1.0, 1.0, 1.0);
            layerTemp.transform = tScale;
            layerTemp.transform = CATransform3DConcat(tRotate, tScale)
            layerTemp.transform = CATransform3DConcat(tScale, tRotate)
            self.mainContainer!.view.frame = CGRect(x: 0, y: 0, width: appDelegate.window!.frame.size.width, height: appDelegate.window!.frame.size.height)
            }) { (finished: Bool) -> Void in
                self.mainViewController!.view.isUserInteractionEnabled = true
                self.removeGesture()
        }
    }
    func addTapGestures(){
        self.mainViewController!.view.isUserInteractionEnabled = false
        let tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(KSideMenuVC.tapMainAction))
        self.mainContainer!.view.addGestureRecognizer(tapGestureRecognizer)
    }
    func removeGesture(){
        for recognizer in  self.mainContainer!.view.gestureRecognizers ?? [] {
            if (recognizer .isKind(of: UITapGestureRecognizer.self)){
                self.mainContainer!.view.removeGestureRecognizer(recognizer)
            }
        }
    }
    @objc func tapMainAction(){
        closeMenu()
    }
    func toggleMenu(){
        let fMain : CGRect = self.mainContainer!.view.frame
        if (fMain.minX == self.distanceOpenMenu) {
           closeMenu()
        }else{
           openMenu()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
