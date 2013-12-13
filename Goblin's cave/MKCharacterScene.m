//
//  MKCharacterScene.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 24.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKCharacterScene.h"
#import "MKHeroCharacter.h"
#import "MKUtilites.h"

@interface MKCharacterScene ()

@property (nonatomic) NSTimeInterval lastTimeUpdateInterval;
@property (nonatomic) NSMutableArray *nodes;
@property (nonatomic) NSMutableArray *layers;
@property (nonatomic) SKLabelNode *score;

@end

@implementation MKCharacterScene

#pragma mark - Initialization

- (instancetype) initWithSize:(CGSize)size
{
    self  = [super initWithSize:size];
    if (self)
    {
        _hero = [[MKHeroCharacter alloc] init];
        
        _world = [[SKNode alloc] init];
        [_world setName:@"world"];
        
        _layers = [NSMutableArray arrayWithCapacity:kWorldLayerCount];
        for (int i = 0; i < kWorldLayerCount; i++)
        {
            SKNode *layer = [[SKNode alloc] init];
            layer.zPosition = i - kWorldLayerCount;
            [_world addChild:layer];
            [(NSMutableArray *)_layers addObject:layer];
        }
        
        [self addChild:_world];
    
        [self buildHUD];
    }
    
    return self;
}

- (MKHeroCharacter *)addhero
{
    if (_hero)
    {
        [_hero removeFromParent];
    }
    
    CGPoint spawnPos = self.defaultSpawnPoint;
    
    _hero = [[self.hero.heroClass alloc] initAtPosition:spawnPos];
    if (_hero)
    {
        SKEmitterNode *emitter = [[self sharedSpawnEmitter] copy];
        emitter.position = spawnPos;
        [self addNode:emitter
          atWorlLayer:MKWorldLayerAboveCharacter];
        MKRunOneShotEmitter(emitter, 0.15f);
        
        [_hero fadeIn:2.0f];
        [_hero addToScene:self];
    }
    
    return _hero;
}

- (void)heroWasKilled
{
    _hero.moveRequested = NO;
    
    if (--_hero.livesLeft < 1)
    {
        return;
    }
    [self addhero];
    [self centerWorldOnCharacter];
}

- (void)addNode:(SKNode *)node atWorlLayer:(MKWorldLayer)layer
{
    SKNode *layerNode = self.layers[layer];
    [layerNode addChild:node];
}

- (void)buildHUD
{
    SKNode *hud = [[SKNode alloc] init];
    
    SKSpriteNode *avatar = [SKSpriteNode spriteNodeWithImageNamed:@"iconWarrior_red"];
    avatar.alpha = 0.5;
    avatar.scale = 0.8;
    avatar.anchorPoint = CGPointMake(0, 0);
    avatar.position = CGPointMake(10,
                                  self.frame.size.height - 10 - avatar.size.height);
    [hud addChild:avatar];
    
    _score = [SKLabelNode labelNodeWithFontNamed:@"Copperplate"];
    [_score setName:@"Score"];
    _score.text = @"Score : 0";
    _score.fontSize = 16;
    
    _score.position = CGPointMake(avatar.position.x + avatar.size.width + 40, avatar.position.y + 20);
    [hud addChild:_score];
    
    for (int i = 0; i < 3; ++i)
    {
        SKSpriteNode *heart = [SKSpriteNode spriteNodeWithImageNamed:@"lives.png"];
        heart.anchorPoint = CGPointMake(0, 0);
        heart.scale = 0.6;
        heart.position = CGPointMake(avatar.position.x + avatar.size.width + (10 + heart.size.width) * i,
                                     avatar.position.y + avatar.size.height / 2 - 10);
        heart.alpha = 0.1;
        [hud addChild:heart];
    }
    
    [self addChild:hud];
}

- (void)updateHUD
{
    _score.text = [NSString stringWithFormat:@"Score: %d", _hero.score];
}

#pragma mark - Mapping

- (void)centerWorldOnPosition:(CGPoint)position
{
    [self.world setPosition:CGPointMake(-(position.x) + CGRectGetMidX(self.frame),
                                        -(position.y) + CGRectGetMidY(self.frame))];
    
}

- (void)centerWorldOnCharacter
{
    [self centerWorldOnPosition:_hero.position];
}


- (float)distanceToWall:(CGPoint)pos0 from:(CGPoint)pos1
{
    return 0.0f;
}

- (void) addToScore:(uint32_t)amount
{
    self.hero.score += amount;
}

- (BOOL)canSee:(CGPoint)pos0 from:(CGPoint)pos1
{
    return NO;
}

#pragma mark - Loop update

- (void) update:(NSTimeInterval)currentTime
{
    CFTimeInterval timeSinceLast = currentTime - self.lastTimeUpdateInterval;
    _hero.timeSinceLastAttack += timeSinceLast;
    self.lastTimeUpdateInterval = currentTime;
    if (timeSinceLast > 1)
    {
        timeSinceLast = kMinTimeInterval;
        self.lastTimeUpdateInterval = currentTime;
    }
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    if (_hero.fireAction)
    {
        [_hero performAttackAction];
        _hero.fireAction = NO;
    }
    if (_hero.moveRequested)
    {
        if (!CGPointEqualToPoint(_hero.targetLocation, _hero.position))
        {
            [_hero moveTowards:_hero.targetLocation
              withTimeInterval:timeSinceLast];
        } else
        {
            _hero.moveRequested = NO;
        }
    }
    [self updateHUD];
}

- (void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLast
{
    // Overriden;
}

- (void) didSimulatePhysics
{
    
    if (_hero)
    {
        CGPoint heroPostion = _hero.position;
        CGPoint worldPos = self.world.position;
        
        CGFloat yCoordinate = worldPos.y + heroPostion.y;
        if (yCoordinate < 256)
        {
            worldPos.y = worldPos.y - yCoordinate + 256;
        } else if (yCoordinate > self.frame.size.height - 256)
        {
            worldPos.y = worldPos.y + (self.frame.size.height - yCoordinate) - 256;
        }
        
        CGFloat xCoordinate = worldPos.x + heroPostion.x;
        if (xCoordinate < 256)
        {
            worldPos.x = worldPos.x - xCoordinate + 256;
        } else if (xCoordinate > self.frame.size.width - 256)
        {
            worldPos.x = worldPos.x + (self.frame.size.width - xCoordinate) - 256;
        }
        
        self.world.position = worldPos;
    }
}

#pragma mark - Event handling

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (_hero.movementTouch)
    {
        return;
    }
    _hero.targetLocation = [touch locationInNode:_hero.parent];
    BOOL wantsAttack = NO;
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    for (SKNode *node in nodes)
    {
        if (node.physicsBody.categoryBitMask &
            (MKColliderTypeCave | MKColliderTypeGoblinOrBoss))
        {
            wantsAttack = YES;
        }

    }
    _hero.fireAction = wantsAttack;
    _hero.moveRequested = !wantsAttack;
    _hero.movementTouch = touch;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = _hero.movementTouch;
    if ([touches containsObject:touch])
    {
        _hero.targetLocation = [touch locationInNode:_hero.parent];
        if (!_hero.fireAction)
        {
            _hero.moveRequested = YES;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = _hero.movementTouch;
    
    if ([touches containsObject:touch])
    {
        _hero.movementTouch = nil;
        _hero.fireAction = NO;
    }
}

#pragma mark - Shared assets

+ (void)loadSceneAssetsWithCompletionHandler:(MKAssetLoadCompletionHandler)handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self loadSceneAssets];
        
        if (!handler)
        {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler();
        });
    });
}


+ (void)loadSceneAssets
{
    // Overriden
}

+ (void) releaseSceneAssets
{
    // Overriden
}

- (SKEmitterNode *)sharedSpawnEmitter
{
    // Overriden
    return nil;
}

@end
