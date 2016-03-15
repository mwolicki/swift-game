//
// Created by Marcin Wolicki on 15/03/2016.
// Copyright (c) 2016 Marcin Wolicki. All rights reserved.
//

import Foundation


class Observable<T> {
    typealias A = T
    private var subscribers:[(T->())] = []
    func subscribe(fun:(T->())) -> Observable<T>  {
        subscribers.append(fun)
        self
    }

    func OnNext(el:T){
        for s in subscribers {
            s(el)
        }
    }


}

extension Observable<T> {
    func map<R>(mapper:(T->R)) -> Observable<R>{
        let o=Observable<R>()
        self.subscribe({x -> o.OnNext(mapper (x))})
        o
    }

    func filter(predictor:(T->bool)) -> Observable<T>{
        let o=Observable<T>()
        self.subscribe({x in if predictor(x) { o.OnNext(x)}})
        o
    }

    
}
