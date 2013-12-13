//
//  MKArtificialIntelligence.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class MKCharacter;

@interface MKArtificialIntelligence : NSObject

@property (nonatomic, weak) MKCharacter *character;
@property (nonatomic, weak) MKCharacter *target;
@property (nonatomic) NSMutableArray *explosionTextures;

- (id) initWithCharacter:(MKCharacter *)character target:(MKCharacter *)target;

- (void) clearTarget:(MKCharacter *)target;

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)timeInterval;

@end
