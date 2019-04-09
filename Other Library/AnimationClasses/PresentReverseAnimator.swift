import UIKit
class PresentReverseAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.3
    var isPresenting = true
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        var animatedView: UIView!
        var destinationView: UIView!
        var destinationFrame: CGRect
        if self.isPresenting {
            animatedView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            animatedView.frame = CGRect(x: 0.0, y: -animatedView.frame.height, width: animatedView.frame.width, height: animatedView.frame.height)
            destinationFrame = CGRect(x: 0.0, y: 0.0, width: animatedView.frame.width, height: animatedView.frame.height)
            containerView.addSubview(animatedView)
        } else {
            animatedView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            destinationView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            destinationFrame = CGRect(x: 0.0, y: -animatedView.frame.height, width: animatedView.frame.width, height: animatedView.frame.height)
            containerView.addSubview(destinationView)
            containerView.addSubview(animatedView)
        }
        UIView.animate(withDuration: self.duration, delay: 0.0, options: .curveEaseOut, animations: {
            animatedView.frame = destinationFrame
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}
