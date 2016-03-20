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


func startGame(scene:SKScene){
    drawBackground(scene)
    drawSpaceship(scene)
    
    let setAsteroid = { x, type, scale in
        drawAsteroid(scene, position: CGPointMake(x, scene.size.height), type: type, scale: scale)
    }
    
    setAsteroid(scene.size.width/2, .A, 0.75)
    setAsteroid(scene.size.width/4, .B, 0.25)
    setAsteroid(scene.size.width - 50, .C, 0.5)
    setAsteroid(20, .D, 0.4)
    
    
    
    setAsteroid(scene.size.width/2, .B, 0.55)
    setAsteroid(scene.size.width/4, .C, 0.15)
    setAsteroid(scene.size.width - 50, .D, 0.15)
    setAsteroid(20, .A, 0.1)
    
    
    
    setAsteroid(scene.size.width/2, .C, 0.1)
    setAsteroid(scene.size.width/4, .D, 0.25)
    setAsteroid(scene.size.width - 50, .A, 0.7)
    setAsteroid(20, .B, 0.5)
    
    
    
    setAsteroid(scene.size.width/2, .D, 0.30)
    setAsteroid(scene.size.width/4, .A, 0.80)
    setAsteroid(scene.size.width - 50, .B, 0.25)
    setAsteroid(20, .C, 0.7)
    
    
    let objects :[Asteroid] = [Asteroid.A,Asteroid.B,Asteroid.C,Asteroid.D]
    
    
    Signal.update.subscribe { _ in
        if arc4random_uniform(5000) > 4950{
            let pos = CGFloat(arc4random_uniform(UInt32(scene.size.width)))
            
            let objPos = Int32(arc4random_uniform(UInt32(objects.count)));
            let obj = objects[3];
            let scale = (Double(arc4random_uniform(95))+5.0)/100.0
            
            setAsteroid(pos, obj, CGFloat(scale))
        }
         } |> ignore
    
}

func drawBackground(scene:SKScene){
    let background = SKSpriteNode(imageNamed: "background")
    background.size = scene.size
    background.position = CGPointMake(scene.size.width/2, scene.size.height/2)
    background.zPosition = -1
    scene.addChild(background)
}

func drawAsteroid(scene:SKScene,  position:CGPoint, type:Asteroid, scale:CGFloat){
    let asteroid = SKSpriteNode(imageNamed: type.rawValue)
    asteroid.position = position
    asteroid.xScale = scale
    asteroid.yScale = scale
    
    let angel = CGFloat(arc4random_uniform(12) + 1) - 6
    let duration = Double(arc4random_uniform(20) + 1)
    let speed = Double(arc4random_uniform(30) + 1)
    
    
    asteroid.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(angel, duration:duration)))
    
    let moveAction = SKAction.moveToY (-asteroid.size.height*2, duration: speed)
    asteroid.runAction(moveAction, completion: { asteroid.removeFromParent()  })
    scene.addChild(asteroid)
}



func drawSpaceship(scene:SKScene){

    let spaceship = SKSpriteNode(imageNamed:"Spaceship")
    spaceship.name = "spaceship"
    spaceship.xScale = 0.25
    spaceship.yScale = 0.25
    spaceship.position = CGPointMake(scene.size.width/2, spaceship.size.height)
    spaceship.zPosition = 1
    scene.addChild(spaceship)
}

func moveSpaceship (model : State, scene:SKScene, spaceship: SKSpriteNode){
    spaceship.removeActionForKey("moveSpaceship")
    
    if model.ShipMovement != .None {
        let pos = model.ShipMovement == Direction.Left
            ? spaceship.size.width/2
            : scene.size.width - spaceship.size.width/2
        let action = SKAction.moveToX (pos, duration: 1.5)
        
        spaceship.runAction (action, withKey: "moveSpaceship")
    }
}


func fire(scene:SKScene, position:CGPoint){
    let laser = SKShapeNode(rectOfSize: CGSize(width: 3, height: 15))
    
    laser.fillColor = SKColor.yellowColor()
    laser.position = position
    let moveAction = SKAction.moveToY (scene.size.height + 15, duration: 1.5)
    laser.runAction(moveAction, completion: { laser.removeFromParent()  })
    scene.addChild(laser)
}

func drawModel (model:State, scene:SKScene) {
    let spaceship = scene.childNodeWithName("spaceship") as! SKSpriteNode
    moveSpaceship(model, scene: scene, spaceship: spaceship)
    if model.Fire {
        fire(scene, position: spaceship.position)
    }
}
