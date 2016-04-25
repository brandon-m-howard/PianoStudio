//
//  GameScene.swift
//  Music Maniac
//
//  Created by Brandon Howard on 4/24/16.
//  Copyright (c) 2016 Ticklin' The Ivories. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, BluetoothManagerDelegate {

	var bluetooth: BluetoothManager!
	var alpaca: SKSpriteNode!
	var ground = [SKSpriteNode]()
	var scoreLabel: SKLabelNode!
	let GROUND_BLOCKS = 20
	let MAX_HEALTH = 3
	var health = 0
	var score = 0

	override func didMoveToView(view: SKView) {
		bluetooth = BluetoothManager()
		bluetooth.setup()
		bluetooth.delegate = self

		addGravityToView()
		addBackground()
		addGround()
		addHealth()
		addAlpacaToView()
		addScore()
	}

	func addGravityToView() {
		self.physicsWorld.gravity = CGVectorMake(0.0, -4.9)
	}

	func addAlpacaToView() {
		alpaca = SKSpriteNode(imageNamed: "Alpaca")
		alpaca.xScale = 0.25
		alpaca.yScale = 0.25
		alpaca.position = CGPointMake(200, frame.height / 2.75)
		alpaca.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: alpaca.size.width, height: alpaca.size.height))
		alpaca.physicsBody?.dynamic = true
		alpaca.physicsBody?.allowsRotation = false
		self.addChild(alpaca)
	}

	func addBackground() {

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

		self.addChild(scoreLabel)
	}

	func jump() {
		alpaca.physicsBody!.velocity = CGVectorMake(0, 0)
		alpaca.physicsBody!.applyImpulse(CGVectorMake(0, 1200))
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

		for touch in touches {
			jump()
		}

	}

	override func update(currentTime: CFTimeInterval) {
		incrementScore()
	}

	func incrementScore() {
		score += 1
		scoreLabel.text = "Score:  \(score)"
	}

	
	func playSound(sound: String) {
		let soundAction = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
		self.runAction(soundAction)
	}

	func keyWasPressed(key: String) {
		playSound(key)
		print(key)
	}
}