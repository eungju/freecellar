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
private let BLACK_SUITS: [Suit] = [.Spade, .Club]
private let RED_SUITS: [Suit] = [.Diamond, .Heart]

protocol Column {
    var index: Int { get }
    var top: Card? { get }
}

struct Cell: Column {
    let index: Int
    let card: Card?
    
    init(_ index: Int, _ card: Card?) {
        self.index = index
        self.card = card
    }

    var top: Card? {
        return self.card
    }
    
    func put(card: Card) -> Cell? {
        if let top = self.card {
            return nil
        } else {
            return Cell(index, card)
        }
    }
    
    func take() -> (column: Cell, card: Card)? {
        if let top = self.card {
            return (Cell(index, nil), top)
        } else {
            return nil
        }
    }
}

extension Cell: Equatable {}

func ==(lhs: Cell, rhs: Cell) -> Bool {
    return lhs.index == rhs.index && lhs.card == rhs.card
}

struct Foundation: Column {
    let index: Int
    let cards: [Card]
    
    init(_ index: Int, _ cards: [Card]) {
        self.index = index
        self.cards = cards
    }
    
    var top: Card? {
        return self.cards.last
    }

    func put(card: Card) -> Foundation? {
        if let top = self.top {
            return Foundation.allow(card, on: top) ? Foundation(index, self.cards + [card]) : nil
        } else {
            return card.rank == Rank.Ace ? Foundation(index, [card]) : nil
        }
    }
    
    func take() -> (column: Foundation, card: Card)? {
        if self.cards.isEmpty {
            return nil
        } else {
            return (Foundation(index, Array(self.cards[0..<self.cards.count - 1])), self.cards.last!)
        }
    }

    private static func allow(card: Card, on top: Card) -> Bool {
        return (top.suit == card.suit) && (find(RANK_ORDER, top.rank)! + 1 == find(RANK_ORDER, card.rank)!)
    }
}

extension Foundation: Equatable {}

func ==(lhs: Foundation, rhs: Foundation) -> Bool {
    return lhs.index == rhs.index && lhs.cards == rhs.cards
}

struct Cascade: Column {
    let index: Int
    let cards: [Card]

    init(_ index: Int, _ cards: [Card]) {
        self.index = index
        self.cards = cards
    }
    
    var top: Card? {
        return self.cards.last
    }
    
    func put(card: Card) -> Cascade? {
        if let top = self.top {
            return Cascade.allow(card, on: top) ? Cascade(index, self.cards + [card]) : nil
        } else {
            return Cascade(index, [card])
        }
    }
    
    func take() -> (column: Cascade, card: Card)? {
        if self.cards.isEmpty {
            return nil
        } else {
            return (Cascade(index, Array(self.cards[0..<self.cards.count - 1])), self.cards.last!)
        }
    }
    
    private static func allow(card: Card, on top: Card) -> Bool {
        return alternativeColor(top.suit, card.suit) && (find(RANK_ORDER, top.rank)! - 1 == find(RANK_ORDER, card.rank)!)
    }
   
    private static func alternativeColor(a: Suit, _ b: Suit) -> Bool {
        return (contains(BLACK_SUITS, a) && contains(RED_SUITS, b)) || ((contains(BLACK_SUITS, b) && contains(RED_SUITS, a)))
    }
}

extension Cascade: Equatable {}

func ==(lhs: Cascade, rhs: Cascade) -> Bool {
    return lhs.index == rhs.index && lhs.cards == rhs.cards
}

struct Freecell {
    let cascades: [Cascade]
    let foundations: [Foundation]
    let cells: [Cell]
    
    init() {
        foundations = (0..<4).map({ i in Foundation(i, []) })
        cells = (0..<4).map({ i in Cell(i, nil) })
        var deck: [Card] = []
        for suit in SUIT_ORDER {
            for rank in RANK_ORDER {
                deck.append(Card(rank, suit))
            }
        }
        cascades = (0..<8).map({ i in
            let height = i < 4 ? 7 : 6
            let cascade = Cascade(i, Array(deck[0..<height]))
            deck.removeRange(0..<height)
            return cascade
        })
    }
    
    init(cascades: [Cascade], cells: [Cell], foundations: [Foundation]) {
        self.cascades = cascades
        self.cells = cells
        self.foundations = foundations
    }
    
    func columnContains(card: Card) -> Column? {
        if let column = filter(cascades, { contains($0.cards, card) }).last {
            return column
        }
        if let column = filter(cells, { $0.card == card }).last {
            return column
        }
        if let column = filter(foundations, { contains($0.cards, card) }).last {
            return column
        }
        return nil
    }
    
    func pick(card: Card) -> Freecell? {
        for cascade in cascades {
            if let (changed, taken) = cascade.take() where taken == card {
                var modified = cascades
                modified.replaceRange(cascade.index..<cascade.index + 1, with: [changed])
                return Freecell(cascades: modified, cells: cells, foundations: foundations)
            }
        }
        for cell in cells {
            if let (changed, taken) = cell.take() where taken == card {
                var modified = cells
                modified.replaceRange(cell.index..<cell.index + 1, with: [changed])
                return Freecell(cascades: cascades, cells: modified, foundations: foundations)
            }
        }
        for foundation in foundations {
            if let (changed, taken) = foundation.take() where taken == card {
                var modified = foundations
                modified.replaceRange(foundation.index..<foundation.index + 1, with: [changed])
                return Freecell(cascades: cascades, cells: cells, foundations: modified)
            }
        }
        return nil
    }
    
    func put(card: Card, on: Column) -> Freecell? {
        if let cascade = on as? Cascade, let changed = cascade.put(card) {
            var modified = cascades
            modified.replaceRange(cascade.index..<cascade.index + 1, with: [changed])
            return Freecell(cascades: modified, cells: cells, foundations: foundations)
        } else if let cell = on as? Cell, let changed = cell.put(card) {
            var modified = cells
            modified.replaceRange(cell.index..<cell.index + 1, with: [changed])
            return Freecell(cascades: cascades, cells: modified, foundations: foundations)
        } else if let foundation = on as? Foundation, let changed = foundation.put(card) {
            var modified = foundations
            modified.replaceRange(foundation.index..<foundation.index + 1, with: [changed])
            return Freecell(cascades: cascades, cells: cells, foundations: modified)
        } else {
            return nil
        }
    }
    
    func move(card: Card, to: Column) -> Freecell? {
        return pick(card)?.put(card, on: to)
    }
    
}

extension Freecell: Equatable {}

func ==(lhs: Freecell, rhs: Freecell) -> Bool {
    return lhs.cascades == rhs.cascades && lhs.foundations == rhs.foundations && lhs.cells == rhs.cells
}
