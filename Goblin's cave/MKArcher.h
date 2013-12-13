//
//  MKArcher.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKHeroCharacter.h"

@interface MKArcher : MKHeroCharacter

@property (nonatomic) SKSpriteNode *projectile;

- (id) initAtPosition:(CGPoint)position;

@end
