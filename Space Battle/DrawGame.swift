//
//  GamieLogic.swift
//  Space Battle
//
//  Created by Marcin Wolicki on 18/03/2016.
//  Copyright © 2016 Marcin Wolicki. All rights reserved.
//


import UIKit
import SpriteKit


func startGame(scene:SKScene){
    drawBackground(scene)
    drawSpaceship(scene)
    
    
}

func drawBackground(scene:SKScene){
    let background = SKSpriteNode(imageNamed: "background")
    background.size = scene.size
    background.position = CGPointMake(scene.size.width/2, scene.size.height/2)
    background.zPosition = -1
    scene.addChild(background)
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

func fire(scene:SKScene, posit:CGPoint){
    let laser = SKShapeNode(rectOfSize: CGSize(width: 3, height: 15))
    
    laser.fillColor = SKColor.yellowColor()
    laser.position = posit
    let moveAction = SKAction.moveToY (scene.size.height + 15, duration: 1.5)
    laser.runAction(moveAction, completion: { laser.removeFromParent()  })
    scene.addChild(laser)
}

func drawModel (model:State, scene:SKScene) {
    let spaceship = scene.childNodeWithName("spaceship") as! SKSpriteNode
    moveSpaceship(model, scene: scene, spaceship: spaceship)
    if model.Fire {
        fire(scene, posit: spaceship.position)
    }
}

