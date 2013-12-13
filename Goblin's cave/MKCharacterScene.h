//
//  MKCharacterScene.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 24.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define kMinHeroToEdgeDistance (CGFloat)256;
#define kMinTimeInterval (1.0f / 60.0f)

typedef enum : uint8_t
{
	MKWorldLayerGround = 0,
	MKWorldLayerBelowCharacter,
	MKWorldLayerCharacter,
	MKWorldLayerAboveCharacter,
	MKWorldLayerTop,
	kWorldLayerCount
} MKWorldLayer;

typedef void (^MKAssetLoadCompletionHandler)(void);

@class MKHeroCharacter, MKCharacter;

@interface MKCharacterScene : SKScene

@property (nonatomic, readonly) MKHeroCharacter *hero;

@property (nonatomic) SKNode *world;

@property (nonatomic) CGPoint defaultSpawnPoint;

+ (void)loadSceneAssetsWithCompletionHandler:(MKAssetLoadCompletionHandler)callback;

+ (void)loadSceneAssets;

+ (void)releaseSceneAssets;

- (SKEmitterNode *)sharedSpawnEmitter;

- (void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLast;

- (void)addNode:(SKNode *)node atWorlLayer:(MKWorldLayer)layer;

- (MKHeroCharacter *)addhero;
- (void)heroWasKilled;

- (void)centerWorldOnCharacter;
- (void)centerWorldOnPosition:(CGPoint)position;
- (float)distanceToWall:(CGPoint)pos0 from:(CGPoint)pos1;
- (BOOL)canSee:(CGPoint)pos0 from:(CGPoint)pos1;

- (void)addToScore:(uint32_t)amount;

@end
