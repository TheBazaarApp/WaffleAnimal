//
//  FullScreenViewController.swift
//  Authtest
//
//  Created by CSSummer16 on 7/18/16.
//  Copyright © 2016 CSSummer16. All rights reserved.
//

import UIKit

class FullScreenViewController: UIViewController {

    @IBOutlet weak var messagePic: UIImageView!
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagePic.image = image
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
