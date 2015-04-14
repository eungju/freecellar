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
        let open = Cell()
        XCTAssertEqual(open.put(_AS)!, Cell(_AS))
        XCTAssertEqual(open.put(_2S)!, Cell(_2S))
    }
    
    func testClosedCellsRejectAllCards() {
        let closed = Cell(_AS)
        XCTAssert(closed.put(_2S) == nil)
        XCTAssert(closed.put(_2D) == nil)
    }
    
    func testOpenCellsHaveNothingToTake() {
        let open = Cell()
        XCTAssert(open.take() == nil)
    }

    func testClosedCellsHaveSomethingToTake() {
        let closed = Cell(_AS)
        XCTAssertEqual(closed.take()!.column, Cell())
        XCTAssertEqual(closed.take()!.card, _AS)
    }
}

class FoundationTests: XCTestCase {
    func testEmptyFoundationsAcceptAces() {
        let empty = Foundation([])
        XCTAssertEqual(empty.put(_AS)!, Foundation([_AS]))
        XCTAssert(empty.put(_2S) == nil)
    }
    
    func testFoundationsAcceptTheSuccessorOfTheTop() {
        let noneEmpty = Foundation([_2S])
        XCTAssertEqual(noneEmpty.put(_3S)!, Foundation([_2S, _3S]))
        XCTAssert(noneEmpty.put(_AS) == nil)
        XCTAssert(noneEmpty.put(_4S) == nil)
        XCTAssert(noneEmpty.put(_3C) == nil)
        XCTAssert(noneEmpty.put(_3D) == nil)
    }
}

class CascadeTests: XCTestCase {
    func testEmptyCascadesAcceptAnyCard() {
        let empty = Cascade([])
        XCTAssertEqual(empty.put(_AS)!, Cascade([_AS]))
        XCTAssertEqual(empty.put(_2S)!, Cascade([_2S]))
    }
    
    func testCascadesAcceptTheSuccessorOfTheTop() {
        let noneEmpty = Cascade([_3S])
        XCTAssertEqual(noneEmpty.put(_2D)!, Cascade([_3S, _2D]))
        XCTAssertEqual(noneEmpty.put(_2H)!, Cascade([_3S, _2H]))
        XCTAssert(noneEmpty.put(_AH) == nil)
        XCTAssert(noneEmpty.put(_4H) == nil)
        XCTAssert(noneEmpty.put(_AD) == nil)
        XCTAssert(noneEmpty.put(_4D) == nil)
        XCTAssert(noneEmpty.put(_2S) == nil)
        XCTAssert(noneEmpty.put(_2C) == nil)
    }
    
    func testEmptyCascadesHaveNothingToTake() {
        let empty = Cascade([])
        XCTAssert(empty.take() == nil)
    }

    func testNoneEmptyCascadesHaveSomethingToTake() {
        let noneEmpty = Cascade([_AS, _2S])
        XCTAssertEqual(noneEmpty.take()!.column, Cascade([_AS]))
        XCTAssertEqual(noneEmpty.take()!.card, _2S)
    }
}

class FreecellTests: XCTestCase {
    func testInitialization() {
        let freecell = Freecell()
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
//        let freecell = Freecell(cascades: [Cascade([_AS])], foundations: [], cells: [])
//        XCTAssertEqual(freecell.apply(.MoveCard(from: ((.Cascade), 0), to: (.Foundation, 0)))!, Freecell(cascades: [Cascade([])], foundations: [Foundation([_AS])], cells: []))
    }
}
