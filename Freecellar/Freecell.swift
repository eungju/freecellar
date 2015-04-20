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

struct Column {
    let cards: [Card]
    let rule: ColumnRule
    
    init(_ cards: [Card], _ rule: ColumnRule) {
        self.cards = cards
        self.rule = rule
    }
    
    var top: Card? {
        return self.cards.last
    }
    
    var height: Int {
        return self.cards.count
    }
    
    func has(card: Card) -> Bool {
        return contains(self.cards, card)
    }
    
    func put(card: Card) -> Column? {
        return rule.put(card, self)
    }
    
    func take(card: Card) -> Column? {
        return rule.take(card, self)
    }
}

extension Column: Equatable {}

func ==(lhs: Column, rhs: Column) -> Bool {
    return lhs.cards == rhs.cards
}

struct ColumnRule {
    let put: (Card, Column) -> Column?
    let take: (Card, Column) -> Column?
}

let cellRule = ColumnRule(
    put: { (card: Card, column: Column) -> Column? in
        if let top = column.top {
            return nil
        } else {
            return Column([card], column.rule)
        }
    },
    take: { (card: Card, column: Column) -> Column? in
        if column.top == card {
            return Column([], column.rule)
        } else {
            return nil
        }
    }
)

private func foundationConstraint(card: Card, on top: Card) -> Bool {
    return (top.suit == card.suit) && (find(RANK_ORDER, top.rank)! + 1 == find(RANK_ORDER, card.rank)!)
}

let foundationRule = ColumnRule(
    put: { (card: Card, column: Column) -> Column? in
        if let top = column.top {
            return foundationConstraint(card, on: top) ? Column(column.cards + [card], column.rule) : nil
        } else {
            return card.rank == Rank.Ace ? Column([card], column.rule) : nil
        }
    },
    take: { (card: Card, column: Column) -> Column? in
        if column.top == card {
            return Column(Array(column.cards[0..<column.cards.count - 1]), column.rule)
        } else {
            return nil
        }
    }
)

private func cascadeConstraint(card: Card, on top: Card) -> Bool {
    return alternativeColor(top.suit, card.suit) && (find(RANK_ORDER, top.rank)! - 1 == find(RANK_ORDER, card.rank)!)
}

private func alternativeColor(a: Suit, b: Suit) -> Bool {
    return (contains(BLACK_SUITS, a) && contains(RED_SUITS, b)) || ((contains(BLACK_SUITS, b) && contains(RED_SUITS, a)))
}

let cascadeRule = ColumnRule(
    put: { (card: Card, column: Column) -> Column? in
        if let top = column.top {
            return cascadeConstraint(card, on: top) ? Column(column.cards + [card], column.rule) : nil
        } else {
            return Column([card], column.rule)
        }
    },
    take: { (card: Card, column: Column) -> Column? in
        if column.top == card {
            return Column(Array(column.cards[0..<column.cards.count - 1]), column.rule)
        } else {
            return nil
        }
    }
)

struct Freecell {
    let cascades: [Column]
    let foundations: [Column]
    let cells: [Column]
    
    init() {
        var deck: [Card] = []
        for suit in SUIT_ORDER {
            for rank in RANK_ORDER {
                deck.append(Card(rank, suit))
            }
        }
        cascades = (0..<8).map({ i in
            let height = i < 4 ? 7 : 6
            let cascade = Column(Array(deck[0..<height]), cascadeRule)
            deck.removeRange(0..<height)
            return cascade
        })
        foundations = (0..<4).map({ i in Column([], foundationRule) })
        cells = (0..<4).map({ i in Column([], cellRule) })
    }
    
    init(cascades: [Column], foundations: [Column], cells: [Column]) {
        self.cascades = cascades
        self.foundations = foundations
        self.cells = cells
    }
    
    func pick(card: Card, from: Lens<Freecell, Column>) -> Freecell? {
        if let changedColumn = from.get(self).take(card) {
            return from.set(changedColumn, self)
        }
        return nil
    }
    
    func put(card: Card, to: Lens<Freecell, Column>) -> Freecell? {
        if let changedColumn = to.get(self).put(card) {
            return to.set(changedColumn, self)
        }
        return nil
    }
    
    func move(card: Card, from: Lens<Freecell, Column>, to: Lens<Freecell, Column>) -> Freecell? {
        return pick(card, from: from)?.put(card, to: to)
    }
}

extension Freecell: Equatable {}

func ==(lhs: Freecell, rhs: Freecell) -> Bool {
    return lhs.cascades == rhs.cascades && lhs.foundations == rhs.foundations && lhs.cells == rhs.cells
}

let _cascades = Lens<Freecell, [Column]>(get: { $0.cascades }, set: { Freecell(cascades: $0, foundations: $1.foundations, cells: $1.cells) })
let _cells = Lens<Freecell, [Column]>(get: { $0.cells }, set: { Freecell(cascades: $1.cascades, foundations: $1.foundations, cells: $0) })
let _foundations = Lens<Freecell, [Column]>(get: { $0.foundations }, set: { Freecell(cascades: $1.cascades, foundations: $0, cells: $1.cells) })
