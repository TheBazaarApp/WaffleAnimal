//
//  TestLoadingCircle.swift
//  Authtest
//
//  Created by HMCloaner on 8/26/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class TestLoadingCircle: UIViewController, NVActivityIndicatorViewable {

    override func viewDidLoad() {
        super.viewDidLoad()

        startActivityAnimating(CGSizeMake(200, 200), message: "Feed Loading")
        let triggerTime = (Int64(NSEC_PER_SEC) * 6)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                    print("finishing")
                    self.stopActivityAnimating()
                    //loadingCircle.stopAnimation()
                })
        
//        print("loading view")
//        let loadingCircle = NVActivityIndicatorView(frame: self.view.frame, type: .BallSpinFadeLoader, color: UIColor.purpleColor())
//        print("loading circle frame is \(loadingCircle.frame)")
//        self.view.addSubview(loadingCircle)
//        loadingCircle.startAnimation()
//        let triggerTime = (Int64(NSEC_PER_SEC) * 6)
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
//            print("finishing")
//            loadingCircle.stopAnimation()
//        })
    }


}
