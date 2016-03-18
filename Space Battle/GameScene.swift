//
//  GameScene.swift
//  Space Battle
//
//  Created by Marcin Wolicki on 15/03/2016.
//  Copyright (c) 2016 Marcin Wolicki. All rights reserved.
//

import SpriteKit

 class Signal {
    static let touchesBegan = Observable<Set<UITouch>>();
}

class GameScene: SKScene {

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        Signal.touchesBegan.OnNext(touches);

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
