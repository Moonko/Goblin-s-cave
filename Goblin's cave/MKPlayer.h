//
//  MKPlayer.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

@class MKHeroCharacter;

#define kStartLives 3

@interface MKPlayer : NSObject

@property (nonatomic) MKHeroCharacter *hero;
@property (nonatomic) Class heroClass;

@property (nonatomic) BOOL fireAction;

@property (nonatomic) uint8_t livesLeft;
@property (nonatomic) uint32_t score;

@property (nonatomic) UITouch *movementTouch;
@property (nonatomic) CGPoint targetLocation;
@property (nonatomic) BOOL moveRequested;

@end
