//
//  MKUtilites.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define MK_RANDOM_0_1() (arc4random() / (float)(0xffffffffu))

#define MK_POLAR_ADJUST(x) x + (M_PI * 0.5f)

void *MKCreateDataMap(NSString *mapName);

CGFloat MKDistanceBetweenPoints(CGPoint first, CGPoint second);
CGFloat MKRadiansBetweenPoints(CGPoint first, CGPoint second);
CGPoint MKPointByAddingCGPoints(CGPoint first, CGPoint second);

NSArray *MKLoadFramesFromAtlas(NSString *atlasName, NSString *baseFileName, int numberOfFrames);

void MKRunOneShotEmitter(SKEmitterNode *emitter, CGFloat duration);

#pragma pack(1)

typedef struct
{
    uint8_t bossLocation, wall, goblinCaveLocation, heroSpawnLocation;
} MKDataMap;

typedef struct
{
    uint8_t unusedA, bigTreeLocation, smallTreeLocation, unusedB;
} MKTreeMap;

#pragma pack()

typedef MKDataMap *MKDataMapRef;
typedef MKTreeMap *MKTreeMapRef;

@interface NSValue (MKAdventureAdditions)

- (CGPoint)mk_CGPointValue;

+ (instancetype)mk_valueWithCGPoint:(CGPoint)point;

@end

@interface SKEmitterNode (MKAdventureAdditions)

+ (instancetype)mk_emitterNodeWithEmitterNamed:(NSString *)emitterFileName;

@end