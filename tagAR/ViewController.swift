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
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        // fix perspective
        let box = SCNPlane(width: 0.1, height: 0.1)
        box.cornerRadius = 0.3
        box.firstMaterial?.diffuse.contents = UIImage(named: "../assets/spraytag_01.png")
        box.firstMaterial?.transparency = 0.25;
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)
        
        ARscene.scene.rootNode.addChildNode(boxNode)
    }
    
    func addTapGestureToSceneView() {
           let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
           circleBtn.addGestureRecognizer(tapGestureRecognizer)
       }
       
       @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
           let tapLocation = recognizer.location(in: circleBtn)
            let hitTestResultsWithFeaturePoints = ARscene.hitTest(tapLocation, types: .featurePoint)
                       
            if recognizer.state != .ended {
                circleBtn.isHighlighted = true
                if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
                    let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                    addBox(x: translation.x, y: translation.y, z: translation.z)
                }
            } else {
                circleBtn.isHighlighted = false
            }
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()

        
//        let oneTap = UITapGestureRecognizer(target: self, action: #selector(screenShot))
//        oneTap.numberOfTapsRequired = 1
//        screenShotBtn.addGestureRecognizer(oneTap)

//        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
//        circleBtn.addGestureRecognizer(longGesture)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

