enum Direction{
    case None
    case Left(speed:UInt8)
    case Right(speed:UInt8)
}

enum GameState {
    case GameOver
    case Running(state:State)
}

struct State
{
    var ShipMovement = Direction.None
    var Points = 0
}

class GameEvent{
    static let onGameOver = Observable<Void>()
    
    static let onHitAsteroid = Observable<Int>()
}

class GameLogic{
    
    static var currentState = GameState.Running(state: State())
    
    static let onFire = Observable<Void>()
    static let onRestartGame = Observable<Void>()
    static let onPointsUpdated = Observable<Int>()
    
    static func start(gameScene:GameScene){
        
        Signal.onGameStart.subscribe({ scene, _ in
            startGame(scene)
            modelUpdated.subscribe({ drawModel($0, scene: gameScene) }) |> ignore
        }) |> ignore
        
        
        //Signal.accelerometerUpdate.subscribe({ x,_ in print("\(x)")})|>ignore
        Signal.accelerometerUpdate
            .map({x,_ in
                return x < -0.01 ? Direction.Left (speed: 1)
                    : x > 0.01 ? Direction.Right (speed: 10) : Direction.None})
            .subscribe {
                if currentState.ShipMovement != $0{
                    currentState.ShipMovement = $0
                    modelUpdated.set(currentState)
                }
            } |> ignore
        
        Signal.touchesBegan.subscribe { _ in
            switch currentState{
            case .Running(state: _) : onFire.set(())
            case .GameOver: onRestartGame.set(())
            }
            
        } |> ignore
    
        GameEvent.onHitAsteroid.subscribe({ currentState.Points += $0
                                            onPointsUpdated.set(currentState.Points)}) |> ignore
        
        GameEvent.onGameOver.subscribe{
            currentState = GameState.GameOver } |> ignore
    }
}