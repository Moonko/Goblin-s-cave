//
//  MKEnemyCharacter.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKCharacter.h"

@class  MKArtificialIntelligence;

@interface MKEnemyCharacter : MKCharacter

@property (nonatomic) MKArtificialIntelligence *intelligence;

@end
