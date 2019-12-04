//
//  ViewController.swift
//  tagAR
//
//  Created by moa on 2019-11-27.
//  Copyright © 2019 moa. All rights reserved.
//

import UIKit
import ARKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var ARscene: ARSCNView!
    @IBOutlet weak var circleBtn: UIImageView!
    @IBOutlet weak var screenShotBtn: UIImageView!

    var cameraAudio:AVAudioPlayer?
    var sprayAudio:AVAudioPlayer?
    
    func playCameraAudio() {
        let path = Bundle.main.path(forResource: "./assets/cameraAudio.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            cameraAudio = try AVAudioPlayer(contentsOf: url)
            cameraAudio?.play()
        }
        catch {
            print("error with sound")
        }
    }
    
    @objc func screenShot(_ sender: UIGestureRecognizer){
        // capture image and save to camera roll
        playCameraAudio()

        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
        // add flicking image as feedback
        let clickImage = UIImage(named: "./assets/blackBackground.png")
        let imageView = UIImageView(image: clickImage)
        imageView.contentMode = .scaleToFill
        view.addSubview(imageView)
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { timer in
            imageView.image = nil
        })
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
    
    func addSprayAudio() {
        let path = Bundle.main.path(forResource: "../assets/spray-paint.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            sprayAudio = try AVAudioPlayer(contentsOf: url)
            sprayAudio?.numberOfLoops = -1
        }
        catch {
            print("error with sound")
        }
    }
       
   @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = self.ARscene.center
        let hitTestResultsWithFeaturePoints = ARscene.hitTest(tapLocation, types: .featurePoint)
        addSprayAudio()

        if recognizer.state != .ended {
            circleBtn.isHighlighted = true
            if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
                let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                addBox(x: translation.x, y: translation.y, z: translation.z)
                sprayAudio?.play()
            }
        } else {
            sprayAudio?.stop()
            circleBtn.isHighlighted = false
        }
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()

        
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(screenShot))
        oneTap.numberOfTapsRequired = 1
        screenShotBtn.addGestureRecognizer(oneTap)
    }
}

extension float4x4 {
    var translation: SIMD3<Float> {
        let translation = self.columns.3
        return SIMD3<Float>(translation.x, translation.y, translation.z)
    }
}

