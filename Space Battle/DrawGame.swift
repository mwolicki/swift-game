//
//  GamieLogic.swift
//  Space Battle
//
//  Created by Marcin Wolicki on 18/03/2016.
//  Copyright © 2016 Marcin Wolicki. All rights reserved.
//


import UIKit
import SpriteKit

enum Asteroid : String{
    case A = "asteroid0"
    case B = "asteroid1"
    case C = "asteroid2"
    case D = "asteroid3"
}


enum GameObject : UInt32{
    case Laser = 0x01
    case Asteroid = 0x02
    case Spaceship = 0x4
}


func startGame(scene:SKScene){
    drawGameOnStart(scene)
    
    Signal.frame(5).subscribe(newAsteroid) |> ignore
    Signal.didBeginContact.subscribe(onContact) |> ignore
    GameLogic.onPointsUpdated.subscribe({ points in drawPoints(points, scene: scene) }) |> ignore
}

func drawGameOnStart(scene:SKScene){
    drawBackground(scene)
    drawSpaceship(scene)
    drawPoints(0, scene: scene)
}

func newAsteroid(scene:SKScene){
    
    let setAsteroid = { x, type, scale in
        drawAsteroid(scene, position: CGPointMake(x, scene.size.height), type: type, scale: scale)
    }
    
    if arc4random_uniform(50) > 48{
        let pos = CGFloat(arc4random_uniform(UInt32(scene.size.width)))
        
        let objPos = Int32(arc4random_uniform(4))
        if let obj = Asteroid(rawValue: "asteroid\(objPos)"){
            let scale = (Double(arc4random_uniform(95))+5.0)/100.0
            setAsteroid(pos, obj, CGFloat(scale))
        }
    }
}

func onContact (scene:SKScene, contact:SKPhysicsContact){
    
    if(contact.bodyA.categoryBitMask != contact.bodyB.categoryBitMask){
        if let bodyA = GameObject(rawValue: contact.bodyA.categoryBitMask) {
            if bodyA == .Spaceship {
                gameOver(scene)
            }
        }
        
        if let node = contact.bodyA.node{
            node.removeFromParent()
            GameEvent.onHitAsteroid.set(10)
        }
        if let node = contact.bodyB.node{
            node.removeFromParent()
            
            GameEvent.onHitAsteroid.set(10)
        }
    }
}

func gameOver(scene:SKScene){
    let gameover = SKLabelNode(fontNamed: "Chalkduster")
    gameover.text = "Game Over"
    gameover.fontSize = 50
    gameover.fontColor = SKColor.blueColor()
    gameover.position = CGPointMake(scene.size.width/2, scene.size.height/2)
    gameover.zPosition = 1
    scene.addChild(gameover)
    
    GameEvent.onGameOver.set(())
}

func drawBackground(scene:SKScene){
    let background = SKSpriteNode(imageNamed: "background")
    background.size = scene.size
    background.position = CGPointMake(scene.size.width/2, scene.size.height/2)
    background.zPosition = -1
    scene.addChild(background)
}

func drawPoints(currentPoints: Int, scene:SKScene){
    if let points : SKLabelNode = scene.childNodeWithName("points") as! SKLabelNode?{
        points.removeFromParent()
    }
    
    let points = SKLabelNode(fontNamed: "Chalkduster")
    points.name = "points"
    points.text = "score: \(currentPoints)"
    points.fontSize = 25
    points.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
    points.fontColor = SKColor.yellowColor()
    points.position = CGPointMake(scene.size.width-10, scene.size.height-20)
    points.zPosition = 1
    scene.addChild(points)
}

func drawAsteroid(scene:SKScene,  position:CGPoint, type:Asteroid, scale:CGFloat){
    let asteroid = SKSpriteNode(imageNamed: type.rawValue)
    asteroid.position = position
    asteroid.xScale = scale
    asteroid.yScale = scale
    
    let physicsBody =
        PhysicsBody.basedOnTexture(asteroid.texture!, size: asteroid.size)
        |> PhysicsBody.setCategoryBitMask (GameObject.Asteroid.rawValue | GameObject.Spaceship.rawValue)
        |> PhysicsBody.setContactTestBitMask (GameObject.Laser.rawValue)
    asteroid.physicsBody = physicsBody
    
    
    let angel = CGFloat(arc4random_uniform(12) + 1) - 6
    let duration = Double(arc4random_uniform(20) + 1)
    let speed = Double(arc4random_uniform(25) + 5)
    
    
    asteroid.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(angel, duration:duration)))
    
    let moveAction = SKAction.moveToY (-asteroid.size.height*4, duration: speed)
    asteroid.runAction(moveAction, completion: { asteroid.removeFromParent()  })
    scene.addChild(asteroid)
}

class PhysicsBody {
    static func basedOnTexture (texture:SKTexture, size:CGSize) -> SKPhysicsBody{
        return SKPhysicsBody(texture: texture, size: size) |> setupDefaults
    }
    
    private static func setCategoryBitMask (categoryBitMask : UInt32) (pb:SKPhysicsBody) -> SKPhysicsBody{
        pb.categoryBitMask = categoryBitMask
        return pb
    }
    
    
    private static func setContactTestBitMask (contactTestBitMask : UInt32) (pb:SKPhysicsBody) -> SKPhysicsBody{
        pb.contactTestBitMask = contactTestBitMask
        return pb
    }
    
    private static func setupDefaults (pb:SKPhysicsBody) -> SKPhysicsBody{
        pb.dynamic = true
        pb.affectedByGravity = false
        pb.collisionBitMask = 0
        return pb
    }
    
}

func drawSpaceship(scene:SKScene){

    let spaceship = SKSpriteNode(imageNamed:"Spaceship")
    spaceship.name = "spaceship"
    spaceship.xScale = 0.25
    spaceship.yScale = 0.25
    spaceship.position = CGPointMake(scene.size.width/2, spaceship.size.height)
    spaceship.zPosition = 1
    
    let physicsBody = SKPhysicsBody(texture: spaceship.texture!, size: spaceship.size)
    physicsBody.dynamic = true
    physicsBody.affectedByGravity = false
    physicsBody.collisionBitMask = 0
    physicsBody.categoryBitMask = GameObject.Spaceship.rawValue
    physicsBody.contactTestBitMask = GameObject.Asteroid.rawValue
    spaceship.physicsBody = physicsBody

    
    scene.addChild(spaceship)
}

func moveSpaceship (model : State, scene:SKScene, spaceship: SKSpriteNode){
    spaceship.removeActionForKey("moveSpaceship")
    
    if model.ShipMovement != .None {
        let pos = model.ShipMovement == Direction.Left
            ? spaceship.size.width/2
            : scene.size.width - spaceship.size.width/2
        
        let speed = Double(2.5 * abs(pos - spaceship.position.x)/scene.size.width)
        let action = SKAction.moveToX (pos, duration: speed)
        
        spaceship.runAction (action, withKey: "moveSpaceship")
    }
}


func fire(scene:SKScene, position:CGPoint){
    let laser = SKShapeNode(rectOfSize: CGSize(width: 3, height: 15))
    
    laser.fillColor = SKColor.yellowColor()
    laser.position = position
    let moveAction = SKAction.moveToY (scene.size.height + 15, duration: 1.5)
    laser.runAction(moveAction, completion: { laser.removeFromParent() })
    
    let physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 3, height: 15))
    physicsBody.dynamic = true
    physicsBody.affectedByGravity = false
    physicsBody.collisionBitMask =  0
    physicsBody.categoryBitMask = GameObject.Laser.rawValue
    physicsBody.contactTestBitMask = GameObject.Asteroid.rawValue
    laser.physicsBody = physicsBody
    
    scene.addChild(laser)
}

func drawModel (model:State, scene:SKScene) {
    if let spaceship : SKSpriteNode = scene.childNodeWithName("spaceship") as! SKSpriteNode?{
        moveSpaceship(model, scene: scene, spaceship: spaceship)
        if model.Fire {
            fire(scene, position: spaceship.position)
        }
    }
    else{
        scene.removeAllChildren()
        drawGameOnStart(scene)
    }
}

