enum Direction{
    case None
    case Left
    case Right
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
    static let onDirectionChanged = Observable<Direction>()
    
    static func start(gameScene:GameScene){
        
        Signal.onGameStart.subscribe({ scene, _ in
            startGame(scene)
        }) |> ignore
        
        
        //Signal.accelerometerUpdate.subscribe({ x,_ in print("\(x)")})|>ignore
        Signal.accelerometerUpdate
            .map({x,_ in
                return x < -0.02 ? Direction.Left
                    : x > 0.02 ? Direction.Right : Direction.None})
            .subscribe {
                switch currentState {
                case .Running(var state):
                    if state.ShipMovement != $0{
                        state.ShipMovement = $0
                        currentState = .Running(state: state)
                        onDirectionChanged.set($0)
                    }
                default: ()
                }
                
            } |> ignore
        
        Signal.touchesBegan.subscribe { _ in
            switch currentState{
            case .Running(_) : onFire.set(())
            case .GameOver: onRestartGame.set(())
            }
            
        } |> ignore
    
        GameEvent.onHitAsteroid.subscribe({
            switch currentState{
            case .Running(var state) :
                state.Points += $0
                currentState = .Running(state: state)
                onPointsUpdated.set(state.Points)
            default: ()
            }}) |> ignore
        
        GameEvent.onGameOver.subscribe{
            currentState = GameState.GameOver } |> ignore
        
        
        GameLogic.onRestartGame.subscribe{
            currentState = GameState.Running(state: State()) } |> ignore
    }
}