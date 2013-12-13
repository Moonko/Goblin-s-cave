//
//  MKGoblin.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKGoblin.h"
#import "MKCave.h"
#import "MKUtilites.h"
#import "MKChaseAI.h"
#import "MKGameScene.h"

#define kMinimumGoblinSize 0.5
#define kGoblinSizeVariance 0.350
#define kGoblinCollisionRadius 10

@implementation MKGoblin

#pragma mark - Initialization

- (id)initAtPosition:(CGPoint)position
{
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"goblin_idle_0001.png"]
                       atPosition:position];
    
    if (self)
    {
        self.movementSpeed = kMovementSpeed * MK_RANDOM_0_1();
        self.scale = kMinimumGoblinSize + (MK_RANDOM_0_1() * kGoblinSizeVariance);
        self.zPosition = -0.25;
        self.name = @"Enemy";
    
        self.intelligence = [[MKChaseAI alloc] initWithCharacter:self
                                                          target:nil];
    }
    
    return self;
}

- (void)configurePhysicsBody
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kGoblinCollisionRadius];
    
    self.physicsBody.categoryBitMask = MKColliderTypeGoblinOrBoss;
    
    self.physicsBody.collisionBitMask = MKColliderTypeGoblinOrBoss |
    MKColliderTypeHero | MKColliderTypeProjectile | MKColliderTypeWall |
    MKColliderTypeCave;
    
    self.physicsBody.contactTestBitMask = MKColliderTypeProjectile;
}

- (void)reset
{
    [super reset];
    
    self.alpha = 1.0f;
    [self removeAllChildren];
    
    [self configurePhysicsBody];
}

- (void)collideWith:(SKPhysicsBody *)other
{
    if (other.categoryBitMask & MKColliderTypeProjectile)
    {
        CGFloat damage = 100.0f;
        if ((arc4random_uniform(2)) == 0)
        {
            damage = 50.0f;
        }
        
        BOOL killed = [self applyDamage:damage fromProjectile:other.node];
        if (killed)
        {
            [[self characterScene] addToScore:10];
            [self removeFromParent];
            [self.cave recycle:self];
        }
    }
}

- (void)performDeath
{
    [self removeAllActions];
    
    SKSpriteNode *splort = [[self deathSplort] copy];
    splort.zPosition = -1.0;
    splort.zRotation = MK_RANDOM_0_1() * M_PI;
    splort.position = self.position;
    splort.alpha = 0.5;
    [[self characterScene] addNode:splort
                       atWorlLayer:MKWorldLayerGround];
    [splort runAction:[SKAction fadeOutWithDuration:10.0f]];
    
    [super performDeath];
    
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
    self.physicsBody.categoryBitMask = 0;
    self.physicsBody = nil;    
}

#pragma mark - Shared assets

+ (void)loadSharedAssets
{
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Environment"];
        sSharedDeathSplort = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"minionSplort.png"]];
        sSharedDamageAction = [SKAction sequence:@[[SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:1.0 duration:0.0],
                                                   [SKAction waitForDuration:0.75],
                                                   [SKAction colorizeWithColorBlendFactor:0.0 duration:0.1]
                                                   ]];
    });
}

static SKEmitterNode *sSharedDamageEmitter = nil;
- (SKEmitterNode *)damageEmitter
{
    return sSharedDamageEmitter;
}

static SKAction *sSharedDamageAction = nil;
- (SKAction *)damageAction
{
    return sSharedDamageAction;
}

static SKSpriteNode *sSharedDeathSplort = nil;
- (SKSpriteNode *)deathSplort
{
    return sSharedDeathSplort;
}


@end
