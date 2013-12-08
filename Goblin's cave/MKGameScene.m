//
//  MKGameScene.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 24.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKGameScene.h"
#import "MKUtilites.h"
#import "MKTree.h"
#import "MKCharacter.h"
#import "MKWarrior.h"
#import "MKArcher.h"
#import "MKBoss.h"
#import "MKCave.h"
#import "MKGoblin.h"
#import "MKPlayer.h"

@interface MKGameScene () <SKPhysicsContactDelegate>

@property (nonatomic, readwrite) NSMutableArray *goblinCaves;

@property (nonatomic) MKDataMapRef levelMap;
@property (nonatomic) MKTreeMapRef treeMap;

@property (nonatomic) MKBoss *levelBoss;

@property (nonatomic) NSMutableArray *particleSystem;

@property (nonatomic) NSMutableArray *trees;

@end

@implementation MKGameScene

#pragma mark - Initialization

- (id) initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        _goblinCaves = [[NSMutableArray alloc] init];
        _particleSystem = [[NSMutableArray alloc] init];
        _trees = [[NSMutableArray alloc] init];
        
        _levelMap = MKCreateDataMap(@"map_level.png");
        _treeMap = MKCreateDataMap(@"map_trees.png");
        
        [MKCave setGlobalGoblinCap:32];
        
        [self buildWorld];
        
        [self centerWorldOnPosition:self.defaultSpawnPoint];
    }
    
    return self;
}

#pragma mark -World building

- (void) buildWorld
{
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    self.physicsWorld.contactDelegate = self;
    
    [self addBackgroundTiles];
    
    [self addSpawnPoints];
    
    [self addTrees];
   
    [self addCollisionWalls];
}

- (void) addBackgroundTiles
{
    for (SKNode *tileNode in [self backgroundTiles])
    {
        [self addNode:tileNode
          atWorlLayer:MKWorldLayerGround];
    }
}

- (void)addSpawnPoints
{
    for (int y = 0; y < kLevelMapSize; y++)
    {
        for (int x = 0; x < kLevelMapSize; x++)
        {
            CGPoint location = CGPointMake(x, y);
            MKDataMap spot = [self queryLevelMap:location];
            CGPoint worldPoint = [self convertLevelMapPointToWorldPoint:location];
            
            if (spot.bossLocation <= 200)
            {
                self.levelBoss = [[MKBoss alloc] initAtPosition:worldPoint];
                [self.levelBoss addToScene:self];
                
            } else if (spot.goblinCaveLocation >= 200)
            {
                MKCave *cave = [[MKCave alloc] initAtPosition:worldPoint];
                [self.goblinCaves addObject:cave];
                [cave addToScene:self];
                
            } else if (spot.heroSpawnLocation >= 200)
            {
                
                self.defaultSpawnPoint = worldPoint;
            }
        }
    }
}
- (void) addTrees
{
    for (int y = 0; y < kLevelMapSize; y++)
    {
        for (int x = 0; x < kLevelMapSize; x++)
        {
            CGPoint location = CGPointMake(x, y);
            MKTreeMap spot = [self queryTreeMap:location];
            
            CGPoint treePos = [self convertLevelMapPointToWorldPoint:location];
            MKWorldLayer treeLayer = MKWorldLayerTop;
            MKTree *tree = nil;
            
            if (spot.smallTreeLocation >= 200)
            {
                tree = [[self sharedSmallTree] copy];

            } else if (spot.bigTreeLocation >= 200)
            {
                tree = [[self sharedBigTree] copy];
            } else
            {
                continue;
            }
            
            tree.position = treePos;
            tree.zRotation = MK_RANDOM_0_1() * (M_PI * 2.0f);
            
            [self addNode:tree atWorlLayer:treeLayer];
            [self.trees addObject:tree];
        }
    }
    
    free(self.treeMap);
    self.treeMap = NULL;
}

- (void) addCollisionWalls
{
    NSDate *startDate = [NSDate date];
    unsigned char *filled = alloca(kLevelMapSize * kLevelMapSize);
    memset(filled, 0, kLevelMapSize * kLevelMapSize);
    
    int numVolumes = 0;
    int numBlocks = 0;
    
    for (int y = 0; y < kLevelMapSize; ++y)
    {
        for (int x = 0; x < kLevelMapSize; ++x)
        {
            CGPoint location = CGPointMake(x, y);
            MKDataMap spot = [self queryLevelMap:location];
            
            CGPoint worldPoint = [self convertLevelMapPointToWorldPoint:location];
            
            if (spot.wall < 200)
            {
                continue;
            }
            
            int horizontalDistanceFromLeft = x;
            MKDataMap nextSpot = spot;
            while (horizontalDistanceFromLeft < kLevelMapSize && nextSpot.wall >= 200
                   && !filled[(y * kLevelMapSize) + horizontalDistanceFromLeft])
            {
                horizontalDistanceFromLeft++;
                nextSpot = [self queryLevelMap:CGPointMake(horizontalDistanceFromLeft, y)];
            }
            
            int wallWidth = (horizontalDistanceFromLeft - x);
            int verticalDistanceFromTop = y;
            
            if (wallWidth > 8)
            {
                nextSpot = spot;
                while (verticalDistanceFromTop < kLevelMapSize
                       && nextSpot.wall >= 200)
                {
                    verticalDistanceFromTop++;
                    nextSpot = [self queryLevelMap:CGPointMake(x + (wallWidth / 2),
                                                               verticalDistanceFromTop)];
                }
                
                int wallHeight = (verticalDistanceFromTop - y);
                for (int j = y; j < verticalDistanceFromTop; ++j)
                {
                    for (int i = x; i < horizontalDistanceFromLeft; ++i)
                    {
                        filled[(j * kLevelMapSize) + i] = 255;
                        numBlocks++;
                    }
                }
                
                [self addCollisionWallAtWorldPoint:worldPoint
                                         withWidth:kLevelMapDivisor * wallWidth
                                            height:kLevelMapDivisor * wallHeight];
                numVolumes++;
            }
        }
    }
    
    for (int x = 0; x < kLevelMapSize; ++x)
    {
        for (int y = 0; y < kLevelMapSize; ++y)
        {
            CGPoint location = CGPointMake(x, y);
            MKDataMap spot = [self queryLevelMap:location];
            
            CGPoint worldPoint = [self convertLevelMapPointToWorldPoint:location];
            
            if (spot.wall < 200 || filled[(y * kLevelMapSize) + x])
            {
                continue;
            }
            
            int verticalDistanceFromTop = y;
            MKDataMap nextSpot = spot;
            while (verticalDistanceFromTop < kLevelMapSize && nextSpot.wall >= 200
                   && !filled[(verticalDistanceFromTop * kLevelMapSize) + x])
            {
                verticalDistanceFromTop++;
                nextSpot = [self queryLevelMap:CGPointMake(x, verticalDistanceFromTop)];
            };
            
            int wallHeight = (verticalDistanceFromTop - y);
            int horizontalDistanceFromLeft = x;
            
            if (wallHeight > 8)
            {
                nextSpot = spot;
                while (horizontalDistanceFromLeft < kLevelMapSize && nextSpot.wall >= 200)
                {
                    horizontalDistanceFromLeft++;
                    nextSpot = [self queryLevelMap:CGPointMake(horizontalDistanceFromLeft, y + (wallHeight / 2))];
                }
                
                int wallLength = (horizontalDistanceFromLeft - x);
                for (int j = y; j < verticalDistanceFromTop; ++j)
                {
                    for (int i = x; i < horizontalDistanceFromLeft; ++i)
                    {
                        filled[(j * kLevelMapSize) + i] = 255;
                        numBlocks++;
                    }
                }
                
                [self addCollisionWallAtWorldPoint:worldPoint
                                         withWidth:kLevelMapDivisor * wallLength
                                            height:kLevelMapDivisor * wallHeight];
                numVolumes++;
            }
        }
    }
    NSLog(@"converted %d collision blocks into %d volumes in %f seconds",
          numBlocks, numVolumes, [[NSDate date] timeIntervalSinceDate:startDate]);
}

- (void)addCollisionWallAtWorldPoint:(CGPoint)worldPoint
                           withWidth:(CGFloat)width
                              height:(CGFloat)height
{
    CGRect rect = CGRectMake(0, 0, width, height);
    
    SKNode *wallNode = [SKNode node];
    wallNode.position = CGPointMake(worldPoint.x + rect.size.width * 0.5,
                                    worldPoint.y - rect.size.height * 0.5);
    wallNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rect.size];
    wallNode.physicsBody.dynamic = NO;
    wallNode.physicsBody.categoryBitMask = MKColliderTypeWall;
    wallNode.physicsBody.collisionBitMask = 0;
    
    [self addNode:wallNode atWorlLayer:MKWorldLayerGround];
}

#pragma mark - Level start

- (void) startLevel
{
    [self addhero];
    
    [self centerWorldOnCharacter];
}

#pragma mark - Heroes

- (void) setDefaultPlayerHeroType:(MKHeroType)heroType
{
    switch (heroType)
    {
        case MKHeroTypeArcher:
            self.player.heroClass = [MKArcher class];
            break;
        case MKHeroTypeWarrior:
            self.player.heroClass = [MKWarrior class];
            break;
    }
}

- (void) heroWasKilled
{
    for (MKCave *cave in self.goblinCaves)
    {
        [cave stopGoblinsFromTargettingHero:self.player.hero];
    }
    [super heroWasKilled];
}

#pragma  mark - Loop update

- (void) updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLast
{
    [self.player.hero updateWithTimeSinceLastUpdate:timeSinceLast];
    [self.levelBoss updateWithTimeSinceLastUpdate:timeSinceLast];
    for (MKCave *cave in self.goblinCaves)
    {
        [cave updateWithTimeSinceLastUpdate:timeSinceLast];
    }
}

- (void) didSimulatePhysics
{
    [super didSimulatePhysics];
    
    CGPoint position = CGPointZero;
    if (self.player.hero)
    {
        position = self.player.hero.position;
    } else
    {
        position = self.defaultSpawnPoint;
    }
    
    for (MKTree *tree in self.trees)
    {
        if (MKDistanceBetweenPoints(tree.position, position) < 1024)
        {
            [tree updateAlphaWithScene:self];
        }
    }
    if (!self.worldMovedForUpdate)
    {
        return;
    }
    for (SKEmitterNode *particles in self.particleSystem)
    {
        BOOL particlesAreVisible = MKDistanceBetweenPoints(particles.position,
                                                           position) < 1024;
        if (!particlesAreVisible && !particles.paused)
        {
            particles.paused = YES;
        } else if (particlesAreVisible && particles.paused)
        {
            particles.paused = NO;
        }
    }
}

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *node = contact.bodyA.node;
    if ([node isKindOfClass:[MKCharacter class]])
    {
        [(MKCharacter *)node collideWith:contact.bodyB];
    }
    node = contact.bodyB.node;
    if ([node isKindOfClass:[MKCharacter class]])
    {
        [(MKCharacter *)node collideWith:contact.bodyA];
    }
    
    if (contact.bodyA.categoryBitMask & MKColliderTypeProjectile ||
        contact.bodyB.categoryBitMask & MKColliderTypeProjectile)
    {
        SKNode *projectile = (contact.bodyA.categoryBitMask & MKColliderTypeProjectile) ?
        contact.bodyA.node : contact.bodyB.node;
        [projectile runAction:[SKAction removeFromParent]];
        
        SKEmitterNode *emitter = [[self sharedProjectileSparkEmitter] copy];
        [self addNode:emitter
          atWorlLayer:MKWorldLayerAboveCharacter];
        MKRunOneShotEmitter(emitter, 0.15f);
    }
}

#pragma mark - mapping

- (MKDataMap) queryLevelMap:(CGPoint)point
{
    return self.levelMap[((int)point.y) * kLevelMapSize + ((int)point.x)];
}

- (MKTreeMap)queryTreeMap:(CGPoint)point
{
    return self.treeMap[((int)point.y) * kLevelMapSize + ((int)point.x)];
}

- (float) distanceToWall:(CGPoint)pos0 from:(CGPoint)pos1
{
    CGPoint a = [self convertWorldPointToLevelMapPoint:pos0];
    CGPoint b = [self convertWorldPointToLevelMapPoint:pos1];
    
    CGFloat deltaX = b.x - a.x;
    CGFloat deltaY = b.y - a.y;
    CGFloat dist = MKDistanceBetweenPoints(a, b);
    CGFloat inc = 1.0 / dist;
    CGPoint p = CGPointZero;
    
    for (CGFloat i = 0; i <= 1; i+= inc)
    {
        p.x = a.x + i * deltaX;
        p.y = a.y + i * deltaY;
        
        MKDataMap point = [self queryLevelMap:p];
        if (point.wall > 200)
        {
            CGPoint wpos2 = [self convertLevelMapPointToWorldPoint:p];
            return MKDistanceBetweenPoints(pos0, wpos2);
        }
    }
    return MAXFLOAT;
}

- (BOOL) canSee:(CGPoint)pos0 from:(CGPoint)pos1
{
    CGPoint a = [self convertWorldPointToLevelMapPoint:pos0];
    CGPoint b = [self convertWorldPointToLevelMapPoint:pos1];
    
    CGFloat deltaX = b.x - a.x;
    CGFloat deltaY = b.y - a.y;
    CGFloat dist = MKDistanceBetweenPoints(a, b);
    CGFloat inc = 1.0 / dist;
    CGPoint p = CGPointZero;
    
    for (CGFloat i = 0; i <= 1; i+= inc)
    {
        p.x = a.x + i * deltaX;
        p.y = a.y + i * deltaY;
        
        MKDataMap point = [self queryLevelMap:p];
        if (point.wall > 200)
        {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Point conversion

- (CGPoint) convertLevelMapPointToWorldPoint:(CGPoint)location
{
    int x =   (location.x * kLevelMapDivisor) - (kWorldCenter + (kWorldTileSize/2));
    int y = -(location.y * kLevelMapDivisor) - (kWorldCenter + (kWorldTileSize/2));
    return CGPointMake(x, y);
}

- (CGPoint) convertWorldPointToLevelMapPoint:(CGPoint)location
{
    int x = (location.x + kWorldCenter) / kLevelMapDivisor;
    int y = (kWorldSize - (location.y + kWorldCenter)) /kLevelMapDivisor;
    
    return CGPointMake(x, y);
}

- (void) dealloc
{
    free(_levelMap);
    _levelMap = NULL;
}

#pragma mark - Shared assets

+ (void) loadSceneAssets
{
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Environment"];
    
    sSharedProjectileSparkEmitter = [SKEmitterNode mk_emitterNodeWithEmitterNamed:@"ProjectileSplat"];
    sSharedSpawnEmitter = [SKEmitterNode mk_emitterNodeWithEmitterNamed:@"Spawn"];
    sSharedSmallTree = [[MKTree alloc] initWithSprites:@[
                                                         [SKSpriteNode spriteNodeWithTexture:
                                                          [atlas textureNamed:@"small_tree_base.png"]],
                                                         [SKSpriteNode spriteNodeWithTexture:
                                                          [atlas textureNamed:@"small_tree_middle.png"]],
                                                         [SKSpriteNode spriteNodeWithTexture:
                                                          [atlas textureNamed:@"small_tree_top.png"]]]];
    sSharedBigTree = [[MKTree alloc] initWithSprites:@[
                                                       [SKSpriteNode spriteNodeWithTexture:
                                                        [atlas textureNamed:@"big_tree_base.png"]],
                                                       [SKSpriteNode spriteNodeWithTexture:
                                                        [atlas textureNamed:@"big_tree_middle.png"]],
                                                       [SKSpriteNode spriteNodeWithTexture:
                                                        [atlas textureNamed:@"big_tree_top.png"]]]];
    sSharedBigTree.fadeAlpha = YES;
    
    [self loadWorldTiles];
  
    [MKCave loadSharedAssets];
    [MKArcher loadSharedAssets];
    [MKWarrior loadSharedAssets];
    [MKGoblin loadSharedAssets];
    [MKBoss loadSharedAssets];
}

+ (void) loadWorldTiles
{
    NSLog(@"Loading world tiles");
    NSDate *startDate = [NSDate date];
    
    SKTextureAtlas *tileAtlas = [SKTextureAtlas atlasNamed:@"Tiles"];
    
    sBackgroundTiles = [[NSMutableArray alloc] initWithCapacity:1024];
    for (int y = 0; y < kWorldTileDivisor; y++)
    {
        for (int x = 0; x < kWorldTileDivisor; x++)
        {
            int tileNumber = ( y * kWorldTileDivisor) + x;
            SKSpriteNode *tileNode =
            [SKSpriteNode spriteNodeWithTexture:
             [tileAtlas textureNamed:[NSString stringWithFormat:@"tile%d.png", tileNumber]]];
            CGPoint position = CGPointMake((x * kWorldTileSize) - kWorldCenter,
                                           (kWorldSize - (y * kWorldTileSize)) - kWorldCenter);
            tileNode.position = position;
            tileNode.zPosition = -1.0f;
            tileNode.blendMode = SKBlendModeReplace;
            [(NSMutableArray *)sBackgroundTiles addObject:tileNode];
        }
    }
    NSLog(@"Loaded all world tiles in %f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
}

+ (void) releaseSceneAssets
{
    sBackgroundTiles = nil;
    sSharedProjectileSparkEmitter = nil;
    sSharedSpawnEmitter = nil;
}

static SKEmitterNode *sSharedProjectileSparkEmitter = nil;
- (SKEmitterNode *) sharedProjectileSparkEmitter
{
    return sSharedProjectileSparkEmitter;
}

static SKEmitterNode *sSharedSpawnEmitter = nil;
- (SKEmitterNode *) sharedSpawnEmitter
{
    return sSharedSpawnEmitter;
}

static MKTree *sSharedSmallTree = nil;
- (MKTree *) sharedSmallTree
{
    return sSharedSmallTree;
}

static MKTree *sSharedBigTree = nil;
- (MKTree *) sharedBigTree
{
    return sSharedBigTree;
}

static NSArray *sBackgroundTiles = nil;
- (NSArray *) backgroundTiles
{
    return sBackgroundTiles;
}

@end
