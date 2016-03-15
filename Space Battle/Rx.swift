//
// Created by Marcin Wolicki on 15/03/2016.
// Copyright (c) 2016 Marcin Wolicki. All rights reserved.
//

import Foundation


class Observable<T> {
    typealias A = T
    private var subscribers: [(T -> ())] = []
    func subscribe(fun: (T -> ())) -> Observable<T> {
        subscribers.append(fun)
        return self
    }

    func OnNext(el: T) {
        for s in subscribers {
            s(el)
        }
    }
}

extension Observable {
    func map<R>(mapper: (T -> R)) -> Observable<R> {
        let o = Observable<R>()
        self.subscribe({ x in o.OnNext(mapper(x)) })
        return o
    }

    func filter(predictor: (T -> Bool)) -> Observable<T> {
        let o = Observable<T>()
        self.subscribe({ x in if predictor(x) {
            o.OnNext(x)
        } })
        return o
    }

    func merge(o1: Observable<T>, o2: Observable<T>) -> Observable<T> {
        let o = Observable<T>()
        o1.subscribe({ x in o.OnNext(x) })
        o2.subscribe({ x in o.OnNext(x) })
        return o
    }

}
