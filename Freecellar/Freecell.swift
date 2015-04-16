//
//  Freecell.swift
//  Freecellar
//
//  Created by Park Eungju on 4/13/15.
//  Copyright (c) 2015 Park Eungju. All rights reserved.
//

import Foundation

private let RANK_ORDER: [Rank] = [.Ace, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Ten, .Jack, .Queen, .King]
private let SUIT_ORDER: [Suit] = [.Spade, .Diamond, .Heart, .Club]

protocol Column {
    typealias ColumnType
    
    var top: Card? {
        get
    }
    
    func put(card: Card) -> ColumnType?
}

struct Cell: Column {
    typealias ColumnType = Cell
    
    let card: Card?
    
    init() {
        self.card = nil
    }
    
    init(_ card: Card) {
        self.card = card
    }

    var top: Card? {
        get {
            return self.card
        }
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

struct Foundation: Column {
    typealias ColumnType = Foundation

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
        return (top.suit == card.suit) && (find(RANK_ORDER, top.rank)! + 1 == find(RANK_ORDER, card.rank)!)
    }
}

extension Foundation: Equatable {}

func ==(lhs: Foundation, rhs: Foundation) -> Bool {
    return lhs.cards == rhs.cards
}

struct Cascade {
    typealias ColumnType = Cascade

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
        return alternativeColor(top.suit, card.suit) && (find(RANK_ORDER, top.rank)! - 1 == find(RANK_ORDER, card.rank)!)
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

enum ColumnType {
    case Cascade, Foundation, Cell
}

enum Action {
    case MoveCard(from: (ColumnType, UInt), to: (ColumnType, UInt))
}

struct Freecell {
    let cascades: [Cascade]
    let foundations: [Foundation]
    let cells: [Cell]
    
    init() {
        foundations = [Foundation](count: 4, repeatedValue: Foundation([]))
        cells = [Cell](count: 4, repeatedValue: Cell())
        var deck: [Card] = []
        for suit in SUIT_ORDER {
            for rank in RANK_ORDER {
                deck.append(Card(rank, suit))
            }
        }
        cascades = (0..<8).map({ i in
            let height = i < 4 ? 7 : 6
            let cascade = Cascade(Array(deck[0..<height]))
            deck.removeRange(0..<height)
            return cascade
        })
    }
    
    func isPickable(card: Card) -> Bool {
        return !cascades.filter({$0.top == card}).isEmpty || !cells.filter({$0.top == card}).isEmpty || !foundations.filter({$0.top == card}).isEmpty
    }
    
    func apply(action: Action) -> Freecell? {
        return nil
    }
}

extension Freecell: Equatable {}

func ==(lhs: Freecell, rhs: Freecell) -> Bool {
    return lhs.cascades == rhs.cascades && lhs.foundations == rhs.foundations && lhs.cells == rhs.cells
}
