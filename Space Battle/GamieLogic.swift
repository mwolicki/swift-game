//
//  GamieLogic.swift
//  Space Battle
//
//  Created by Marcin Wolicki on 18/03/2016.
//  Copyright © 2016 Marcin Wolicki. All rights reserved.
//


import UIKit
import SpriteKit


class GameLogic{
    
    static let shipRotateFinished = Observable<SKSpriteNode>()
    
    static func start(gameScene:GameScene){
        Signal.touchesBegan
            .filter({touches in touches.count == 1})
            .map({$0.first!})
            .subscribe { (touch) -> () in
                let location = touch.locationInNode(gameScene)
                
                let sprite = SKSpriteNode(imageNamed:"Spaceship")
                
                sprite.xScale = 0.5
                sprite.yScale = 0.5
                sprite.position = location
                
                let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
                
                sprite.runAction(SKAction.repeatAction(action, count: 3), completion: { shipRotateFinished.OnNext(sprite) })
                
                gameScene.addChild(sprite)
                
            } |> ignore
        
        shipRotateFinished.subscribe({ $0.removeFromParent() |> ignore }) |> ignore
    }
}