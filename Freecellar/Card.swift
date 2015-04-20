//
//  Card.swift
//  Freecellar
//
//  Created by Park Eungju on 4/13/15.
//  Copyright (c) 2015 Park Eungju. All rights reserved.
//

import Foundation

enum Suit {
    case Spade, Diamond, Heart, Club
}

enum Rank {
    case Ace, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King
}

struct Card: Printable {
    let rank: Rank
    let suit: Suit
    
    init(_ rank: Rank, _ suit: Suit) {
        self.rank = rank
        self.suit = suit
    }
    
    var name: String {
        get {
            return Card.rankNames[rank]! + Card.suitNames[suit]!
        }
    }
    
    var description: String {
        return name
    }

    static let rankNames: Dictionary<Rank, String> = [
        .Ace: "A",
        .Two: "2",
        .Three: "3",
        .Four: "4",
        .Five: "5",
        .Six: "6",
        .Seven: "7",
        .Eight: "8",
        .Nine: "9",
        .Ten: "T",
        .Jack: "J",
        .Queen: "Q",
        .King: "K"
    ]
    static let suitNames: Dictionary<Suit, String> = [
        .Spade: "S",
        .Diamond: "D",
        .Heart: "H",
        .Club: "C",
    ]
}

extension Card: Equatable {}

func ==(lhs: Card, rhs: Card) -> Bool {
    return lhs.suit == rhs.suit && lhs.rank == rhs.rank
}
