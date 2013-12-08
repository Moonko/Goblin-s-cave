//
//  MKTree.h
//  Goblin's cave
//
//  Created by Андрей Рычков on 24.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define kOpaqueDistance 400

@class MKCharacterScene;

@interface MKTree : SKSpriteNode

@property (nonatomic) BOOL fadeAlpha;

- (void) updateAlphaWithScene:(MKCharacterScene *)scene;

- (id) initWithSprites:(NSArray *)sprites;

@end
