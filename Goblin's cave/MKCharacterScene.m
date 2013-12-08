//
//  MKCharacterScene.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 24.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKCharacterScene.h"
#import "MKPlayer.h"
#import "MKHeroCharacter.h"
#import "MKUtilites.h"

@interface MKCharacterScene ()

@property (nonatomic) NSTimeInterval lastTimeUpdateInterval;
@property (nonatomic) NSMutableArray *nodes;
@property (nonatomic) NSMutableArray *layers;

@end

@implementation MKCharacterScene

#pragma mark - Initialization

- (instancetype) initWithSize:(CGSize)size
{
    self  = [super initWithSize:size];
    if (self)
    {
        _player = [[MKPlayer alloc] init];
        
        _world = [[SKNode alloc] init];
        
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
    if (_player.hero && !_player.hero.dying)
    {
        [_player.hero removeFromParent];
    }
    
    CGPoint spawnPos = self.defaultSpawnPoint;
    
    MKHeroCharacter *hero = [[_player.heroClass alloc] initAtPosition:spawnPos];
    if (hero)
    {
        SKEmitterNode *emitter = [[self sharedSpawnEmitter] copy];
        emitter.position = spawnPos;
        [self addNode:emitter
          atWorlLayer:MKWorldLayerAboveCharacter];
        MKRunOneShotEmitter(emitter, 0.15f);
        
        [hero fadeIn:2.0f];
        [hero addToScene:self];
    }
    _player.hero = hero;
    
    return hero;
}

- (void)heroWasKilled
{
    _player.moveRequested = NO;
    
    if (--_player.livesLeft < 1)
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
    
    SKLabelNode *score = [SKLabelNode labelNodeWithFontNamed:@"Copperplate"];
    score.text = @"Score : 0";
    score.fontSize = 16;
    score.position = CGPointMake(avatar.position.x + avatar.size.width + 40, avatar.position.y + 20);
    [hud addChild:score];
    
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

#pragma mark - Mapping

- (void)centerWorldOnPosition:(CGPoint)position
{
    [self.world setPosition:CGPointMake(-(position.x) + CGRectGetMidX(self.frame),
                                        -(position.y) + CGRectGetMidY(self.frame))];
    
    self.worldMovedForUpdate = YES;
}

- (void)centerWorldOnCharacter
{
    [self centerWorldOnPosition:_player.hero.position];
}


- (float)distanceToWall:(CGPoint)pos0 from:(CGPoint)pos1
{
    return 0.0f;
}

- (void) addToScore:(uint32_t)amount
{
    self.player.score += amount;
}

#pragma mark - Loop update

- (void) update:(NSTimeInterval)currentTime
{
    CFTimeInterval timeSinceLast = currentTime - self.lastTimeUpdateInterval;
    self.lastTimeUpdateInterval = currentTime;
    if (timeSinceLast > 1)
    {
        timeSinceLast = kMinTimeInterval;
        self.lastTimeUpdateInterval = currentTime;
        self.worldMovedForUpdate = YES;
    }
    [self updateWithTimeSinceLastUpdate:timeSinceLast];

    if (![_player.hero isDying])
    {
        if (!CGPointEqualToPoint(_player.targetLocation, CGPointZero))
        {
            if (_player.fireAction)
            {
                [_player.hero faceTo:_player.targetLocation];
            }
            if (_player.moveRequested)
            {
                if (!CGPointEqualToPoint(_player.targetLocation, _player.hero.position))
                {
                    [_player.hero moveTowards:_player.targetLocation
                             withTimeInterval:timeSinceLast];
                } else
                {
                    _player.moveRequested = NO;
                }
            }
        }
    }
    
    if (!_player.hero || [_player.hero isDying])
    {
        return;
    }
    if (_player.fireAction)
    {
        [_player.hero performAttackAction];
    }
}

- (void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLast
{
    // Overriden;
}

- (void) didSimulatePhysics
{
    
    if (_player.hero)
    {
        CGPoint heroPostion = _player.hero.position;
        CGPoint worldPos = self.world.position;
        
        CGFloat yCoordinate = worldPos.y + heroPostion.y;
        if (yCoordinate < 256)
        {
            worldPos.y = worldPos.y - yCoordinate + 256;
            _worldMovedForUpdate = YES;
        } else if (yCoordinate > self.frame.size.height - 256)
        {
            worldPos.y = worldPos.y + (self.frame.size.height - yCoordinate) - 256;
            _worldMovedForUpdate = YES;
        }
        
        CGFloat xCoordinate = worldPos.x + heroPostion.x;
        if (xCoordinate < 256)
        {
            worldPos.x = worldPos.x - xCoordinate + 256;
            _worldMovedForUpdate = YES;
        } else if (xCoordinate > self.frame.size.width - 256)
        {
            worldPos.x = worldPos.x + (self.frame.size.width - xCoordinate) - 256;
            _worldMovedForUpdate = YES;
        }
        
        self.world.position = worldPos;
    }
    [self performSelector:@selector(clearWorldMoved)
               withObject:nil
               afterDelay:0.0f];
}

- (void) clearWorldMoved
{
    self.worldMovedForUpdate = NO;
}

#pragma mark - Event handling

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (_player.movementTouch)
    {
        return;
    }
    _player.targetLocation = [touch locationInNode:_player.hero.parent];
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
    _player.fireAction = wantsAttack;
    _player.moveRequested = !wantsAttack;
    _player.movementTouch = touch;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = _player.movementTouch;
    if ([touches containsObject:touch])
    {
        _player.targetLocation = [touch locationInNode:_player.hero.parent];
        if (!_player.fireAction)
        {
            _player.moveRequested = YES;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = _player.movementTouch;
    
    if ([touches containsObject:touch])
    {
        _player.movementTouch = nil;
        _player.fireAction = NO;
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
