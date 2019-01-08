//
//  GameScene.swift
//  IosFinal
//
//  Created by Lu Andy on 2019/1/3.
//  Copyright © 2019 Lu Andy. All rights reserved.
//

import SpriteKit
import GameplayKit


func +(left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

extension CGPoint
{
    func length() -> CGFloat
    {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint
    {
        return self / length()
    }
}

class GameScene: SKScene
{
    
    struct PhysicsCategory
    {
        static let none      : UInt32 = 0
        static let monster   : UInt32 = 1
        static let bullet: UInt32 = 2
    }
    
    
   
    let player = SKSpriteNode(imageNamed: "player")
    var scoreLabel: SKLabelNode!
    var background = SKSpriteNode(imageNamed: "background")
    var monstergogo = false
    var life = 3
    {
        didSet
        {
            scoreLabel.text = "life:\(life)  Score:\(monstersDestroyed)"
        }
    }
    
    var monstersDestroyed  = 0 {
        didSet {
            scoreLabel.text = "life:\(life)  Score:\(monstersDestroyed)"
            if monstersDestroyed == 25
            {
                background.removeFromParent()
            }
            
            if monstersDestroyed % 10 == 0
            {
                monstergogo = true
                run(SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.run(addMonster),
                        SKAction.wait(forDuration: 1.5),
                        
                        ])
                ))
            }
            
        }
    }
    override func didMove(to view: SKView)
    {
        background = SKSpriteNode(imageNamed: "background")
        background.zPosition = 0
        background.size = frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
       
        addChild(background)

        // 3
        player.position = CGPoint(x: size.width * 0.08, y: size.height * 0.5)
        player.size = CGSize(width: 60, height: 60)
        player.zPosition = 1
        // 4
        addChild(player)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 1.0),
        
                ])
        ))
        
        let backgroundMusic = SKAudioNode(fileNamed: "background.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontColor = SKColor.white
        scoreLabel.text = "Life:3  Score:0"
        scoreLabel.zPosition = 1
        scoreLabel.position = CGPoint(x: 140, y: 0)
        addChild(scoreLabel)
        
    }
    
    func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat
    {
        return random() * (max - min) + min
    }
    
    func addMonster()
    {
        // Create sprite
        let monster = monstergogo ? SKSpriteNode(imageNamed: "monster2") :SKSpriteNode(imageNamed: "monster")
        monster.zPosition = 1
        monster.size = CGSize(width: 50, height: 50)
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = false // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.bullet // 4

        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        var actualDuration = CGFloat(10.0)
        // Determine speed of the monster
        if(monstersDestroyed<5)
        {
             actualDuration = random(min: CGFloat(3.0), max: CGFloat(4.0))
        }
        else
        {
              actualDuration = random(min: CGFloat(1.5), max: CGFloat(3.0))
        }
        
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.run()
            { [weak self] in
            guard let `self` = self else { return }
                if self.life == 0
                {
                    let reveal = SKTransition.flipHorizontal(withDuration: 0.2)
                    let gameOverScene = GG(size: self.size, won: false)
                    self.view?.presentScene(gameOverScene, transition: reveal)
                }
                else
                {
                    self.life -= 1
                }
            }
        
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        
        
        let touchLocation = touch.location(in: self)
        
        // 2 - Set up initial location of bullet
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.size = CGSize(width: 30, height: 30)
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width)
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.none
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to bullet
        let offset = touchLocation - bullet.position
        
        // 4 - Bail out if you are shooting down or backwards
        if offset.x < 0 { return }
        run(SKAction.playSoundFileNamed("gun.mp3", waitForCompletion: false))
        // 5 - OK to add now - you've double checked position
        addChild(bullet)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + bullet.position
        
        // 9 - Create the actions
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func bulletDidCollideWithMonster(bullet: SKSpriteNode, monster: SKSpriteNode)
    {
        print("Hit")
        bullet.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed += 1
        if monstersDestroyed == 50
        {
            let reveal = SKTransition.flipHorizontal(withDuration:0.2)
            let gameOverScene = GG(size: self.size, won: true)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.bullet != 0)) {
            if let monster = firstBody.node as? SKSpriteNode,
                let bullet = secondBody.node as? SKSpriteNode {
                bulletDidCollideWithMonster(bullet: bullet, monster: monster)
            }
        }
    }
}
