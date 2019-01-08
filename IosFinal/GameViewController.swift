//
//  GameViewController.swift
//  IosFinal
//
//  Created by Lu Andy on 2019/1/3.
//  Copyright © 2019 Lu Andy. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        scene.scaleMode = .aspectFill
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
