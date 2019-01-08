//
//  GG.swift
//  IosFinal
//
//  Created by Lu Andy on 2019/1/3.
//  Copyright © 2019 Lu Andy. All rights reserved.
//



import Foundation
import SpriteKit

var size2:CGSize?

class GG: SKScene {
  
    init(size: CGSize, won:Bool) {
        super.init(size: size)
        
        let button = won ? SKSpriteNode(imageNamed: "player") : SKSpriteNode(imageNamed: "monster")
        
        size2 = size
        backgroundColor = SKColor.white
        
    
        button.position = CGPoint(x: 200, y: 180)
        button.name = "GG"
        addChild(button)
        
        let message = won ? "You Won! OuO" : "You Lose QQ"
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        if !won
        {
           let Music = SKAudioNode(fileNamed: "sad.mp3")
            Music.autoplayLooped = true
            addChild(Music)
        }
        else
        {
           let Music = SKAudioNode(fileNamed: "happy.mp3")
            Music.autoplayLooped = true
            addChild(Music)
        }
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "GG"
            {
                run()
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func run()
    {
        run(SKAction.sequence([
            SKAction.run() { [weak self] in
                // 5
                guard let `self` = self else { return }
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size2!)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
    }
}



