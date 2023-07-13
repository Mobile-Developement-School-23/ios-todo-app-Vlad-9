import UIKit

// MARK: - UIViewControllerAnimatedTransitioning

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
  let duration = 0.35
  var presenting = true
  var originFrame = CGRect.zero

  var dismissCompletion: (() -> Void)?

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    let containerView = transitionContext.containerView
    let toView = presenting ? transitionContext.view(forKey: .to)! : transitionContext.view(forKey: .from)!
      let secondView = presenting ? toView : transitionContext.view(forKey: .from)!
    let initialFrame = presenting ? originFrame : secondView.frame
    let finalFrame = presenting ? secondView.frame : originFrame
    let xScale = presenting ?
      initialFrame.width / finalFrame.width :
      finalFrame.width / initialFrame.width
    let yScale = presenting ?
      initialFrame.height / finalFrame.height :
      finalFrame.height / initialFrame.height
    let scaleTransform = CGAffineTransform(scaleX: xScale, y: yScale)
    if presenting {
        secondView.transform = scaleTransform
        secondView.center = CGPoint(
        x: initialFrame.midX,
        y: initialFrame.midY)
        secondView.clipsToBounds = true
    }

      secondView.layer.cornerRadius = presenting ? 20.0 : 0.0
      secondView.layer.masksToBounds = true

    containerView.addSubview(toView)
    containerView.bringSubviewToFront(secondView)

    UIView.animate(
      withDuration: duration,
      delay: 0.0,
      animations: {
          secondView.transform = self.presenting ? .identity : scaleTransform
          secondView.alpha = 0.6
          secondView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
    }, completion: { _ in

      if !self.presenting {
        self.dismissCompletion?()
      }
      transitionContext.completeTransition(true)
    })
  }

  private func handleRadius(recipeView: UIView, hasRadius: Bool) {
  }
}
