//
//  ViewController.swift
//  tagAR
//
//  Created by moa on 2019-11-27.
//  Copyright © 2019 moa. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    @IBOutlet weak var ARscene: ARSCNView!
    @IBOutlet weak var circleBtn: UIImageView!
    @IBOutlet weak var screenShotBtn: UIImageView!
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        if sender.state == .ended {
            circleBtn.isHighlighted = false
            print("stopped pressing")
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .began {
            circleBtn.isHighlighted = true
            print("pressing")
            // start tagging
        }
    }
    
    @objc func screenShot(_ sender: UIGestureRecognizer){
        print("screen shots fired")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        ARscene.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ARscene.session.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(screenShot))
        oneTap.numberOfTapsRequired = 1
        screenShotBtn.addGestureRecognizer(oneTap)

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        circleBtn.addGestureRecognizer(longGesture)
    }
}

