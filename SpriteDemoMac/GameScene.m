//
//  GameScene.m
//  SpriteDemoMac
//
//  Created by Ajay Thakur on 4/10/16.
//  Copyright (c) 2016 Ajay Thakur. All rights reserved.
//
//
// Original image assets URLs:
//  1. Desert background: http://science-all.com/image.php?pic=/images/desert/desert-01.jpg
//  2. Tire: http://www.firestonetire.com/content/dam/fst/tire-images/affinity-touring/quick-look.png
//  3. Flapping bird: http://heathersanimations.com/flying/anibird9.gif
//  4. Snake: http://heathersanimations.com/snakes/s16.gif
//
//  Used GIMP to crop images to 2880x1800 size.
//
// Original Sound assets URLs:
//  1. Swish originial sound: https://www.freesound.org/people/byMax/sounds/327990/
//  2. Thud original sound: https://www.freesound.org/people/Reitanna/sounds/332668/
//  3. Old plane sound: https://www.freesound.org/people/fresco/sounds/40810/
//  4. Spaceship sound: https://www.freesound.org/people/nick121087/sounds/234316/
//
// Particles are created in the Xcode Partcile editor.

#import "GameScene.h"
@interface GameScene () <SKPhysicsContactDelegate>

@property (strong, nonatomic) SKSpriteNode* bouncingTireSprite;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here - GameScene.sks sets the size to 2880x1800 full screen mode. */

    // Create a boundary physics body. All Physics objects stay in.
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.physicsWorld.contactDelegate = self; // Delegate for contacts
    self.physicsBody.restitution = 1.0;
    self.physicsBody.categoryBitMask = 0x01;
    self.physicsBody.contactTestBitMask = 0x0;
    self.name = @"Boundary";
    
    // Sprite Node 2: Background Sprite - Desert
    SKSpriteNode *backgroundImageNode = [SKSpriteNode spriteNodeWithImageNamed:@"desert2880x1800"];
    backgroundImageNode.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    backgroundImageNode.name = @"Background";
    backgroundImageNode.zPosition = 0.1;
    [self addChild:backgroundImageNode];
    
    // Sprite Node 3: Lower area - Desert
    //  This adds a affect so the falling tire bounces of little bit up from bottom of
    //  the screem. The image used to create it is exactl bitmap of under-layed background
    SKSpriteNode *lowerStripNode = [SKSpriteNode spriteNodeWithImageNamed:@"desertBottom2880x300"];
    lowerStripNode.name = @"LowerStrip";
    lowerStripNode.position = CGPointMake(self.size.width/2, lowerStripNode.size.height/2);
    lowerStripNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:lowerStripNode.size];
    lowerStripNode.physicsBody.dynamic = NO;
    lowerStripNode.physicsBody.friction = 0.2;
    lowerStripNode.physicsBody.restitution = 0.8;
    lowerStripNode.physicsBody.categoryBitMask = 0x02;
    lowerStripNode.physicsBody.collisionBitMask = 0x00; // does not collide with anything
    lowerStripNode.physicsBody.contactTestBitMask = 0x00;
    lowerStripNode.zPosition = 0.1;
    [self addChild:lowerStripNode];
    
    // Sprite Node 4: A falling tire from sky
    // The moving body in the scene. A tire falls from sky. 
    self.bouncingTireSprite = [SKSpriteNode spriteNodeWithImageNamed:@"tire256x256"];
    self.bouncingTireSprite.name = @"Tire";
    self.bouncingTireSprite.position = CGPointMake(0, self.frame.size.height * 0.75);
    self.bouncingTireSprite.zPosition = 1.0; // Make sure it gets displayed above the backgroind sprite.
    self.bouncingTireSprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.bouncingTireSprite.size.height/2.0];
    self.bouncingTireSprite.physicsBody.dynamic = YES;
    self.bouncingTireSprite.physicsBody.friction = 0.2;
    self.bouncingTireSprite.physicsBody.restitution = 0.8;
    self.bouncingTireSprite.physicsBody.linearDamping = 0.0;
    self.bouncingTireSprite.physicsBody.angularDamping = 0.2;
    self.bouncingTireSprite.physicsBody.allowsRotation = YES;
    self.bouncingTireSprite.physicsBody.mass = 1.0;
    self.bouncingTireSprite.physicsBody.velocity = CGVectorMake(400.0, 0);
    self.bouncingTireSprite.physicsBody.angularVelocity = -10.0;
    self.bouncingTireSprite.physicsBody.affectedByGravity = YES;
    self.bouncingTireSprite.physicsBody.fieldBitMask = 0x01;
    
    self.bouncingTireSprite.physicsBody.categoryBitMask = 0x04; // All added sprites of same category 0x03
    self.bouncingTireSprite.physicsBody.collisionBitMask = 0x03; // Can collide with Lowerstri[e and Edge
    self.bouncingTireSprite.physicsBody.contactTestBitMask = 0x03; // Notify on colision with Boundary and Lower surface
    [self addChild:self.bouncingTireSprite];
    
    //Sprite Node 5,6,7: Reuse 'spaceship' asset + Add a Bird + Add a sanke [animated]
    [self addSpaceshipSprite];
    [self addBirdAtlas];
    [self addSnakeAtlas];
}

-(void)mouseDown:(NSEvent *)theEvent {
     /* Called when a mouse click occurs */
    // When user touched restart the whole sequence.
    [self removeAllTireTracks]; // Rmeove all "TireTracks" nodes
    self.bouncingTireSprite.position = CGPointMake(0, 0.75 * self.size.height);
    self.bouncingTireSprite.physicsBody.velocity = CGVectorMake(400.0, 0);
    self.bouncingTireSprite.physicsBody.angularVelocity = -10.0;

}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

#pragma mark -- Helper funcitons to create Sprites.

// Add spaceship sprite with blue fire particle emitter.
- (void) addSpaceshipSprite {
    SKSpriteNode *spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    spaceship.zPosition = 0.2;
    spaceship.size = CGSizeMake(197, 123);
    [self addChild:spaceship];
    
    // Spaceship Action 1: Move around in an Ellipse
    CGPathRef ellipsePath = CGPathCreateWithEllipseInRect(CGRectMake(0, 1500, 2700, 300), NULL);
    SKAction *flyingTrack = [SKAction followPath:ellipsePath asOffset:NO orientToPath:YES duration:10.0];
    
    // Spaceship Action 2: play sound
    SKAction *playPlaneSound = [SKAction playSoundFileNamed:@"spaceship.wav" waitForCompletion:NO];
    SKAction *spaceshipActionSequence = [SKAction sequence:@[flyingTrack,playPlaneSound]];
    // Run composite action sequence for ever
    SKAction *ssActionSequenceRunForever = [SKAction repeatActionForever:spaceshipActionSequence];
    [spaceship runAction:ssActionSequenceRunForever];
    
    // Add blue fire particles
    NSString *sandsParticlesPath = [[NSBundle mainBundle] pathForResource:@"FireParticle" ofType:@"sks"];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:sandsParticlesPath];
    emitterNode.zPosition = 1.0;
    //emitterNode.targetNode = self;
    emitterNode.position = CGPointMake(0,-60);
    emitterNode.name = @"SSExhaustParticles";
    [spaceship addChild:emitterNode];
}


- (void) addBirdAtlas {
    // Grab the images im a array from the Atlas.
    NSMutableArray *birdFrames = [NSMutableArray array];
    SKTextureAtlas *birdAtlas = [SKTextureAtlas atlasNamed:@"bird"];
    NSInteger countOfFrames = birdAtlas.textureNames.count;
    for (NSInteger i=1; i <= countOfFrames; i++) {
        NSString *texture = [NSString stringWithFormat:@"bird%ld", i];
        SKTexture *aFlap = [birdAtlas textureNamed:texture];
        [birdFrames addObject:aFlap];
    }

    // Create the Bird Sprite Node
    SKSpriteNode *flappingBird = [SKSpriteNode spriteNodeWithTexture:birdFrames[0]];
    flappingBird.position = CGPointMake(2600, 800);
    flappingBird.zPosition = 0.3;
    flappingBird.name = @"FlappingBird";
    [self addChild:flappingBird];
    
    // Add flapping from the atlas to bird node.
    SKAction *flappingImages = [SKAction animateWithTextures:birdFrames timePerFrame:0.1f];
    SKAction *flapForever = [SKAction repeatActionForever:flappingImages];
    
    // Add color changing animations to it.
    // Apple documentation: https://developer.apple.com/library/ios/documentation/GraphicsAnimation/Conceptual/SpriteKit_PG/Sprites/Sprites.html
    //
    SKAction *pulseOrange = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor orangeColor] colorBlendFactor:1.0 duration:3.0],
                                              [SKAction waitForDuration:1.0],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:3.0]]];
    SKAction *pulseOrangeForever = [SKAction repeatActionForever:pulseOrange];
    
    // Add up and down motion.
    SKAction *moveUp = [SKAction moveToY:1300 duration:6.0f];
    SKAction *moveDown = [SKAction moveToY:800 duration:3.0f];
    SKAction *moveCombo = [SKAction sequence:@[moveUp, moveDown]];
    SKAction *moveForever = [SKAction repeatActionForever:moveCombo];
    SKAction *birdActionGroup = [SKAction group:@[flapForever,pulseOrangeForever,moveForever]];
    // Running these in parallel.
    [flappingBird runAction:birdActionGroup withKey:@"BirdAnimation"];
}

- (void) addSnakeAtlas {
    // Grab the images im a array from the Atlas.
    NSMutableArray *snakeFrames = [NSMutableArray array];
    SKTextureAtlas *snakeAtlas = [SKTextureAtlas atlasNamed:@"snake"];
    NSInteger countOfFrames = snakeAtlas.textureNames.count;
    for (NSInteger i=1; i <= countOfFrames; i++) {
        NSString *texture = [NSString stringWithFormat:@"snake%ld", i];
        SKTexture *aFlap = [snakeAtlas textureNamed:texture];
        [snakeFrames addObject:aFlap];
    }
    
    // Create the Bird Sprite Node
    SKSpriteNode *snake = [SKSpriteNode spriteNodeWithTexture:snakeFrames[0]];
    snake.position = CGPointMake(2600, 700);
    snake.zPosition = 0.3;
    snake.name = @"Snake";
    [self addChild:snake];
    
    // Add flapping from the atlas to bird node.
    SKAction *snakeAnime = [SKAction animateWithTextures:snakeFrames timePerFrame:0.4f];
    SKAction *wait = [SKAction waitForDuration:5.0];
    SKAction *moveSeq = [SKAction sequence:@[snakeAnime, wait]];
    SKAction *moveForever = [SKAction repeatActionForever:moveSeq];
    [snake runAction:moveForever withKey:@"snakeMoving"];
}

- (SKEmitterNode* ) createDesertSandParticles: (CGPoint) position {
    NSString *sandsParticlesPath = [[NSBundle mainBundle] pathForResource:@"DesertSand" ofType:@"sks"];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:sandsParticlesPath];
    emitterNode.zPosition = 1.0;
    emitterNode.position = position;
    emitterNode.name = @"SandParticles";
    return emitterNode;
}

- (SKEmitterNode* ) createDesertSmokeParticles: (CGPoint) position {
    NSString *smokeParticlesPath = [[NSBundle mainBundle] pathForResource:@"DesertSmoke" ofType:@"sks"];
    SKEmitterNode * emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:smokeParticlesPath];
    emitterNode.zPosition = 1.0;
    emitterNode.position = position;
    emitterNode.name = @"SmokeParticles";
    
    return emitterNode;
}

// createTireTrack: Creates a sprite at 'postion'
- (SKSpriteNode *) createTireTrack: (CGPoint) position {
    SKSpriteNode *track = [SKSpriteNode spriteNodeWithImageNamed:@"tireMarks90x60"];
    track.zPosition = 0.9;
    track.position = position;
    track.name = @"TireTrack";
    return track;
}

//removeAllTireTracks: Removes all tire track nodes.
- (void) removeAllTireTracks {
    for (SKSpriteNode *node in self.children) {
        if ([node.name containsString:@"TireTrack"]) {
            [node removeFromParent];
        }
    }
}

#pragma mark -- Handle Contacts
- (void)didBeginContact:(SKPhysicsContact *)contact {
    NSString *bodyA = contact.bodyA.node.name;
    NSString *bodyB = contact.bodyB.node.name;
    
    if ( ([bodyA containsString:@"Tire"] && [bodyB containsString:@"LowerStrip"]) ||
        ([bodyB containsString:@"Tire"] && [bodyA containsString:@"LowerStrip"]) ) {
        // When "Tire" collides with "LowerStrip"
        
        // Create required nodes.
        CGPoint point = CGPointMake(contact.contactPoint.x - arc4random_uniform(20.0), contact.contactPoint.y - arc4random_uniform(30.0));
        SKEmitterNode *smoke = [self createDesertSmokeParticles:point];
        SKEmitterNode *sand = [self createDesertSandParticles:point];
        SKSpriteNode *tireTrack = [self createTireTrack:point];
        
        // Create a individual actions.
        SKAction *playThudSound = [SKAction playSoundFileNamed:@"bigThud.mp3" waitForCompletion:NO]; // Action 1: play sound
        SKAction *playWindSound = [SKAction playSoundFileNamed:@"wind.mp3" waitForCompletion:NO]; // Action 2: play sound
        SKAction *addTireTracks = [SKAction runBlock:^{ // Action 3: Add Tire tracks
            [self addChild:tireTrack];
        }];
        SKAction *addSmokeParticles = [SKAction runBlock:^{ // Action 4: Add smoke particles
            [self addChild:smoke];
        }];
        SKAction *addSandParticles = [SKAction runBlock:^{ // Action 5: Add sand particles
            [self addChild:sand];
        }];
        SKAction *waitForSomeTime = [SKAction waitForDuration:4.0]; // Action 6: Wait before removing child nodes
        SKAction *removeSmokeParticles = [SKAction runBlock:^{ // Action 7: Remove child smoke particles node
            [smoke removeFromParent];
        }];
        SKAction *removeSandParticles = [SKAction runBlock:^{ // Action 8: Remove child sand particles node
            [sand removeFromParent];
        }];
        
        // Sequence all desired 8 actions.
        SKAction *actionSequence = [SKAction sequence:@[addTireTracks, playThudSound, playWindSound, addSmokeParticles, addSandParticles, waitForSomeTime, removeSmokeParticles, removeSandParticles]];

        [self runAction:actionSequence]; // Run the action sequence.
        
        // Debug
        // NSLog(@"Collision: [%ld] (%@,%@) at (%f,%f)", self.children.count, bodyA, bodyB, contact.contactPoint.x, contact.contactPoint.y);
        
    } else if ([bodyA containsString:@"Boundary"] || [bodyB containsString:@"Boundary"]) {
        // When "Tires" collide with the "Boundary" adjust velocity and angular rotation
        CGVector velocity = self.bouncingTireSprite.physicsBody.velocity;
        // NSLog(@"Collision: (%@,%@) at (%f,%f) speed:(%f,%f)", bodyA, bodyB, contact.contactPoint.x, contact.contactPoint.y, velocity.dx, velocity.dy);
        if (contact.contactPoint.x > self.frame.size.width * 0.5) {
            self.bouncingTireSprite.physicsBody.velocity = CGVectorMake(-fabs(velocity.dx), velocity.dy);
            self.bouncingTireSprite.physicsBody.angularVelocity = fabs(self.bouncingTireSprite.physicsBody.angularVelocity);
        } else {
            self.bouncingTireSprite.physicsBody.velocity = CGVectorMake(fabs(velocity.dx), velocity.dy);
            self.bouncingTireSprite.physicsBody.angularVelocity = -fabs(self.bouncingTireSprite.physicsBody.angularVelocity);
        }
        
    } else {
        // Should not show as masks setup so no other contacts shoudl be reported.
        NSLog(@"Contact began: (%@,%@)", bodyA, bodyB);
    }
}

- (void) didEndContact:(SKPhysicsContact *)contact {
    // NSString *bodyA = contact.bodyA.node.name;
    // NSString *bodyB = contact.bodyB.node.name;
    // NSLog(@"Contact ended: (%@,%@)", bodyA, bodyB);
}

@end
