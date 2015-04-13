//
//  Freecell.swift
//  Freecellar
//
//  Created by Park Eungju on 4/13/15.
//  Copyright (c) 2015 Park Eungju. All rights reserved.
//

import Foundation

struct Cell {
    let card: Card?
    
    init() {
        self.card = nil
    }
    
    init(_ card: Card) {
        self.card = card
    }
    
    func put(card: Card) -> Cell? {
        if let top = self.card {
            return nil
        } else {
            return Cell(card)
        }
    }
    
    func take() -> (column: Cell, card: Card)? {
        if let top = self.card {
            return (Cell(), top)
        } else {
            return nil
        }
    }
}

extension Cell: Equatable {}

func ==(lhs: Cell, rhs: Cell) -> Bool {
    return lhs.card == rhs.card
}

struct Foundation {
    let cards: [Card]
    
    init(_ cards: [Card]) {
        self.cards = cards
    }
    
    var top: Card? {
        get {
            return self.cards.last
        }
    }

    func put(card: Card) -> Foundation? {
        if let top = self.top {
            return Foundation.allow(card, on: top) ? Foundation(self.cards + [card]) : nil
        } else {
            return card.rank == Rank.Ace ? Foundation([card]) : nil
        }
    }

    private static func allow(card: Card, on top: Card) -> Bool {
        let order: [Rank] = [.Ace, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Ten, .Jack, .Queen, .King]
        let succ: Int = find(order, top.rank)! + 1
        return (top.suit == card.suit) && (order.count > succ && order[succ] == card.rank)
    }
}

extension Foundation: Equatable {}

func ==(lhs: Foundation, rhs: Foundation) -> Bool {
    return lhs.cards == rhs.cards
}

struct Cascade {
    let cards: [Card]

    init(_ cards: [Card]) {
        self.cards = cards
    }
    
    var top: Card? {
        get {
            return self.cards.last
        }
    }
    
    func put(card: Card) -> Cascade? {
        if let top = self.top {
            return Cascade.allow(card, on: top) ? Cascade(self.cards + [card]) : nil
        } else {
            return Cascade([card])
        }
    }
   
    private static func alternativeColor(a: Suit, _ b: Suit) -> Bool {
        return ((a == .Spade || a == .Club) && (b == .Diamond || b == .Heart)) || ((b == .Spade || b == .Club) && (a == .Diamond || a == .Heart))
    }
    
    private static func allow(card: Card, on top: Card) -> Bool {
        let order: [Rank] = [.Ace, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Ten, .Jack, .Queen, .King]
        let pred: Int = find(order, top.rank)! - 1
        return alternativeColor(top.suit, card.suit) && (0 <= pred && order[pred] == card.rank)
    }

    func take() -> (column: Cascade, card: Card)? {
        if self.cards.isEmpty {
            return nil
        } else {
            return (Cascade(Array(self.cards[0..<self.cards.count - 1])), self.cards.last!)
        }
    }
}

extension Cascade: Equatable {}

func ==(lhs: Cascade, rhs: Cascade) -> Bool {
    return lhs.cards == rhs.cards
}

enum Column {
    case Cascade, Foundation, Cell
}

enum Action {
    case MoveCard(from: (Column, UInt), to: (Column, UInt))
}

struct Freecell {
    let cascades: [Cascade]
    let foundations: [Foundation]
    let cells: [Cell]
    
    func apply(action: Action) -> Freecell? {
        return nil
    }
}
