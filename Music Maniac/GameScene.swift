//
//  GameScene.swift
//  Music Maniac
//
//  Created by Brandon Howard on 4/24/16.
//  Copyright (c) 2016 Ticklin' The Ivories. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, BluetoothManagerDelegate, SKPhysicsContactDelegate {

	var bluetooth: BluetoothManager!
	var alpaca: SKSpriteNode!
	var ground = [SKSpriteNode]()
	var scoreLabel: SKLabelNode!
	var note: SKSpriteNode!
	var noteString: String!
	var soundActions = [SKAction]()
	let GROUND_BLOCKS = 20
	let MAX_HEALTH = 3
	var health = 0
	var score = 0
	let noteCategory: UInt32 = 0x1 << 0
	let alpacaCategory: UInt32 = 0x1 << 1

	override func didMoveToView(view: SKView) {
		bluetooth = BluetoothManager()
		bluetooth.setup()
		bluetooth.delegate = self

		self.physicsWorld.contactDelegate = self // For collision detection

		setupAudio()
		addGravityToView()
		addBackground()
		addGround()
		addHealth()
		addAlpacaToView()
		addScore()
		setupNoteAction()
	}

	func setupAudio() {
		let c0 = SKAction.playSoundFileNamed("C0", waitForCompletion: false)
		soundActions.append(c0)
		let d = SKAction.playSoundFileNamed("D", waitForCompletion: false)
		soundActions.append(d)
		let e = SKAction.playSoundFileNamed("E", waitForCompletion: false)
		soundActions.append(e)
		let f = SKAction.playSoundFileNamed("F", waitForCompletion: false)
		soundActions.append(f)
		let g = SKAction.playSoundFileNamed("G", waitForCompletion: false)
		soundActions.append(g)
		let a = SKAction.playSoundFileNamed("A", waitForCompletion: false)
		soundActions.append(a)
		let b = SKAction.playSoundFileNamed("B", waitForCompletion: false)
		soundActions.append(b)
		let c1 = SKAction.playSoundFileNamed("C1", waitForCompletion: false)
		soundActions.append(c1)
	}

	func setupNoteAction() {
		let waitAction = SKAction.waitForDuration(8)
		let noteAction = SKAction.runBlock({ self.addNote() })
		let sequenceAction = SKAction.sequence([noteAction, waitAction])
		let repeatAction = SKAction.repeatActionForever(sequenceAction)
		self.runAction(repeatAction)
	}

	func randomNoteString() -> String {
		let random = Int(arc4random_uniform(8))
		switch (random) {
		case 1:
			noteString = "C0"
			return "C0"
		case 2:
			noteString = "D"
			return "D"
		case 3:
			noteString = "E"
			return "E"
		case 4:
			noteString = "F"
			return "F"
		case 5:
			noteString = "G"
			return "G"
		case 6:
			noteString = "A"
			return "A"
		case 7:
			noteString = "B"
			return "B"
		case 8:
			noteString = "C1"
			return "C1"
		default:
			noteString = "C1"
			return "C1"
		}
	}

	func addGravityToView() {
		self.physicsWorld.gravity = CGVectorMake(0.0, -4.9)
	}

	func addAlpacaToView() {
		alpaca = SKSpriteNode(imageNamed: "Alpaca")
		alpaca.xScale = 0.25
		alpaca.yScale = 0.25
		alpaca.position = CGPointMake(200, frame.height / 2.75)
		alpaca.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: alpaca.size.width - 20, height: alpaca.size.height - 20))
		alpaca.physicsBody?.dynamic = true
		alpaca.physicsBody?.allowsRotation = false
		alpaca.zPosition = 1
		alpaca.physicsBody?.friction = 1.0
		alpaca.physicsBody?.usesPreciseCollisionDetection = true
		alpaca.physicsBody?.contactTestBitMask = noteCategory
		alpaca.physicsBody?.categoryBitMask = alpacaCategory
		self.addChild(alpaca)
	}

	func addBackground() {
		let background = SKSpriteNode(imageNamed: "sky")
		background.position = CGPoint(x: 0, y: 0)
		background.anchorPoint = CGPoint(x: 0, y: 0)
		background.size.width = self.frame.size.width
		background.size.height = self.frame.size.height
		background.zPosition = -2
		self.addChild(background)
	}

	func addGround() {
		for iBlock in 0..<GROUND_BLOCKS {
			let block = SKSpriteNode(imageNamed: "Ground")
			ground.append(block)
			block.xScale = 1.0
			block.yScale = 1.0
			block.position = CGPointMake(0 + CGFloat(iBlock)*block.size.width, 125)
			block.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: block.size.width, height: block.size.height))
			block.physicsBody?.dynamic = false
			block.zPosition = 0
			self.addChild(block)
		}
	}

	func addHealth() {
		health = MAX_HEALTH
	}

	func addScore() {
		scoreLabel = SKLabelNode(fontNamed: "Cassius Garrod")
		scoreLabel.fontSize = 40
		scoreLabel.text = "Score:  \(score)"
		scoreLabel.horizontalAlignmentMode = .Left
		scoreLabel.verticalAlignmentMode = .Top
		scoreLabel.position = CGPoint(x: 20, y: self.frame.height - 110)
		scoreLabel.zPosition = 0
		self.addChild(scoreLabel)
	}

	func addNote() {
		let noteString = randomNoteString()
		let note = SKSpriteNode(imageNamed: noteString)
		note.xScale = 0.25
		note.yScale = 0.25
		note.position = CGPointMake(self.frame.width + note.size.width, 290)
		note.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: note.size.width, height: note.size.height))
		note.physicsBody?.dynamic = true
		note.physicsBody?.allowsRotation = false
		note.zPosition = 1
		note.physicsBody?.friction = 1.0
		note.physicsBody?.usesPreciseCollisionDetection = true
		note.physicsBody?.categoryBitMask = noteCategory
		note.physicsBody?.collisionBitMask = alpacaCategory
		note.physicsBody?.contactTestBitMask = alpacaCategory
		let moveAction = SKAction.moveToX(-note.size.width, duration: 10)
		let deleteAction = SKAction.removeFromParent()
		let sequenceAction = SKAction.sequence([moveAction, deleteAction])
		note.runAction(sequenceAction)
		self.addChild(note)
	}

	func jump() {
		alpaca.physicsBody!.velocity = CGVectorMake(0, 0)
		alpaca.physicsBody!.applyImpulse(CGVectorMake(0, 2000))
//		let fireEffect = SKEmitterNode(fileNamed: "FireParticleEffect")
//		fireEffect!.position = CGPointMake(alpaca.size.width/2, -alpaca.size.height)
//		fireEffect!.name = "sparkEmmitter"
//		fireEffect!.zPosition = 1
//		fireEffect!.targetNode = alpaca
//		fireEffect!.particleLifetime = 0.5
//		fireEffect!.particleColor = UIColor.orangeColor()
//		alpaca.addChild(fireEffect!)
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

		for touch in touches {  }

	}

	func destroyNote() {
		note.removeFromParent()
	}

	override func update(currentTime: CFTimeInterval) {
		if (health <= 0) {
			print("GAME OVER")


		}
	}

	func incrementScore() {
		score += 1
		scoreLabel.text = "Score:  \(score)"
	}

	
	func playSound(sound: String) {
		switch (sound) {
		case "C0":
			runAction(soundActions[0])
		case "D":
			runAction(soundActions[1])
		case "E":
			runAction(soundActions[2])
		case "F":
			runAction(soundActions[3])
		case "G":
			runAction(soundActions[4])
		case "A":
			runAction(soundActions[5])
		case "B":
			runAction(soundActions[6])
		case "C1":
			runAction(soundActions[7])
		default:
			runAction(soundActions[0])
		}
	}

	func didBeginContact(contact: SKPhysicsContact) {

//		let firstNode = contact.bodyA.node as! SKSpriteNode
//		let secondNode = contact.bodyB.node as! SKSpriteNode

		if (contact.bodyA.categoryBitMask == alpacaCategory) &&
			(contact.bodyB.categoryBitMask == noteCategory) {

			print("COLLISION")
			health -= 1
		}

	}

	func keyWasPressed(key: String) {

		if (key == noteString) {
			jump()
			playSound(key)
			incrementScore()
		} else {
			health -= 1
		}
	}
}