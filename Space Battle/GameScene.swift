//
//  GameScene.swift
//  Space Battle
//
//  Created by Marcin Wolicki on 15/03/2016.
//  Copyright (c) 2016 Marcin Wolicki. All rights reserved.
//

import SpriteKit
import CoreMotion
import Foundation

 class Signal {
    static let touchesBegan = Observable<Set<UITouch>>();
    static let onGameStart = Observable<(SKScene,SKView)>();
    static let accelerometerUpdate = Observable<(Double,Double)>();
}

class GameScene: SKScene {

    let motionManager = CMMotionManager()

    
    override func didMoveToView(view: SKView) {
        Signal.onGameStart.set((self,view))
        
        if self.motionManager.accelerometerAvailable == true {
            self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler:{
                data, error in
                if let x = data?.acceleration.x{
                    if let y =  data?.acceleration.y{
                        Signal.accelerometerUpdate.set((x, y));
                    }
                }
            })
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        Signal.touchesBegan.set(touches);

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
