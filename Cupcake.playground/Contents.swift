/*:
 # ![cupcake_img](cupcake2.png) Cupcake
 ## A simplistic game
 
 A guide on how to play is available [here](https://omarelamri.me/cupcake-guide).
 
 
 */

import SpriteKit
import GameplayKit
import PlaygroundSupport


// Constants
let INTERVAL: TimeInterval = 1
let MUFFIN1LIVES = 2
let MUFFIN2LIVES = 3
let MUFFIN3LIVES = 4
let BOSSLIVES = 10

let FRAMEWIDTH = 768
let FRAMEHEIGHT = 768


class TitleScene: SKScene {
    
    let titleLabel = SKLabelNode(text: "Cupcake")
    let startButton = SKLabelNode(text: "Play")
    let muffinEmitter = SKEmitterNode()
    let sparkleEmitter = SKEmitterNode()
    
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        titleLabel.fontColor = UIColor(red: 255/255, green: 181/255, blue: 181/255, alpha: 1.0)
        titleLabel.fontSize = 50
        titleLabel.fontName = "SpaceMono-Bold"
        titleLabel.position = CGPoint(x: size.width*0.5, y: size.height*0.75)
        addChild(titleLabel)
        
        startButton.fontColor = UIColor(red: 125/255, green: 252/255, blue: 121/255, alpha: 1.0)
        startButton.fontSize = 50
        startButton.fontName = "SpaceMono-Regular"
        startButton.position = CGPoint(x: size.width*0.5, y: size.height*0.5)
        addChild(startButton)
        
        muffinEmitter.particleTexture = SKTexture(image: UIImage(named: "muffin")!)
        muffinEmitter.particleSize = CGSize(width: 25, height: 25)
        muffinEmitter.emissionAngle = CGFloat.pi * 1.5
        muffinEmitter.emissionAngleRange = 0.5
        muffinEmitter.particleBirthRate = 5
        muffinEmitter.particleLifetime = 4
        muffinEmitter.particleSpeed = 300
        muffinEmitter.particleZPosition = -1
        muffinEmitter.position = CGPoint(x: size.width*0.5, y: size.height+200)
        addChild(muffinEmitter)
        
        sparkleEmitter.particleTexture = SKTexture(image: UIImage(named: "sprinkle")!)
        sparkleEmitter.particleSize = CGSize(width: 6, height: 18)
        sparkleEmitter.emissionAngle = CGFloat.pi * 0.5
        sparkleEmitter.emissionAngleRange = 0.75
        sparkleEmitter.particleBirthRate = 7
        sparkleEmitter.particleLifetime = 4
        sparkleEmitter.particleSpeed = 600
        sparkleEmitter.particleZPosition = -1
        sparkleEmitter.particleColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        sparkleEmitter.particleColorRedRange = 255
        sparkleEmitter.particleColorGreenRange = 255
        sparkleEmitter.particleColorBlueRange = 255
        sparkleEmitter.particleColorBlendFactor = 1
        sparkleEmitter.position = CGPoint(x: size.width/2, y: -12)
        addChild(sparkleEmitter)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if startButton.contains(touch.location(in: self)) {
                print("Play!")
                
                let presScene = GameScene(size: self.size)
                presScene.scaleMode = .aspectFit
                let transition = SKTransition.moveIn(with: .right, duration: 0.4)
                self.view?.presentScene(presScene, transition: transition)
                return
            }
        }
    }
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let cupcake = SKSpriteNode(texture: SKTexture(image: UIImage(named: "cupcake2")!), size: CGSize(width: 200, height: 200))
    let masterShot = SKSpriteNode(texture: SKTexture(image: UIImage(named: "sprinkle")!), size: CGSize(width: 6, height: 18))
    let masterMuffin = Muffin(texture: SKTexture(image: UIImage(named: "muffin")!), size: CGSize(width: 50, height: 50))
    let replay = SKLabelNode(text: "Play Again")
    
    let muffinsSLabel = SKLabelNode(fontNamed: "SpaceMono-Regular")
    let livesLeftLabel = SKLabelNode(fontNamed: "SpaceMono-Regular")
    let pauseButton = SKLabelNode(fontNamed: "SpaceMono-Bold")
    let pauseLabel = SKLabelNode(fontNamed: "SpaceMono-Bold")
    let returnToTitleButton = SKLabelNode(fontNamed: "SpaceMono-Regular")
    
    var gameEnded = false
    
    var numberOfMuffinsDestroyed = 0 {
        didSet {
            muffinsSLabel.text = "Score: \(numberOfMuffinsDestroyed)"
        }
    }
    var livesLeft = 5 {
        didSet {
            livesLeftLabel.text = "Lives Left: \(livesLeft)"
        }
    }
    
    override func didMove(to view: SKView) {
        cupcake.position = CGPoint(x: size.width/2, y: 0)
        muffinsSLabel.position = CGPoint(x: size.width*0.5, y: size.height-30)
        livesLeftLabel.position = CGPoint(x: size.width-100, y: size.height-30)
        pauseButton.position = CGPoint(x: 30, y: size.height-50)
        pauseLabel.position = CGPoint(x: size.width*0.5, y: size.height*0.5)
        returnToTitleButton.position = CGPoint(x: size.width*0.5, y: size.height*0.15)
        
        masterMuffin.name = "muffin"
        
        muffinsSLabel.fontSize = 20
        livesLeftLabel.fontSize  = 20
        muffinsSLabel.fontColor = .black
        livesLeftLabel.fontColor = .black
        muffinsSLabel.text = "Score: \(numberOfMuffinsDestroyed)"
        livesLeftLabel.text = "Lives Left: \(livesLeft)"
        
        
        pauseButton.text = "||"
        pauseButton.fontSize = 40
        pauseButton.fontColor = .black
        pauseButton.name = "pauseButton"
        pauseLabel.text = "Paused"
        pauseLabel.fontColor = .black
        pauseLabel.fontSize = 30
        
        
        returnToTitleButton.text = "< Return to Title Screen"
        returnToTitleButton.fontSize = 20
        returnToTitleButton.fontColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
        
        self.backgroundColor = .white
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        addChild(cupcake)
        addChild(muffinsSLabel)
        addChild(livesLeftLabel)
        addChild(pauseButton)
        
        generateMuffins()
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 65), SKAction.run { self.addMuffin(isBoss: true) }])), withKey: "bossGenerator")
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if ((firstBody.categoryBitMask & Physics.muffin != 0) &&
            (secondBody.categoryBitMask & Physics.shot != 0)) {
            secondBody.node?.removeFromParent()
            let muffin = firstBody.node as! Muffin
            muffin.livesLeft -= 1
            if muffin.livesLeft <= 0 {
                numberOfMuffinsDestroyed += 1
                switch muffin.muffinClass {
                case .normal:
                    break
                case .medium:
                    numberOfMuffinsDestroyed += 3
                case .hard:
                    numberOfMuffinsDestroyed += 4
                case .boss:
                    numberOfMuffinsDestroyed += 100
                }
                firstBody.node?.removeFromParent()
            }
        }
    }
    
    func generateMuffins() {
        removeAction(forKey: "muffinGenerator")
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run { self.addMuffin(isBoss: false) }, SKAction.wait(forDuration: INTERVAL)])
        ), withKey: "muffinGenerator")
    }
    
    func returnToTitle() {
        let titleScene = TitleScene(size: self.size)
        titleScene.scaleMode = .aspectFit
        let transition = SKTransition.reveal(with: .right, duration: 0.4)
        self.view?.presentScene(titleScene, transition: transition)
    }
    
    func addMuffin(isBoss: Bool) {
        let muffin = masterMuffin.copy() as! Muffin
        
        let x = arc4random_uniform(UInt32(size.width))
        muffin.position = CGPoint(x: Int(x), y: Int(size.height+muffin.size.height))
        muffin.zPosition = -1
        muffin.livesLeft = MUFFIN1LIVES
        
        var moveAction = SKAction.moveTo(y: -(muffin.size.height), duration: 7)
        let level = GKRandomSource.sharedRandom().nextInt(upperBound: 4)
        switch level {
        case 3:
            muffin.livesLeft = MUFFIN2LIVES
            muffin.size = CGSize(width: 75, height: 75)
            muffin.muffinClass = .medium
            moveAction = SKAction.moveTo(y: -(muffin.size.height), duration: 15)
            break
        case 4:
            muffin.livesLeft = MUFFIN3LIVES
            muffin.size = CGSize(width: 100, height: 100)
            muffin.muffinClass = .hard
            moveAction = SKAction.moveTo(y: -(muffin.size.height), duration: 20)
            break
        default:
            break
        }
        
        if isBoss {
            muffin.muffinClass = .boss
            muffin.livesLeft = BOSSLIVES
            muffin.size = CGSize(width: 300, height: 300)
            moveAction = SKAction.moveTo(y: -(muffin.size.height), duration: 30)
        }
        
        muffin.physicsBody = SKPhysicsBody(rectangleOf: muffin.size)
        muffin.physicsBody?.isDynamic = true
        muffin.physicsBody?.categoryBitMask = Physics.muffin
        muffin.physicsBody?.contactTestBitMask = Physics.shot
        muffin.physicsBody?.collisionBitMask = Physics.none
        
        addChild(muffin)
        muffin.run(SKAction.sequence([moveAction, SKAction.run {
            muffin.removeFromParent()
            }]))
    }
    
    func addSparkle(with location: CGPoint) {
        let sparkle = masterShot.copy() as! SKSpriteNode
        
        sparkle.position = cupcake.position
        sparkle.zPosition = -1
        
        let random = GKRandomSource.sharedRandom()
        let color = UIColor(red: CGFloat(Double(random.nextInt(upperBound: 255))/255), green:  CGFloat(Double(random.nextInt(upperBound: 255))/255), blue:  CGFloat(Double(random.nextInt(upperBound: 255))/255), alpha: 1.0)
        sparkle.run(SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0.01))
        
        sparkle.physicsBody = SKPhysicsBody(rectangleOf: sparkle.size)
        sparkle.physicsBody?.isDynamic = true
        sparkle.physicsBody?.categoryBitMask = Physics.shot
        sparkle.physicsBody?.contactTestBitMask = Physics.muffin
        sparkle.physicsBody?.collisionBitMask = Physics.none
        sparkle.physicsBody?.usesPreciseCollisionDetection = true
        
        let offset = location - sparkle.position
        
        let length = sqrt(offset.x*offset.x + offset.y*offset.y)
        
        let direction = offset / length
        let shootAmount = direction * 1000
        let realDest = shootAmount + sparkle.position
        
        let moveAction = SKAction.move(to: realDest, duration: 2)
        
        let angle = Double(random.nextInt(upperBound: 70))*0.1
        let angleAction = SKAction.rotate(byAngle: CGFloat(angle), duration: 0.01)
        
        sparkle.run(angleAction)
        addChild(sparkle)
        sparkle.run(SKAction.sequence([moveAction, SKAction.run {
            sparkle.removeFromParent()
            }]))
    }
    
    func viewPaused() {
        if isPaused == false {
            isPaused = true
            for child in children { if child.name != "pauseButton" { child.alpha = 0.3 } }
            addChild(pauseLabel)
            addChild(returnToTitleButton)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameEnded else {
            for touch in touches {
                if replay.contains(touch.location(in: self)) {
                    let scene = GameScene(size: self.size)
                    scene.scaleMode = .aspectFit
                    let transition = SKTransition.moveIn(with: .right, duration: 0.4)
                    self.view?.presentScene(scene, transition: transition)
                } else if returnToTitleButton.contains(touch.location(in: self)) {
                    returnToTitle()
                }
            }
            return
        }
        
        for touch in touches {
            if pauseButton.contains(touch.location(in: self)) {
                if isPaused {
                    isPaused = false
                    for child in children { child.alpha = 1 }
                    pauseLabel.removeFromParent()
                    returnToTitleButton.removeFromParent()
                } else {
                    viewPaused()
                }
                
            } else if isPaused && returnToTitleButton.contains(touch.location(in: self)) {
                returnToTitle()
            } else {
                run(SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.run {
                            self.addSparkle(with: touch.location(in: self))
                        },
                        SKAction.wait(forDuration: 0.2)
                        ])
                ), withKey: "sparkles")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            removeAction(forKey: "sparkles")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for child in self.children {
            if child.position.y < 0 && !gameEnded && child.name == "muffin" {
                livesLeft -= 1
                guard livesLeft < 1 else {
                    child.removeFromParent()
                    return
                }
                
                for child in self.children { child.alpha = 0.3 }
                
                let label = SKLabelNode(text: "Too many muffins got past!")
                label.fontColor = .black
                label.fontName = "SpaceMono-Bold"
                label.fontSize = 20
                
                label.position = CGPoint(x: size.width*0.5, y: size.height*0.5)
                addChild(label)
                
                replay.fontColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
                replay.fontName = "SpaceMono-Regular"
                replay.fontSize = 20
                replay.position = CGPoint(x: size.width*0.5, y: size.height*0.25)
                addChild(replay)
                
                addChild(returnToTitleButton)
                
                gameEnded = true
                removeAction(forKey: "muffinGenerator")
                removeAction(forKey: "bossGenerator")
                removeAction(forKey: "sparkles")
                
                return
            }
        }
    }
}


struct Physics {
    static let none: UInt32 = 0
    static let all: UInt32 = UInt32.max
    static let muffin: UInt32 = 1
    static let shot: UInt32 = 2
}

class Muffin: SKSpriteNode {
    var livesLeft = 1
    var muffinClass = MuffinClass.normal
}

enum MuffinClass {
    case normal
    case medium
    case hard
    case boss
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    public func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

let spaceBoldFont = Bundle.main.url(forResource: "SpaceMono-Bold", withExtension: "ttf")! as CFURL
CTFontManagerRegisterFontsForURL(spaceBoldFont, .process, nil)

let spaceRegFont = Bundle.main.url(forResource: "SpaceMono-Regular", withExtension: "ttf")! as CFURL
CTFontManagerRegisterFontsForURL(spaceRegFont, .process, nil)

let frame = CGRect(x: 0, y: 0, width: FRAMEWIDTH, height: FRAMEHEIGHT)

let view = SKView(frame: frame)
let scene = TitleScene(size: frame.size)
scene.scaleMode = .aspectFit
view.presentScene(scene)


PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true


//: ![cupcake_img](cupcake2.png)
