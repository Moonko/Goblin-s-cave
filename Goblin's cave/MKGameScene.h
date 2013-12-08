//
//  MKGameScene.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 24.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKCharacterScene.h"

#define kWorldTileDivisor 32
#define kWorldSize 4096
#define kWorldTileSize (kWorldSize / kWorldTileDivisor)

#define kWorldCenter 2048

#define kLevelMapSize 256
#define kLevelMapDivisor (kWorldSize / kLevelMapSize)

typedef enum : uint8_t
{
    MKHeroTypeArcher,
    MKHeroTypeWarrior
} MKHeroType;

@class MKHeroCharacter;

@interface MKGameScene : MKCharacterScene

- (void) startLevel;

- (void)setDefaultPlayerHeroType:(MKHeroType)heroType;

@end
