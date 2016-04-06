enum Direction{
    case None
    case Left
    case Right
}

struct State
{
    var ShipMovement = Direction.None
    var Fire = false
    var Points = 0
}

class GameEvent{
    static let onGameOver = Observable<Void>()
    
    static let onHitAsteroid = Observable<Int>()
}

class GameLogic{
    
    static var currentState = State()
    
    static let modelUpdated = Observable<State>()
    
    static let onPointsUpdated = Observable<Int>()
    
    static func start(gameScene:GameScene){
        
        Signal.onGameStart.subscribe({ scene, _ in
            startGame(scene)
            modelUpdated.subscribe({ drawModel($0, scene: gameScene) }) |> ignore
        }) |> ignore
        
        
        //Signal.accelerometerUpdate.subscribe({ x,_ in print("\(x)")})|>ignore
        Signal.accelerometerUpdate
            .map({x,_ in
                return x < -0.05 ? Direction.Left
                         : x > 0.05 ? Direction.Right : Direction.None})
            .subscribe {
                if currentState.ShipMovement != $0{
                    currentState.ShipMovement = $0
                    modelUpdated.set(currentState)
                }
            } |> ignore
        
        Signal.touchesBegan.subscribe { _ in
            currentState.Fire = true
            modelUpdated.set(currentState)
            currentState.Fire = false
            
        } |> ignore
    
        GameEvent.onHitAsteroid.subscribe({ currentState.Points += $0
                                            onPointsUpdated.set(currentState.Points)}) |> ignore
        
        GameEvent.onGameOver.subscribe({ currentState.Points = 0 }) |> ignore
    }
}