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
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.grayColor()
        let tablePadding = CGSizeMake(28, 28)
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
        let tableOriginTransform = CGAffineTransformMakeTranslation(-tableSize.width / 2, -tableSize.height / 2)
        let cascadeOrigin = CGPointApplyAffineTransform(CGPointMake(tablePadding.width + cascadeSize.width / 2, tablePadding.height + cascadeSize.height - cardSize.height / 2), tableOriginTransform)
        let cellOrigin = CGPointApplyAffineTransform(CGPointMake(tablePadding.width + cellSize.width / 2, tablePadding.height + cascadeSize.height + columnSpace.height + cellSize.height / 2), tableOriginTransform)
        let foundationOrigin = CGPointApplyAffineTransform(CGPointMake(tablePadding.width + cellSize.width * 4 + columnSpace.width * 4 + foundationSize.width / 2, tablePadding.height + cascadeSize.height + columnSpace.height + cellSize.height / 2), tableOriginTransform)
        let table = SKSpriteNode(color: SKColor(red: 0, green: 0.4, blue: 0.1, alpha: 1), size: tableSize)
        table.name = "table"
        table.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        addChild(table)

        let cardFront = CardFront()
        var cursor = CGPointZero

        let markPrototype = SKShapeNode(rectOfSize: markSize, cornerRadius: 4)
        markPrototype.lineWidth = 2
        
        cursor = cellOrigin
        for (index, cell) in enumerate(freecell.cells) {
            let mark = markPrototype.copy() as! SKShapeNode
            mark.name = "cell-mark-\(index)"
            mark.strokeColor = SKColor.blueColor()
            mark.position = cursor
            table.addChild(mark)
            cursor.x += columnSpace.width + cellSize.width
            cursor.y = cellOrigin.y
        }

        cursor = foundationOrigin
        for (index, foundation) in enumerate(freecell.foundations) {
            let mark = markPrototype.copy() as! SKShapeNode
            mark.name = "foundation-mark-\(index)"
            mark.strokeColor = SKColor.redColor()
            mark.position = cursor
            table.addChild(mark)
            cursor.x += columnSpace.width + foundationSize.width
            cursor.y = foundationOrigin.y
        }

        cursor = cascadeOrigin
        for (index, cascade) in enumerate(freecell.cascades) {
            let mark = markPrototype.copy() as! SKShapeNode
            mark.name = "cascade-mark-\(index)"
            mark.strokeColor = SKColor.blueColor()
            mark.position = cursor
            table.addChild(mark)
            for card in cascade.cards {
                let front = SKSpriteNode(texture: cardFront.texture(card.name))
                front.name = "card-" + card.name
                front.setScale(0.5)
                front.position = cursor
                table.addChild(front)
                cursor.y -= cardSpace.height
            }
            cursor.x += columnSpace.width + cascadeSize.width
            cursor.y = cascadeOrigin.y
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        let table = self.childNodeWithName("table")!
        table.position = CGPointMake(self.size.width / 2, self.size.height / 2)
    }
}
