//
// Created by Marcin Wolicki on 15/03/2016.
// Copyright (c) 2016 Marcin Wolicki. All rights reserved.
//

import Foundation


class Observable<T> {
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
        self.subscribe({ o.OnNext(mapper($0)) })
        return o
    }

    func iter(fun: (T -> ())) {
        self.subscribe({ fun($0) })
    }

    func map2<T2, R>(mapper: ((T, T2) -> R), o2: Observable<T2>) -> Observable<R> {
        var v1: T? = nil
        var v2: T2? = nil
        let o = Observable<R>()
        let performNext = {
            if case .Some(let _v1) = v1 {
                if case .Some(let _v2) = v2 {
                    let val = mapper(_v1, _v2)
                    o.OnNext(val)
                }
            }
        }

        self.subscribe({ v1 = $0; performNext() })
        o2.subscribe({ v2 = $0; performNext() })

        return o
    }

    func filter(predictor: (T -> Bool)) -> Observable<T> {
        let o = Observable<T>()
        self.subscribe({
            x in if predictor(x) {
                o.OnNext(x)
            }
        })
        return o
    }

    func merge(o2: Observable<T>) -> Observable<T> {
        let o = Observable<T>()
        self.subscribe({ o.OnNext($0) })
        o2.subscribe({ o.OnNext($0) })
        return o
    }
}
