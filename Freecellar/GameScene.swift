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
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ColumnNode: SKShapeNode {
    let columnType: Column.Type
    let index: Int
    
    init(columnType: Column.Type, index: Int) {
        self.columnType = columnType
        self.index = index
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
        super.init(columnType: Cell.self, index: index)
        name = "cell-\(index)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FoundationNode: ColumnNode {
    init(index: Int) {
        super.init(columnType: Foundation.self, index: index)
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
        super.init(columnType: Cascade.self, index: index)
        name = "cascade-\(index)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct Hand {
    let node: CardNode
    let position: CGPoint
    let zPosition: CGFloat
}

class GameScene: SKScene {
    let tablePadding = CGSizeMake(38, 198)
    let columnSpace = CGSizeMake(10, 30)
    let cardSpace = CGSizeMake(14, 24)
    let cardSize = CGSizeMake(113, 157)
    let table = SKSpriteNode()
    var freecell = Freecell()
    var hand: Hand?
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.grayColor()
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
            mark.zPosition = table.zPosition + 1
            table.addChild(mark)
        }

        for (index, foundation) in enumerate(freecell.foundations) {
            let mark = FoundationNode(index: index)
            mark.position = CGPointApplyAffineTransform(foundationOrigin, CGAffineTransformMakeTranslation((foundationSize.width + columnSpace.width) * CGFloat(index), 0))
            mark.zPosition = table.zPosition + 1
            table.addChild(mark)
        }

        for (index, cascade) in enumerate(freecell.cascades) {
            let mark = CascadeNode(index: index)
            mark.position = CGPointApplyAffineTransform(cascadeOrigin, CGAffineTransformMakeTranslation((cascadeSize.width + columnSpace.width) * CGFloat(index), 0))
            mark.zPosition = table.zPosition + 1
            table.addChild(mark)
            for (row, card) in enumerate(cascade.cards) {
                let front = CardNode(card: card, frontTexture: cardFront.texture(card.name))
                front.position = CGPointApplyAffineTransform(cascadeOrigin, CGAffineTransformMakeTranslation((cascadeSize.width + columnSpace.width) * CGFloat(index), -cardSpace.height * CGFloat(row)))
                front.zPosition = mark.zPosition + CGFloat(1 + row)
                table.addChild(front)
            }
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if let grabbed = hand {
            let pickedNode = grabbed.node
            let nodes = (nodesAtPoint(theEvent.locationInNode(self)) as! [SKNode]).filter { $0 !== pickedNode && ($0 is CardNode || $0 is ColumnNode) }
            var column: Column? = nil
            if let node = nodes.last {
                if let columnNode = node as? CascadeNode {
                    column = freecell.cascades[columnNode.index]
                } else if let columnNode = node as? CellNode {
                    column = freecell.cells[columnNode.index]
                } else if let columnNode = node as? FoundationNode {
                    column = freecell.foundations[columnNode.index]
                } else if let cardNode = node as? CardNode {
                    column = freecell.columnContains(cardNode.card)
                }
                if let cascade = column as? Cascade where cascade.put(pickedNode.card) != nil {
                } else if let cell = column as? Cell where cell.put(pickedNode.card) != nil {
                } else if let foundation = column as? Foundation where foundation.put(pickedNode.card) != nil {
                } else {
                    column = nil
                }
            }
            if let targetNode = nodes.last, let targetColumn = column {
                if let top = targetColumn.top {
                    let topNode = table.childNodeWithName("card-" + top.name) as! CardNode
                    if let cascade = column as? Cascade {
                        pickedNode.position = CGPointApplyAffineTransform(topNode.position, CGAffineTransformMakeTranslation(0, -cardSpace.height))
                    } else {
                        pickedNode.position = topNode.position
                    }
                    pickedNode.zPosition = topNode.zPosition + 1
                } else {
                    pickedNode.position = targetNode.position
                    pickedNode.zPosition = targetNode.zPosition + 1
                }
                freecell = freecell.move(pickedNode.card, to: targetColumn)!
            } else {
                pickedNode.position = grabbed.position
                pickedNode.zPosition = grabbed.zPosition
            }
            pickedNode.setScale(1)
            hand = nil
        } else {
            let node = nodeAtPoint(theEvent.locationInNode(self))
            if let cardNode = node as? CardNode, _ = freecell.pick(cardNode.card) {
                cardNode.zPosition = 20
                cardNode.setScale(1.1)
                hand = Hand(node: cardNode, position: cardNode.position, zPosition: cardNode.zPosition)
            }
        }
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        if let grabbed = hand {
            grabbed.node.position = theEvent.locationInNode(grabbed.node.parent)
        }
    }

    func targetNodeAtPoint(point: CGPoint) -> SKNode? {
        return (nodesAtPoint(point) as! [SKNode]).filter({ ($0 is CardNode || $0 is ColumnNode) && (self.hand?.node !== $0) }).last
    }
}
