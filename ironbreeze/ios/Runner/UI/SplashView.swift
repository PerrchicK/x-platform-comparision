//
//  SplashView.swift
//  Runner
//
//  Created by Perry Shalom on 07/05/2019.
//  Copyright © 2019 perrchick. All rights reserved.
//

import Foundation

class SplashView: UIView {
    static let MINIMUM_SPLASH_DURATION: TimeInterval = 2
    static let MAXIMUM_SPLASH_DURATION: TimeInterval = 6

    @IBOutlet weak var lblIntro: UILabel!

    var start: TimeInterval = 0

    var minimumDuration: TimeInterval {
        return SplashView.MINIMUM_SPLASH_DURATION
    }

    var maximumDuration: TimeInterval {
        return SplashView.MAXIMUM_SPLASH_DURATION
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        lblIntro.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    }

    var isAdded: Bool {
        return superview != nil
    }

    var isVisible: Bool {
        return alpha == 1 && isAdded && isPresented
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview == nil {
            onRemoved()
        } else {
            onAdded()
        }
    }

    func begin() {
        guard start == 0 else { return }

        start = Date().timeIntervalSince1970
        let timeout: Double = maximumDuration
        PerrFuncs.runBlockAfterDelay(afterDelay: timeout, block: {[weak self] in
            self?.beGone()
        })

        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: { [weak self] () -> () in
            self?.lblIntro.transform = CGAffineTransform(scaleX: 5, y: 5)
        }) { (succeeded) -> Void in
            UIView.animate(withDuration: 0.4, delay: 0.3, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: UIView.AnimationOptions.curveEaseOut   , animations: { [weak self] () -> Void in
                self?.lblIntro.transform = CGAffineTransform(scaleX: 3, y: 3)
            }) { (succeeded) -> Void in
            }
        }
    }

    func beGone() {
        guard isVisible else { return }
        guard isPresented else { return }
        let elapsed = Date.init().timeIntervalSince1970 - start
        
        if minimumDuration > elapsed {
            PerrFuncs.runBlockAfterDelay(afterDelay: minimumDuration - elapsed + 0.1) { [weak self] in
                self?.beGone()
            }
        } else {
            animateFade(fadeIn: false, completion: { [weak self] _ in
                self?.isPresented = false
                self?.removeFromSuperview()
            })
        }
    }

    func onAdded() {
        let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        loadingView.startAnimating()
        addSubview(loadingView)
        
        loadingView.center = CGPoint(x: PerrFuncs.screenSize.width / 2, y: PerrFuncs.screenSize.height - 50)
        loadingView.alpha = 0
        
        PerrFuncs.runBlockAfterDelay(afterDelay: (maximumDuration - minimumDuration) / 2) {
            guard self.isVisible else { return }
            loadingView.animateFade(fadeIn: true)
        }
        
        lblIntro.animateZoom(zoomIn: true, duration: 0.5, delay: 0.5, completion: nil)
    }
    
    func onRemoved() {
        // Gone...
        removeAllSubviews()
    }
}

