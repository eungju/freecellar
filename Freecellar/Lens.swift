//
//  Lens.swift
//  Freecellar
//
//  Created by Park Eungju on 4/18/15.
//  Copyright (c) 2015 Park Eungju. All rights reserved.
//

import Foundation

struct Lens<A, B> {
    let get: A -> B
    let set: (B, A) -> A

    func modify(f: (B) -> B) -> (A -> A) {
        return { self.set(f(self.get($0)), $0) }
    }
    
    func andThen<C>(rhs: Lens<B, C>) -> Lens<A, C> {
        return Lens<A, C>(
            get: { rhs.get(self.get($0)) },
            set: { (c, a) in self.set(rhs.set(c, self.get(a)), a) }
        )
    }
}

infix operator >=> { associativity left }
func >=><A, B, C>(lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
    return lhs.andThen(rhs)
}

func _subscript<T>(at: Int) -> Lens<[T], T> {
    return Lens<[T], T>(
        get: { a -> T in a[at] },
        set: { (newB, a) -> [T] in
            map(enumerate(a)) { (i, oldB) in return i == at ? newB : oldB }
        }
    )
}
