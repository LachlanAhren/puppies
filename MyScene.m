//
//  MyScene.m
//  Test
//
//  Created by lachmaxwell on 6/13/14.
//  Copyright (c) 2014 Lachlan. All rights reserved.
//

#import "MyScene.h"
#include <stdlib.h>

@interface MyScene () <SKPhysicsContactDelegate>
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) SKSpriteNode * player;
@end
static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        /*
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
         */

        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"annalivia_skeleton small"];
        self.player.xScale = 0.5;
        self.player.yScale = 0.5;
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        [self addChild:self.player];
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // 1 - Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    
    // 2 - Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"flower"];
    SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
    
    [projectile runAction:[SKAction repeatActionForever:action]];
    projectile.position = self.player.position;
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.density = 10;
    //projectile.physicsBody.mass = 200000;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = monsterCategory;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    // 3- Determine offset of location to projectile
    CGPoint offset = rwSub(location, projectile.position);
    
    // 4 - Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
    
    // 5 - OK to add now - we've double checked position
    [self addChild:projectile];
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = rwNormalize(offset);
    /*
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    //CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    // 9 - Create the actions
    float velocity = 60.0/1.0; */
    [projectile.physicsBody applyImpulse:CGVectorMake(direction.x * 20, direction.y * 20)];
    //float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction waitForDuration:(30)];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}
- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)puppy {
    NSLog(@"Hit");
    [projectile removeFromParent];
    //puppy.xScale = -0.25;
   //[puppy.physicsBody applyImpulse:CGVectorMake(30, 0)];
    int r = arc4random() % 5;
    if (r <= 1)
    {
        [self addPuppy];
    }
}
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
    [self runAction:[SKAction playSoundFileNamed:@"160092__jorickhoofd__dog-bark-1.wav" waitForCompletion:NO]];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"fidget"];
        
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
     */
}
- (void)addPuppy {
    
    // Create sprite
    SKSpriteNode * puppy = [SKSpriteNode spriteNodeWithImageNamed:@"fidget"];
    puppy.xScale = 0.25;
    puppy.yScale = 0.25;
    // Determine where to spawn the puppy along the Y axis
    int minY = puppy.size.height / 2;
    int maxY = self.frame.size.height - puppy.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the puppy slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    puppy.position = CGPointMake(self.frame.size.width - puppy.size.width/2, actualY);
    [self addChild:puppy];
    
    // Determine speed of the puppy
    int minDuration = 7.0;
    int maxDuration = 18.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    puppy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:puppy.size]; // 1
    puppy.physicsBody.dynamic = YES; // 2
    puppy.physicsBody.categoryBitMask = monsterCategory; // 3
    puppy.physicsBody.contactTestBitMask = projectileCategory; // 4
    puppy.physicsBody.collisionBitMask = projectileCategory; // 5
    
    // Create the actions
    [puppy.physicsBody applyImpulse:CGVectorMake(-13, 0)];
    
    SKAction * actionMove = [SKAction waitForDuration:30];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [puppy runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}
- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 2) {
        self.lastSpawnTimeInterval = 0;
        [self addPuppy];
    }
}



@end
