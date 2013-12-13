//
//  MKCave.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKCave.h"
#import "MKUtilites.h"
#import "MKCharacterScene.h"
#import "MKGoblin.h"
#import "MKSpawnAI.h"

#define kCaveCollisionRadius 90
#define kCaveCapacity 50

@interface MKCave ()

@property (nonatomic) NSMutableArray *activeGoblins;
@property (nonatomic) NSMutableArray *inactiveGoblins;
@property (nonatomic) SKEmitterNode *smokeEmitter;

@end

@implementation MKCave

#pragma mark - Initialization

- (id) initAtPosition:(CGPoint)position
{
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"cave_base.png"]
                       atPosition:position];
    if (self)
    {
        _timeUntilNextGenerate = 5.0f + (MK_RANDOM_0_1() * 5.0f);
        
        _activeGoblins = [[NSMutableArray alloc] init];
        _inactiveGoblins = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < kCaveCapacity; ++i)
        {
            MKGoblin *goblin = [[MKGoblin alloc] initAtPosition:self.position];
            goblin.cave = self;
            [(NSMutableArray *) _inactiveGoblins addObject:goblin];
        }
        
        self.movementSpeed = 0.0f;
        
        [self pickRandomFacingForPosition:position];
        
        self.name = @"GoblinCave";
        
        self.intelligence = [[MKSpawnAI alloc] initWithCharacter:self
                                                          target:nil];
    }
    
    return self;
}

- (void) pickRandomFacingForPosition:(CGPoint)position
{
    MKCharacterScene *scene = [self characterScene];
    
    CGFloat maxDoorCanSee = 0.0;
    CGFloat preferredZRotation = 0.0;
    for (int i = 0; i < 8; ++i)
    {
        CGFloat testZ = MK_RANDOM_0_1() * (M_PI * 2.0f);
        CGPoint pos2 = CGPointMake(-sinf(testZ) * 1024 + position.x,
                                   cosf(testZ) * 1024 + position.y);
        CGFloat dist = [scene distanceToWall:position
                                        from:pos2];
        if (dist > maxDoorCanSee)
        {
            maxDoorCanSee = dist;
            preferredZRotation = testZ;
        }
    }
    self.zRotation = preferredZRotation;
}

#pragma mark - Overriden

- (void) configurePhysicsBody
{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:kCaveCollisionRadius];
    self.physicsBody.dynamic = NO;
    
    self.zPosition = -0.85;
    
    self.physicsBody.categoryBitMask = MKColliderTypeCave;
    self.physicsBody.collisionBitMask = MKColliderTypeProjectile |
    MKColliderTypeHero;
    
    self.physicsBody.contactTestBitMask = MKColliderTypeProjectile;
}

- (void) collideWith:(SKPhysicsBody *)other
{
    if (self.health > 0.0f)
    {
        if (other.categoryBitMask & MKColliderTypeProjectile)
        {
            CGFloat damage = 10.0f;
            BOOL killed = [self applyDamage:damage
                             fromProjectile:other.node];
            if (killed)
            {
                [[self characterScene] addToScore:25];
            }
        }
    }
}

- (BOOL) applyDamage:(CGFloat)damage
{
    BOOL killed = [super applyDamage:damage];
    if (killed)
    {
        return YES;
    }
    
    [self updateSmokeForHealth];
    
    for (SKNode *node in self.children)
    {
        [node runAction:[self damageAction]];
    }
    return NO;
}

- (void) performDeath
{
    [super performDeath];
    
    SKNode *splort = [[self deathSplort] copy];
    splort.zPosition = -1.0;
    splort.position = self.position;
    splort.alpha = 0.1;
    [splort runAction:[SKAction fadeAlphaTo:1.0
                                   duration:0.5]];
    MKCharacterScene *scene = [self characterScene];
    
    [scene addNode:splort
       atWorlLayer:MKWorldLayerBelowCharacter];
    [self runAction:[SKAction sequence:@[
                                         [SKAction fadeAlphaTo:0.0f duration:0.5f],
                                         [SKAction removeFromParent],
                                         ]]];
    
    [self.smokeEmitter runAction:[SKAction sequence:@[
                                                      [SKAction waitForDuration:2.0f],
                                                      [SKAction runBlock:^{
        [self.smokeEmitter setParticleBirthRate:2.0f];
    }],
                                                      [SKAction waitForDuration:2.0f],
                                                      [SKAction runBlock:^{
        [self.smokeEmitter setParticleBirthRate:0.0f];
    }],
                                                      [SKAction waitForDuration:5.0f],
                                                      [SKAction fadeAlphaTo:0.0f duration:0.5f],
                                                      [SKAction removeFromParent],
                                                      ]]];
    [(NSMutableArray *)self.inactiveGoblins removeAllObjects];
}

#pragma mark - Damage Smoke Emitter

- (void) updateSmokeForHealth
{
    if (self.health > 75.0f || self.smokeEmitter != nil)
    {
        return;
    }
    
    SKEmitterNode *emitter = [[self deathEmitter] copy];
    emitter.position = self.position;
    emitter.zPosition = -0.8;
    self.smokeEmitter = emitter;
    
    MKCharacterScene *scene = (id)[self scene];
    [scene addNode:emitter
       atWorlLayer:MKWorldLayerAboveCharacter];
}

#pragma mark - Loop update

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval
{
    [super updateWithTimeSinceLastUpdate:interval];
    
    for (MKGoblin *goblin in self.activeGoblins)
    {
        [goblin updateWithTimeSinceLastUpdate:interval];
    }
}

#pragma  mark - Goblin targets

- (void) stopGoblinsFromTargettingHero:(MKCharacter *)hero
{
    for (MKGoblin *goblin in self.activeGoblins)
    {
        [goblin.intelligence clearTarget:hero];
    }
}

#pragma mark - Generating

- (void)generate
{
    if (sGlobalCap > 0 && sGlobalAllocation >= sGlobalCap)
    {
        return;
    }
    
    MKCharacter *object = [self.inactiveGoblins lastObject];
    if (!object)
    {
        return;
    }
    
    CGFloat rot = MK_POLAR_ADJUST(self.zRotation);
    CGFloat offset = kCaveCollisionRadius * 0.75f;
    
    object.position = MKPointByAddingCGPoints(self.position,
                                              CGPointMake(cosf(rot)*offset,
                                                          sinf(rot)*offset));
    
    MKCharacterScene *scene = [self characterScene];
    [object addToScene:scene];
    
    object.zPosition = -1.0f;
    
    [object fadeIn:0.5f];
    
    [(NSMutableArray *)self.inactiveGoblins removeObject:object];
    [(NSMutableArray *)self.activeGoblins addObject:object];
    sGlobalAllocation++;
}

- (void)recycle:(MKGoblin *)goblin
{
    [goblin reset];
    [(NSMutableArray *)self.activeGoblins removeObject:goblin];
    [(NSMutableArray *)self.inactiveGoblins addObject:goblin];
    
    sGlobalAllocation--;
}

#pragma mark - Cap on Generation
static int sGlobalCap = 0;

+ (int)globalGoblinCap
{
    return sGlobalCap;
}

+ (void)setGlobalGoblinCap:(int)amount
{
    sGlobalCap = amount;
}

static int sGlobalAllocation = 0;

#pragma mark - Shared resources

+ (void)loadSharedAssets
{
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Environment"];
        
        
        sSharedCaveBase = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"cave_base.png"]];
        
        sSharedDeathSplort = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"cave_destroyed.png"]];
        
        sSharedDamageEmitter = [SKEmitterNode mk_emitterNodeWithEmitterNamed:@"CaveDamage"];
        sSharedDeathEmitter = [SKEmitterNode mk_emitterNodeWithEmitterNamed:@"CaveDeathSmoke"];
        
        sSharedDamageAction = [SKAction sequence:@[
                                                   [SKAction colorizeWithColor:[SKColor redColor]
                                                              colorBlendFactor:1.0
                                                                      duration:0.0],
                                                   [SKAction waitForDuration:0.25],
                                                   [SKAction colorizeWithColorBlendFactor:0.0 duration:0.1],
                                                   ]];
    });
}

static SKNode *sSharedCaveBase = nil;
- (SKNode *)caveBase
{
    return sSharedCaveBase;
}

static SKSpriteNode *sSharedDeathSplort = nil;
- (SKSpriteNode *)deathSplort
{
    return sSharedDeathSplort;
}

static SKEmitterNode *sSharedDamageEmitter = nil;
- (SKEmitterNode *)damageEmitter
{
    return sSharedDamageEmitter;
}

static SKEmitterNode *sSharedDeathEmitter = nil;
- (SKEmitterNode *)deathEmitter
{
    return sSharedDeathEmitter;
}

static SKAction *sSharedDamageAction = nil;
- (SKAction *)damageAction
{
    return sSharedDamageAction;
}


@end
