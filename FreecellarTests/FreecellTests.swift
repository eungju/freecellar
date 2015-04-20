//
//  FreecellTests.swift
//  Freecellar
//
//  Created by Park Eungju on 4/13/15.
//  Copyright (c) 2015 Park Eungju. All rights reserved.
//

import XCTest

let _AS = Card(.Ace, .Spade)
let _2S = Card(.Two, .Spade)
let _3S = Card(.Three, .Spade)
let _4S = Card(.Four, .Spade)

let _AD = Card(.Ace, .Diamond)
let _2D = Card(.Two, .Diamond)
let _3D = Card(.Three, .Diamond)
let _4D = Card(.Four, .Diamond)

let _AH = Card(.Ace, .Heart)
let _2H = Card(.Two, .Heart)
let _4H = Card(.Four, .Heart)

let _2C = Card(.Two, .Club)
let _3C = Card(.Three, .Club)

class CellTests: XCTestCase {
    func testOpenCellsAcceptAnyCard() {
        let open = Column([], cellRule)
        XCTAssertEqual(open.put(_AS)!, Column([_AS], cellRule))
        XCTAssertEqual(open.put(_2S)!, Column([_2S], cellRule))
    }
    
    func testClosedCellsRejectAllCards() {
        let closed = Column([_AS], cellRule)
        XCTAssert(closed.put(_2S) == nil)
        XCTAssert(closed.put(_2D) == nil)
    }
    
    func testOpenCellsHaveNothingToTake() {
        let open = Column([], cellRule)
        XCTAssert(open.take(_AS) == nil)
    }

    func testClosedCellsHaveSomethingToTake() {
        let closed = Column([_AS], cellRule)
        XCTAssertEqual(closed.take(_AS)!, Column([], cellRule))
    }
}

class FoundationTests: XCTestCase {
    func testEmptyFoundationsAcceptAces() {
        let empty = Column([], foundationRule)
        XCTAssertEqual(empty.put(_AS)!, Column([_AS], foundationRule))
        XCTAssert(empty.put(_2S) == nil)
    }
    
    func testFoundationsAcceptTheSuccessorOfTheTop() {
        let noneEmpty = Column([_2S], foundationRule)
        XCTAssertEqual(noneEmpty.put(_3S)!, Column([_2S, _3S], foundationRule))
        XCTAssert(noneEmpty.put(_AS) == nil)
        XCTAssert(noneEmpty.put(_4S) == nil)
        XCTAssert(noneEmpty.put(_3C) == nil)
        XCTAssert(noneEmpty.put(_3D) == nil)
    }
}

class CascadeTests: XCTestCase {
    func testEmptyCascadesAcceptAnyCard() {
        let empty = Column([], cascadeRule)
        XCTAssertEqual(empty.put(_AS)!, Column([_AS], cascadeRule))
        XCTAssertEqual(empty.put(_2S)!, Column([_2S], cascadeRule))
    }
    
    func testCascadesAcceptTheSuccessorOfTheTop() {
        let noneEmpty = Column([_3S], cascadeRule)
        XCTAssertEqual(noneEmpty.put(_2D)!, Column([_3S, _2D], cascadeRule))
        XCTAssertEqual(noneEmpty.put(_2H)!, Column([_3S, _2H], cascadeRule))
        XCTAssert(noneEmpty.put(_AH) == nil)
        XCTAssert(noneEmpty.put(_4H) == nil)
        XCTAssert(noneEmpty.put(_AD) == nil)
        XCTAssert(noneEmpty.put(_4D) == nil)
        XCTAssert(noneEmpty.put(_2S) == nil)
        XCTAssert(noneEmpty.put(_2C) == nil)
    }
    
    func testEmptyCascadesHaveNothingToTake() {
        let empty = Column([], cascadeRule)
        XCTAssert(empty.take(_AS) == nil)
    }

    func testNoneEmptyCascadesHaveSomethingToTake() {
        let noneEmpty = Column([_AS, _2S], cascadeRule)
        XCTAssertEqual(noneEmpty.take(_2S)!, Column([_AS], cascadeRule))
    }
}

class DeckTests: XCTestCase {
    func testSeed1() {
        XCTAssertEqual(" ".join(Deck(seed: 1).cards[0..<9].map({ $0.name })), "JD 2D 9H JC 5D 7H 7C 5H KD")
    }

    func testSeed617() {
        XCTAssertEqual(" ".join(Deck(seed: 617).cards[0..<9].map({ $0.name })), "7D AD 5C 3S 5S 8C 2D AH TD")
    }
}

class FreecellTests: XCTestCase {
    func testInitialization() {
        let freecell = Freecell(seed: 1)
        XCTAssertEqual(freecell.cascades.count, 8)
        XCTAssertEqual(freecell.cascades[0].cards.count, 7)
        XCTAssertEqual(freecell.cascades[3].cards.count, 7)
        XCTAssertEqual(freecell.cascades[4].cards.count, 6)
        XCTAssertEqual(freecell.cascades[7].cards.count, 6)
        XCTAssertNotEqual(freecell.cascades[0], freecell.cascades[1])
        XCTAssertEqual(freecell.foundations.count, 4)
        XCTAssertEqual(freecell.cells.count, 4)
    }
    
    func testLegalMove() {
        let freecell = Freecell(cascades: [Column([_AS], cascadeRule)], foundations: [Column([], foundationRule)], cells: [Column([], cellRule)])
        XCTAssertEqual(freecell.move(_AS, from: _cascades >=> _subscript(0), to: _foundations >=> _subscript(0))!, Freecell(cascades: [Column([], cascadeRule)], foundations: [Column([_AS], foundationRule)], cells: [Column([], cellRule)]))
    }

    func testIlegalMove() {
        let freecell = Freecell(cascades: [Column([_AS, _2S], cascadeRule)], foundations: [Column([], foundationRule)], cells: [Column([], cellRule)])
        XCTAssert(freecell.move(_2S, from: _cascades >=> _subscript(0), to: _foundations >=> _subscript(0)) == nil)
    }
    
    func testDone() {
        XCTAssert(!Freecell(seed: 1).isDone)
        XCTAssert(Freecell(cascades: [], foundations: SUIT_ORDER.map({ suit in Column(RANK_ORDER.map({ rank in Card(rank, suit) }), foundationRule) }), cells: []).isDone)
    }
}
