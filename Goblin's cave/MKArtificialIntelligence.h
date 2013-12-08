//
//  MKArtificialIntelligence.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

@class MKCharacter;

@interface MKArtificialIntelligence : NSObject

@property (nonatomic, weak) MKCharacter *character;
@property (nonatomic, weak) MKCharacter *target;

- (id) initWithCharacter:(MKCharacter *)character target:(MKCharacter *)target;

- (void) clearTarget:(MKCharacter *)target;

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeInterval;

@end
