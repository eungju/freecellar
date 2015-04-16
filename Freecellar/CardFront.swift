// ---------------------------------------
// Sprite definitions for 'CardFront'
// Generated with TexturePacker 3.7.1
//
// http://www.codeandweb.com/texturepacker
// ---------------------------------------

import SpriteKit


class CardFront {
    let textureAtlas = SKTextureAtlas(named: "CardFront")

    func texture(name: String) -> SKTexture {
        return textureAtlas.textureNamed(name + ".svg")
    }
}
