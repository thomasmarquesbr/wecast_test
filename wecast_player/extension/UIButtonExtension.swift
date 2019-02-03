//
//  UIButtonExtension.swift
//  wecast_player
//
//  Created by Thomás Marques Brandão Reis on 03/02/19.
//  Copyright © 2019 Thomás Marques Brandão Reis. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {
            self.isEnabled = false
            self.alpha = 0.5
            //            let indicator = UIActivityIndicatorView()
            self.setImage(nil, for: .normal)
            let color = UIColor(red: CGFloat(65/255.0), green: CGFloat(69/255.0), blue: CGFloat(70/255.0), alpha: 1)
            let indicator = NVActivityIndicatorView(frame: self.frame, type: NVActivityIndicatorType.circleStrokeSpin, color: color, padding: 3.0)
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            self.isEnabled = true
            self.alpha = 1.0
            //            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
            if let indicator = self.viewWithTag(tag) as? NVActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}
