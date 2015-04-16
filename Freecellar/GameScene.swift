//
//  GameScene.swift
//  Freecellar
//
//  Created by Park Eungju on 4/13/15.
//  Copyright (c) 2015 Park Eungju. All rights reserved.
//

import SpriteKit
import CoreGraphics

class CardNode: SKSpriteNode {
    let card: Card
    
    init(card: Card, frontTexture: SKTexture) {
        self.card = card
        super.init(texture: frontTexture, color: nil, size: CGSizeMake(372, 526))
        texture = frontTexture
        name = "card-" + card.name
        zPosition = 1
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ColumnNode: SKShapeNode {
    let columnType: ColumnType
    
    init(columnType: ColumnType) {
        self.columnType = columnType
        super.init()
        let border = SKShapeNode()
        var path = CGPathCreateMutable()
        CGPathAddRoundedRect(path, nil, CGRectInset(CGRect(origin: CGPointMake(113 * -0.5, 157 * -0.5), size: CGSizeMake(113, 157)), 2, 2), 4, 4)
        self.path = path
        self.lineWidth = 2
        self.fillColor = SKColor(red: 0, green: 0.35, blue: 0.1, alpha: 1)
        self.strokeColor = SKColor(red: 0, green: 0.3, blue: 0.1, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CellNode: ColumnNode {
    init(index: Int) {
        super.init(columnType: .Cell)
        name = "cell-\(index)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FoundationNode: ColumnNode {
    init(index: Int) {
        super.init(columnType: .Foundation)
        name = "foundation-\(index)"
        let a = SKLabelNode(text: "A")
        a.fontSize = frame.width
        a.fontColor = SKColor(red: 0, green: 0.4, blue: 0.1, alpha: 1)
        a.verticalAlignmentMode = .Center
        addChild(a)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CascadeNode: ColumnNode {
    init(index: Int) {
        super.init(columnType: .Cascade)
        name = "cascade-\(index)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct Hand {
    let node: CardNode
    let originalPosition: CGPoint
}

class GameScene: SKScene {
    let table = SKSpriteNode()
    var freecell = Freecell()
    var hand: Hand?
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.grayColor()
        let tablePadding = CGSizeMake(38, 38)
        let columnSpace = CGSizeMake(10, 30)
        let cardSpace = CGSizeMake(14, 24)
        let cardSize = CGSizeMake(113, 157)

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

        for (index, cell) in enumerate(freecell.cells) {
            let mark = CellNode(index: index)
            mark.position = CGPointApplyAffineTransform(cellOrigin, CGAffineTransformMakeTranslation((cellSize.width + columnSpace.width) * CGFloat(index), 0))
            table.addChild(mark)
        }

        for (index, foundation) in enumerate(freecell.foundations) {
            let mark = FoundationNode(index: index)
            mark.position = CGPointApplyAffineTransform(foundationOrigin, CGAffineTransformMakeTranslation((foundationSize.width + columnSpace.width) * CGFloat(index), 0))
            table.addChild(mark)
        }

        for (index, cascade) in enumerate(freecell.cascades) {
            let mark = CascadeNode(index: index)
            mark.position = CGPointApplyAffineTransform(cascadeOrigin, CGAffineTransformMakeTranslation((cascadeSize.width + columnSpace.width) * CGFloat(index), 0))
            table.addChild(mark)
            for (row, card) in enumerate(cascade.cards) {
                let front = CardNode(card: card, frontTexture: cardFront.texture(card.name))
                front.position = CGPointApplyAffineTransform(cascadeOrigin, CGAffineTransformMakeTranslation((cascadeSize.width + columnSpace.width) * CGFloat(index), -cardSpace.height * CGFloat(row)))
                table.addChild(front)
            }
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if let pickedNode = hand?.node {
            let nodes = (nodesAtPoint(theEvent.locationInNode(self)) as! [SKNode]).filter({ return $0 != pickedNode && ($0 is CardNode || $0 is ColumnNode) })
            println(nodes.map({ return $0.name }))
            if let node = nodes.last {
                pickedNode.position = node.position
            } else {
                pickedNode.position = hand!.originalPosition
            }
            pickedNode.zPosition = 1
            hand = nil
        } else {
            let node = nodeAtPoint(theEvent.locationInNode(self))
            if let pickedNode = node as? CardNode {
                if freecell.isPickable(pickedNode.card) {
                    pickedNode.zPosition = 2
                    hand = Hand(node: pickedNode, originalPosition: pickedNode.position)
                }
            }
        }
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        if let pickedNode = hand?.node {
            pickedNode.position = theEvent.locationInNode(pickedNode.parent)
        }
    }
}
