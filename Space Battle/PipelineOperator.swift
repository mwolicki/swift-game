infix operator |>   { precedence 50 associativity left }

// Pipe forward: transform "x |> f" to "f(x)" and "x |> f |> g |> h" to "h(g(f(x)))"
public func |> <T,U>(lhs: T, rhs: T -> U) -> U {
    return rhs(lhs)
}



public func ignore<T>(_:T){
    
}