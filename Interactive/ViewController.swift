//
//  ViewController.swift
//  Interactive
//
//  Created by Ho, Derrick on 7/24/16.
//  Copyright © 2016 Ho, Derrick. All rights reserved.
//

import UIKit

class PanAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	var duration: NSTimeInterval
	
	enum State {
		case Presenting
		case Dismissing
	}
	
	var currState: State
	
	init(_ state: State, duration: NSTimeInterval = 1.0) {
		self.currState = state
		self.duration = duration
		super.init()
	}
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return duration
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		switch currState {
		case .Presenting:
			let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
			transitionContext.containerView()!.addSubview(toView)
			
			toView.frame.origin.x = transitionContext.containerView()!.frame.maxX
			
			UIView.animateWithDuration(transitionDuration(transitionContext)
				, animations: { 
					toView.frame.origin.x = 0
				}, completion: { (b: Bool) in
					transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
			})
			
		case .Dismissing:
			let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
			
			UIView.animateWithDuration(transitionDuration(transitionContext)
				, animations: { 
					fromView.frame.origin.x = transitionContext.containerView()!.frame.maxX
				}, completion: { (b: Bool) in
					transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
			})
		}
	}
}

protocol InteractiveDelegate: class {
	var interactive: Bool { get set }
	var interactiveObj: UIPercentDrivenInteractiveTransition! { get set }
}

class PanViewController1: UIViewController, UIViewControllerTransitioningDelegate, InteractiveDelegate {
	
	var interactive: Bool = false
	var interactiveObj: UIPercentDrivenInteractiveTransition!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.userInteractionEnabled = true
		self.view.backgroundColor = .redColor()
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))
		self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.pan(_:))))
	}
	
	func tap(sender: UITapGestureRecognizer) {
		let vc = storyboard!.instantiateViewControllerWithIdentifier(String(PanViewController2)) as! PanViewController2
		vc.transitioningDelegate = self
		interactive = false
		vc.interactiveDelegate = self
		vc.modalPresentationStyle = .Custom
		presentViewController(vc, animated: true, completion: nil)
	}
	
	func pan(sender: UIPanGestureRecognizer) {
		switch sender.state {
		case .Began:
			let vc = storyboard!.instantiateViewControllerWithIdentifier(String(PanViewController2)) as! PanViewController2
			vc.transitioningDelegate = self
			vc.interactiveDelegate = self
			interactive = true
			vc.modalPresentationStyle = .Custom
			presentViewController(vc, animated: true, completion: nil)
		case .Changed:
			let x = sender.translationInView(view).x
			print(x)
			if x >= 0 {
				interactiveObj.updateInteractiveTransition(0.0)
			} else if x < -view.frame.width {
				interactiveObj.updateInteractiveTransition(1)
			} else {
				interactiveObj.updateInteractiveTransition(abs(x) / view.frame.width)
			}
		case .Ended:
			if interactiveObj.percentComplete > 0.5 {
				interactiveObj.finishInteractiveTransition()
			} else {
				interactiveObj.cancelInteractiveTransition()
			}
			interactiveObj = nil
		default:
			interactiveObj.cancelInteractiveTransition()
		}
	}
	
	// MARK: - transition delegate
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return PanAnimator(.Presenting)
	}
	
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return PanAnimator(.Dismissing)
	}
	
	func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		if interactive {
			interactiveObj = UIPercentDrivenInteractiveTransition()
		} else {
			interactiveObj = nil
		}
		return interactiveObj
	}
	
	func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		if interactive {
			interactiveObj = UIPercentDrivenInteractiveTransition()
		} else {
			interactiveObj = nil
		}
		return interactiveObj
	}
	
}

class PanViewController2: UIViewController {
	
	weak var interactiveDelegate: InteractiveDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.userInteractionEnabled = true
		self.view.backgroundColor = .blueColor()
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))
		self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.pan(_:))))
	}
	
	func tap(sender: UITapGestureRecognizer) {
		interactiveDelegate?.interactive = false
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func pan(sender: UIPanGestureRecognizer) {
		switch sender.state {
		case .Began:
			interactiveDelegate?.interactive = true
			self.dismissViewControllerAnimated(true, completion: nil)
		case .Changed:
			let x = sender.translationInView(view).x
			print(x)
			if x <= 0 {
				interactiveDelegate!.interactiveObj.updateInteractiveTransition(0.0)
			} else if x > view.frame.width {
				interactiveDelegate!.interactiveObj.updateInteractiveTransition(1)
			} else {
				interactiveDelegate!.interactiveObj.updateInteractiveTransition(abs(x) / view.frame.width)
			}
		case .Ended:
			if interactiveDelegate!.interactiveObj.percentComplete > 0.5 {
				interactiveDelegate!.interactiveObj.finishInteractiveTransition()
			} else {
				interactiveDelegate!.interactiveObj.cancelInteractiveTransition()
			}
			interactiveDelegate!.interactiveObj = nil
		default:
			interactiveDelegate!.interactiveObj.cancelInteractiveTransition()
		}
	}
}