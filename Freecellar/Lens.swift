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
}

infix operator >>> { associativity left precedence 140 }
func >>><A, B, C>(l: Lens<A, B>, r: Lens<B, C>) -> Lens<A, C> {
    return Lens(get: { r.get(l.get($0)) }, set: { (c, a) in l.set(r.set(c, l.get(a)), a) })
}

extension Array {
    func replace(at: Int, with anElement: T) -> [T] {
        return Swift.map(enumerate(self)) { (i, e) in return i == at ? anElement : e }
    }
}

func _subscript<T>(at: Int) -> Lens<[T], T> {
    return Lens<[T], T>(get: { a -> T in a[at] }, set: { (e, a) -> [T] in a.replace(at, with: e) })
}