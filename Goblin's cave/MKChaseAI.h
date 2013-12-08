//
//  MKChaseAI.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKArtificialIntelligence.h"

#define kEnemyAlertRadius (kCharacterCollisionRadius * 500)

@interface MKChaseAI : MKArtificialIntelligence

@property (nonatomic) CGFloat chaseRadius;
@property (nonatomic) CGFloat maxAlertRadius;

@end
