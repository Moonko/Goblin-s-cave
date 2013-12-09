//
//  MKHeroCharacter.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKHeroCharacter.h"
#import "MKUtilites.h"
#import "MKCharacterScene.h"

#define kHeroProjectileSpeed 480.0
#define kHeroProjectileLifeTime 1.0
#define kHeroProjectileFadeOutTime 0.6

@implementation MKHeroCharacter

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self)
    {
        _livesLeft = kStartLives;
        
        if ((arc4random_uniform(2)) == 0)
        {
            _heroClass = NSClassFromString(@"MKWarrior");
        } else
        {
            _heroClass = NSClassFromString(@"MKArcher");
        }
    }
    return self;
}


- (id) initAtPosition:(CGPoint)position
{
    return [self initWithTexture:nil
                      atPosition:position];
}

- (id) initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position
{
    self = [super initWithTexture:texture
                       atPosition:position];
    if (self)
    {
        self.zRotation = M_PI;
        self.zPosition = -0.25;
        self.name = [NSString stringWithFormat:@"Hero"];
    }
    return self;
}

#pragma mark - Overriding

- (void) configurePhysicsBody
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kCharacterCollisionRadius];
    
    self.physicsBody.categoryBitMask = MKColliderTypeHero;
    self.physicsBody.collisionBitMask = MKColliderTypeGoblinOrBoss |
    MKColliderTypeWall | MKColliderTypeCave;
    self.physicsBody.contactTestBitMask = MKColliderTypeGoblinOrBoss;
}

- (void) collideWith:(SKPhysicsBody *)other
{
    if (other.categoryBitMask & MKColliderTypeGoblinOrBoss)
    {
        MKCharacter *enemy = (MKCharacter *)other.node;
        if (!enemy.dying)
        {
            [self applyDamage:5.0f];
        }
    }
}

#pragma mark - Projectiles

- (void) fireProjectile
{
    MKCharacterScene *scene = [self characterScene];
    
    SKSpriteNode *projectile = [[self projectile] copy];
    projectile.position = self.position;
    projectile.zRotation = self.zRotation;
    
    SKEmitterNode *emitter = [[self projectileEmitter] copy];
    emitter.targetNode = [self.scene childNodeWithName:@"world"];
    [projectile addChild:emitter];
    
    [scene addNode:projectile
       atWorlLayer:MKWorldLayerCharacter];
    
    CGFloat rot = self.zRotation;
    
    [projectile runAction:[SKAction moveByX:-sinf(rot) * kHeroProjectileSpeed * kHeroProjectileLifeTime
                                          y:cosf(rot) * kHeroProjectileLifeTime * kHeroProjectileSpeed
                                   duration:kHeroProjectileLifeTime]];
}

- (SKSpriteNode *)projectile
{
    return nil;
}

- (SKEmitterNode *)projectileEmitter
{
    return nil;
}

+ (void) loadSharedAssets
{
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedDeathEmitter = [SKEmitterNode mk_emitterNodeWithEmitterNamed:@"Death"];
        sSharedDamageEmitter = [SKEmitterNode mk_emitterNodeWithEmitterNamed:@"Damage"];
    });
}

static SKEmitterNode *sSharedDeathEmitter = nil;
- (SKEmitterNode *)deathEmitter
{
    return sSharedDeathEmitter;
}

static SKEmitterNode *sSharedDamageEmitter = nil;
- (SKEmitterNode *)damageEmitter
{
    return sSharedDamageEmitter;
}

@end

NSString *const kPlayer = @"kPlayer";
