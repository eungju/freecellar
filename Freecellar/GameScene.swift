//
//  GameScene.swift
//  Freecellar
//
//  Created by Park Eungju on 4/13/15.
//  Copyright (c) 2015 Park Eungju. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let table = SKSpriteNode()
    var hand: SKNode?
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.grayColor()
        let tablePadding = CGSizeMake(38, 38)
        let columnSpace = CGSizeMake(10, 20)
        let cardSpace = CGSizeMake(14, 24)
        let cardSize = CGSizeMake(113, 157)
        let markSize = CGSizeMake(113 - 4, 157 - 4)

        let freecell = Freecell()
        let cellSize = cardSize
        let foundationSize = cardSize
        let cascadeSize = CGSizeMake(cardSize.width, cardSize.height + cardSpace.height * (7 - 1))
        let tableSize = CGSizeMake(cascadeSize.width * 8 + columnSpace.width * (8 - 1) + tablePadding.width * 2,
                                   cellSize.height + columnSpace.height + cascadeSize.height + tablePadding.height * 2)
        let toTable = CGAffineTransformMakeTranslation(-tableSize.width * 0.5, -tableSize.height * 0.5)
        let cascadeOrigin = CGPointApplyAffineTransform(CGPointMake(tablePadding.width + cascadeSize.width / 2, tablePadding.height + cascadeSize.height - cardSize.height / 2), toTable)
        let cellOrigin = CGPointApplyAffineTransform(CGPointMake(tablePadding.width + cellSize.width / 2, tablePadding.height + cascadeSize.height + columnSpace.height + cellSize.height / 2), toTable)
        let foundationOrigin = CGPointApplyAffineTransform(CGPointMake(tablePadding.width + cellSize.width * 4 + columnSpace.width * 4 + foundationSize.width / 2, tablePadding.height + cascadeSize.height + columnSpace.height + foundationSize.height / 2), toTable)
        table.color = SKColor(red: 0, green: 0.4, blue: 0.1, alpha: 1)
        table.size = tableSize
        table.name = "table"
        table.position = CGPointZero
        addChild(table)

        let cardFront = CardFront()
        var cursor = CGPointZero

        let markPrototype = SKShapeNode(rectOfSize: markSize, cornerRadius: 4)
        markPrototype.lineWidth = 2
        markPrototype.fillColor = SKColor(red: 0, green: 0.35, blue: 0.1, alpha: 1)
        markPrototype.strokeColor = SKColor(red: 0, green: 0.3, blue: 0.1, alpha: 1)
        
        cursor = cellOrigin
        for (index, cell) in enumerate(freecell.cells) {
            let mark = markPrototype.copy() as! SKShapeNode
            mark.name = "cell-mark-\(index)"
            mark.position = cursor
            table.addChild(mark)
            cursor.x += columnSpace.width + cellSize.width
            cursor.y = cellOrigin.y
        }

        cursor = foundationOrigin
        for (index, foundation) in enumerate(freecell.foundations) {
            let mark = markPrototype.copy() as! SKShapeNode
            mark.name = "foundation-mark-\(index)"
            mark.position = cursor
            let a = SKLabelNode(text: "A")
            a.fontSize = cardSize.width
            a.fontColor = SKColor(red: 0, green: 0.4, blue: 0.1, alpha: 1)
            a.verticalAlignmentMode = .Center
            mark.addChild(a)
            table.addChild(mark)
            cursor.x += columnSpace.width + foundationSize.width
            cursor.y = foundationOrigin.y
        }

        cursor = cascadeOrigin
        for (index, cascade) in enumerate(freecell.cascades) {
            let mark = markPrototype.copy() as! SKShapeNode
            mark.name = "cascade-mark-\(index)"
            mark.position = cursor
            table.addChild(mark)
            for card in cascade.cards {
                let front = SKSpriteNode(texture: cardFront.texture(card.name), color: nil, size: CGSizeMake(372.0, 526.0))
                front.name = "card-" + card.name
                front.position = cursor
                table.addChild(front)
                cursor.y -= cardSpace.height
            }
            cursor.x += columnSpace.width + cascadeSize.width
            cursor.y = cascadeOrigin.y
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if let touchedNode = hand {
            touchedNode.position = theEvent.locationInNode(table)
            hand = nil
        } else {
            let touchedNode = nodeAtPoint(theEvent.locationInNode(self))
            hand = touchedNode
        }
    }
}
