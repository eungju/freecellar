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
    var columnNode: ColumnNode
    
    init(card: Card, columnNode: ColumnNode, frontTexture: SKTexture) {
        self.card = card
        self.columnNode = columnNode
        super.init(texture: frontTexture, color: nil, size: CGSizeMake(372, 526))
        texture = frontTexture
        name = "card-" + card.name
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ColumnNode: SKShapeNode {
    let ref: Lens<Freecell, Column>

    init(ref: Lens<Freecell, Column>) {
        self.ref = ref
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
        super.init(ref: _cells >=> _subscript(index))
        name = "cell-\(index)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FoundationNode: ColumnNode {
    init(index: Int) {
        super.init(ref: _foundations >=> _subscript(index))
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
        super.init(ref: _cascades >=> _subscript(index))
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
    let tablePadding = CGSizeMake(33, 33)
    let columnSpace = CGSizeMake(10, 30)
    let cardSpace = CGSizeMake(15, 30)
    let cardSize = CGSizeMake(113, 157)
    
    var table = SKSpriteNode()
    var cardNodes: [String: CardNode] = [:]
    var cascadeNodes: [CascadeNode] = []
    var cellNodes: [CellNode] = []
    var foundationNodes: [FoundationNode] = []
    var hand: Hand?
    
    var freecell = Freecell(seed: 1)
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.grayColor()
        let cellSize = self.cardSize
        let foundationSize = self.cardSize
        let cascadeSize = CGSizeMake(self.cardSize.width, cardSize.height + cardSpace.height * (13 - 1))
        let tableSize = CGSizeMake(cascadeSize.width * 8 + columnSpace.width * (8 - 1) + tablePadding.width * 2,
                                   cellSize.height + columnSpace.height + cascadeSize.height + tablePadding.height * 2)
        println(tableSize)
        let toTable = CGAffineTransformMakeTranslation(-tableSize.width * 0.5, -tableSize.height * 0.5)
        let cascadeOrigin = CGPointApplyAffineTransform(CGPointMake(tablePadding.width + cascadeSize.width * 0.5, tablePadding.height + cascadeSize.height - cardSize.height * 0.5), toTable)
        let cellOrigin = CGPointApplyAffineTransform(CGPointMake(tablePadding.width + cellSize.width * 0.5, tablePadding.height + cascadeSize.height + columnSpace.height + cellSize.height * 0.5), toTable)
        let foundationOrigin = CGPointApplyAffineTransform(CGPointMake(tablePadding.width + cellSize.width * 4 + columnSpace.width * 4 + foundationSize.width * 0.5, tablePadding.height + cascadeSize.height + columnSpace.height + foundationSize.height * 0.5), toTable)

        table.color = SKColor(red: 0, green: 0.4, blue: 0.1, alpha: 1)
        table.size = tableSize
        table.name = "table"
        table.position = CGPointZero
        addChild(table)

        let cardFront = CardFront()

        for (index, cell) in enumerate(freecell.cells) {
            let node = CellNode(index: index)
            cellNodes.append(node)
            node.position = CGPointApplyAffineTransform(cellOrigin, CGAffineTransformMakeTranslation((cellSize.width + columnSpace.width) * CGFloat(index), 0))
            node.zPosition = table.zPosition + 1
            table.addChild(node)
        }

        for (index, foundation) in enumerate(freecell.foundations) {
            let node = FoundationNode(index: index)
            foundationNodes.append(node)
            node.position = CGPointApplyAffineTransform(foundationOrigin, CGAffineTransformMakeTranslation((foundationSize.width + columnSpace.width) * CGFloat(index), 0))
            node.zPosition = table.zPosition + 1
            table.addChild(node)
        }

        for (index, cascade) in enumerate(freecell.cascades) {
            let node = CascadeNode(index: index)
            cascadeNodes.append(node)
            node.position = CGPointApplyAffineTransform(cascadeOrigin, CGAffineTransformMakeTranslation((cascadeSize.width + columnSpace.width) * CGFloat(index), 0))
            node.zPosition = table.zPosition + 1
            table.addChild(node)
            for (row, card) in enumerate(cascade.cards) {
                let cardNode = CardNode(card: card, columnNode: node, frontTexture: cardFront.texture(card.name))
                cardNodes[card.name] = cardNode
                cardNode.hidden = true
                addChild(cardNode)
            }
        }
        
        startGame()
    }
    
    func startGame() {
        freecell = Freecell(seed: Int(arc4random_uniform(32000)) + 1)
        for (index, cascade) in enumerate(freecell.cascades) {
            let columnNode = cascadeNodes[index]
            for (row, card) in enumerate(cascade.cards) {
                let cardNode = cardNodes[card.name]!
                cardNode.hidden = false
                cardNode.columnNode = columnNode
                cardNode.position = CGPointApplyAffineTransform(columnNode.position, CGAffineTransformMakeTranslation(0, -cardSpace.height * CGFloat(row)))
                cardNode.zPosition = columnNode.zPosition + CGFloat(1 + row)
            }
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if let grabbed = hand {
            let pickedNode = grabbed.node
            let nodes = nodesAtPoint(theEvent.locationInNode(self)).filter({ $0 !== pickedNode && ($0 is CardNode || $0 is ColumnNode) }) as! [SKNode]
            var columnNode: ColumnNode? = nil
            if let node = nodes.last as? ColumnNode {
                columnNode = node
            } else if let node = nodes.last as? CardNode {
                columnNode = node.columnNode
            }
            if let targetNode = columnNode, let nextState = freecell.move(pickedNode.card, from: pickedNode.columnNode.ref, to: targetNode.ref) {
                if let cascadeNode = targetNode as? CascadeNode {
                    pickedNode.position = CGPointApplyAffineTransform(targetNode.position, CGAffineTransformMakeTranslation(0, -cardSpace.height * CGFloat(targetNode.ref.get(freecell).height)))
                } else {
                    pickedNode.position = targetNode.position
                }
                pickedNode.zPosition = targetNode.zPosition + CGFloat(targetNode.ref.get(freecell).height + 1)
                pickedNode.columnNode = targetNode
                freecell = nextState
            } else {
                pickedNode.position = grabbed.position
                pickedNode.zPosition = grabbed.zPosition
            }
            pickedNode.setScale(1)
            hand = nil
            if (freecell.isDone) {
                startGame()
            }
        } else {
            let node = nodeAtPoint(theEvent.locationInNode(self))
            if let cardNode = node as? CardNode where freecell.pick(cardNode.card, from: cardNode.columnNode.ref) != nil {
                hand = Hand(node: cardNode, position: cardNode.position, zPosition: cardNode.zPosition)
                cardNode.zPosition = 1 + 54
                cardNode.setScale(1.1)
            }
        }
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        if let grabbed = hand {
            grabbed.node.position = theEvent.locationInNode(grabbed.node.parent)
        }
    }
}
