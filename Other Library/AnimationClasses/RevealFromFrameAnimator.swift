import UIKit
class RevealFromFrameAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    var forward = true
    let duration = 0.3
    var originFrame = CGRect.zero
    weak var animationContext: UIViewControllerContextTransitioning?
    private func maskLayerForAnimation(frame: CGRect) -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.black.cgColor
        let maskRect = frame
        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path
        return maskLayer
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.animationContext = transitionContext
        let containerView = transitionContext.containerView
        var originView: UIView!
        var animatedView: UIView!
        if self.forward {
            animatedView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            originView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            containerView.addSubview(animatedView)
        } else {
            animatedView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            originView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            containerView.addSubview(originView)
            containerView.addSubview(animatedView)
        }
        var startFrame: CGRect!
        var newPath: CGPath!
        if self.forward {
            startFrame = self.originFrame
            newPath = CGPath(rect: animatedView.frame, transform: nil)
        } else {
            startFrame = animatedView.frame
            newPath = CGPath(rect: self.originFrame, transform: nil)
        }
        let maskLayer = self.maskLayerForAnimation(frame: startFrame)
        animatedView.layer.mask = maskLayer
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.delegate = self
        pathAnimation.fromValue = maskLayer.path
        pathAnimation.toValue = newPath
        pathAnimation.duration = duration
        pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        maskLayer.path = newPath
        maskLayer.add(pathAnimation, forKey: "path")
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.animationContext!.completeTransition(flag)
    }
}
