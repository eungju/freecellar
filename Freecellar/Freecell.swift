//
//  Freecell.swift
//  Freecellar
//
//  Created by Park Eungju on 4/13/15.
//  Copyright (c) 2015 Park Eungju. All rights reserved.
//

import Foundation

let RANK_ORDER: [Rank] = [.Ace, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Ten, .Jack, .Queen, .King]
let SUIT_ORDER: [Suit] = [.Club, .Diamond, .Heart, .Spade]
let BLACK_SUITS: [Suit] = [.Spade, .Club]
let RED_SUITS: [Suit] = [.Diamond, .Heart]

struct Column {
    let cards: [Card]
    let rule: ColumnRule
    
    init(_ cards: [Card], _ rule: ColumnRule) {
        self.cards = cards
        self.rule = rule
    }
    
    var top: Card? {
        return cards.last
    }
    
    var height: Int {
        return cards.count
    }
    
    var isOpen: Bool {
        return cards.isEmpty
    }
    
    func has(card: Card) -> Bool {
        return cards.contains(card)
    }
    
    func put(card: Card) -> Column? {
        if rule.consistent(card, top) {
            return Column(cards + [card], rule)
        }
        return nil
    }
    
    func take(card: Card) -> Column? {
        if top == card {
            return Column(Array(cards[0..<cards.count - 1]), rule)
        } else {
            return nil
        }
    }
}

extension Column: Equatable {}

func ==(lhs: Column, rhs: Column) -> Bool {
    return lhs.cards == rhs.cards
}

struct ColumnRule {
    let consistent: (Card, Card?) -> Bool
}

let cellRule = ColumnRule(
    consistent: { (over, under) in
        return under == nil
    }
)

private func foundationConstraint(over: Card, on under: Card) -> Bool {
    return (under.suit == over.suit) && (RANK_ORDER.indexOf(under.rank)! + 1 == RANK_ORDER.indexOf(over.rank)!)
}

let foundationRule = ColumnRule(
    consistent: { (over, under) in
        if let under = under {
            return foundationConstraint(over, on: under)
        } else {
            return over.rank == Rank.Ace
        }
    }
)

private func cascadeConstraint(over: Card, on under: Card) -> Bool {
    return alternativeColor(under.suit, b: over.suit) && (RANK_ORDER.indexOf(under.rank)! - 1 == RANK_ORDER.indexOf(over.rank)!)
}

private func alternativeColor(a: Suit, b: Suit) -> Bool {
    return (BLACK_SUITS.contains(a) && RED_SUITS.contains(b)) || ((BLACK_SUITS.contains(b) && RED_SUITS.contains(a)))
}

let cascadeRule = ColumnRule(
    consistent: { (over, under) in
        if let under = under {
            return cascadeConstraint(over, on: under)
        } else {
            return true
        }
    }
)

func tableau(column: Column) -> [Card] {
    if let over = column.top, let remaining = column.take(over) {
        if let under = remaining.top where column.rule.consistent(over, under) {
            return tableau(remaining) + [over]
        } else {
            return [over]
        }
    }
    return []
}

class Random {
    var seed: Int

    init(seed: Int) {
        self.seed = seed
    }

    func next() -> Int {
        seed = (seed * 214013 + 2531011) & 0x7fffffff
        return (seed >> 16) & 0x7fff
    }
}

struct Deck {
    let cards: [Card]
    
    init(seed: Int) {
        let random = Random(seed: seed)
        var cards: [Card] = []
        for rank in Array(RANK_ORDER.reverse()) {
            for suit in Array(SUIT_ORDER.reverse()) {
                cards.append(Card(rank, suit))
            }
        }
        for i in 0..<(cards.count - 1) {
            let j = (cards.count - 1) - random.next() % (cards.count - i);
            let t = cards[i]
            cards[i] = cards[j]
            cards[j] = t
        }
        self.cards = cards
    }
}

struct Freecell {
    let cascades: [Column]
    let foundations: [Column]
    let cells: [Column]
    let hand: [Card]

    init(cards: [Card]) {
        cascades = (0..<8).map({ i in
            return Column((0..<(i < 4 ? 7 : 6)).map({ j in cards[i + j * 8] }), cascadeRule)
        })
        foundations = (0..<4).map({ i in Column([], foundationRule) })
        cells = (0..<4).map({ i in Column([], cellRule) })
        hand = []
    }
    
    init(seed: Int) {
        self.init(cards: Deck(seed: seed).cards)
    }
    
    init(cascades: [Column], foundations: [Column], cells: [Column], hand: [Card]) {
        self.cascades = cascades
        self.foundations = foundations
        self.cells = cells
        self.hand = hand
    }
    
    func pick(card: Card, from: Lens<Freecell, Column>) -> Freecell? {
        return from.`try`({ $0.take(card) })(self).map { _hand.set([card], $0) }
    }
    
    func put(to: Lens<Freecell, Column>) -> Freecell? {
        return _hand.get(self).reduce(_hand.set([], self), combine: { (game, card) in
            return game.flatMap(to.`try`({ $0.put(card) }))
        })
    }
    
    func move(card: Card, from: Lens<Freecell, Column>, to: Lens<Freecell, Column>) -> Freecell? {
        return pick(card, from: from)?.put(to)
    }
    
    var isDone: Bool {
        return foundations.filter({ $0.height == RANK_ORDER.count }).count == foundations.count
    }
}

extension Freecell: Equatable {}

func ==(lhs: Freecell, rhs: Freecell) -> Bool {
    return lhs.cascades == rhs.cascades && lhs.foundations == rhs.foundations && lhs.cells == rhs.cells && lhs.hand == rhs.hand
}

let _cascades = Lens<Freecell, [Column]>(get: { $0.cascades }, set: { Freecell(cascades: $0, foundations: $1.foundations, cells: $1.cells, hand: $1.hand) })
let _cells = Lens<Freecell, [Column]>(get: { $0.cells }, set: { Freecell(cascades: $1.cascades, foundations: $1.foundations, cells: $0, hand: $1.hand) })
let _foundations = Lens<Freecell, [Column]>(get: { $0.foundations }, set: { Freecell(cascades: $1.cascades, foundations: $0, cells: $1.cells, hand: $1.hand) })
let _hand = Lens<Freecell, [Card]>(get: { $0.hand }, set: { Freecell(cascades: $1.cascades, foundations: $1.foundations, cells: $1.cells, hand: $0) })
