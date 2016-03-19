//
// Created by Marcin Wolicki on 15/03/2016.
// Copyright (c) 2016 Marcin Wolicki. All rights reserved.
//

import Foundation


class HandlerWrapper<T>{
    typealias Handler = T -> ()
    private let _handler : Handler
    init (handler:Handler){
        _handler = handler
    }
    
    func invoke(arg : T){
        _handler(arg)
    }
}

class Observable<T> {
    init(){
        _onDispose = {}
    }
    
    private let _onDispose:Dispose
    
    init(onDispose:Dispose){
        _onDispose = onDispose
    }
    
    typealias Handler = T -> ()
    typealias Dispose = () -> ()
    
    private var subscribers = [HandlerWrapper<T>]()
    
    func subscribe(fun: Handler) -> Dispose{
        let wrapper = HandlerWrapper(handler: fun)
        subscribers.append(wrapper);
        return {
            self.subscribers = self.subscribers.filter({$0 !== wrapper})
            if self.subscribers.count == 0 {
                self._onDispose()}
        }
    }

    func set(el: T) {
        for s in subscribers {
            s.invoke(el)
        }
    }
}

extension Observable {
    func map<R>(mapper: (T -> R)) -> Observable<R> {
        var disposer:Dispose = {}
        let o = Observable<R>(onDispose: {disposer()})
        disposer = self.subscribe({ o.set(mapper($0)) })
        return o
    }

    func iterOnce(fun: (T -> ())) {
        self.subscribe({ fun($0) })()
    }

    func map2<T2, R>(mapper: ((T, T2) -> R), o2: Observable<T2>) -> Observable<R> {
        var v1: T? = nil
        var v2: T2? = nil
        
        var disposer:Dispose = {}
        let o = Observable<R>(onDispose: {disposer()})
        let performNext = {
            if case .Some(let _v1) = v1 {
                if case .Some(let _v2) = v2 {
                    let val = mapper(_v1, _v2)
                    o.set(val)
                }
            }
        }

        let disposer1 = self.subscribe({ v1 = $0; performNext() })
        let disposer2 = o2.subscribe({ v2 = $0; performNext() })
        disposer = {disposer1(); disposer2()}
        return o
    }

    func filter(predictor: (T -> Bool)) -> Observable<T> {
        var disposer:Dispose = {}
        let o = Observable<T>(onDispose: {disposer()})
        disposer = self.subscribe({
            if predictor($0) {
                o.set($0)
            }
        })
        return o
    }

    func merge(o2: Observable<T>) -> Observable<T> {
        var disposer:Dispose = {}
        let o = Observable<T>(onDispose: {disposer()})
        let disposer1 = self.subscribe({ o.set($0) })
        let disposer2 = o2.subscribe({ o.set($0) })
        disposer = {disposer1(); disposer2()}
        return o
    }
}
