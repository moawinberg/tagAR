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
import AudioToolbox

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var ARscene: ARSCNView!
    @IBOutlet weak var circleBtn: UIImageView!
    @IBOutlet weak var screenShotBtn: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    var cameraAudio:AVAudioPlayer?
    var sprayAudio:AVAudioPlayer?
    var sprayCanAudio:AVAudioPlayer?
    
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
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        addSprayCanAudio()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
       sprayCanAudio?.stop()
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
    
    func addSprayCanAudio() {
        let path = Bundle.main.path(forResource: "./assets/spraycanShake.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            sprayCanAudio = try AVAudioPlayer(contentsOf: url)
            sprayCanAudio?.numberOfLoops = -1
            sprayCanAudio?.play()
        }
        catch {
            print("error with sound")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        DispatchQueue.main.async {
            guard let featurePointHitTest = self.ARscene.hitTest(self.ARscene.center, types: .featurePoint).first else { return }

            let worldCoordinates = featurePointHitTest.worldTransform

            let position = SIMD3<Float>(worldCoordinates.columns.3.x, worldCoordinates.columns.3.y, worldCoordinates.columns.3.z)
            
            let newNode = SCNNode()
            newNode.simdPosition = position
            
            if self.button.isHighlighted {
                let spray = SCNPlane(width: 0.05, height: 0.05)
                spray.firstMaterial?.diffuse.contents = UIImage(named: "../assets/spraytag_01.png")
                spray.firstMaterial?.transparency = 0.5;
                newNode.geometry = spray
                self.ARscene.scene.rootNode.addChildNode(newNode)

                // AudioServicesPlayAlertSound(1519)
                self.sprayAudio?.play()
            } else {
                self.sprayAudio?.stop()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ARscene.delegate = self
        addSprayAudio()
        
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(screenShot))
        screenShotBtn.addGestureRecognizer(oneTap)
    }
}



