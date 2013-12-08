//
//  MKCharacter.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 25.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import "MKCharacter.h"
#import "MKCharacterScene.h"
#import "MKUtilites.h"

@interface MKCharacter ()

@property (nonatomic) SKSpriteNode *shadowBlob;

@end

@implementation MKCharacter

#pragma mark - Initialization

- (id) initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position
{
    self = [super initWithTexture:texture];
    
    if (self)
    {
        [self sharedInitAtPosition:position];
    }
    return self;
}

- (id) initWithSprites:(NSArray *)sprites atPosition:(CGPoint)position
{
    self = [super init];
    if (self)
    {
        [self sharedInitAtPosition:position];
    }
    return self;
}

- (void) sharedInitAtPosition:(CGPoint)position
{
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Environment"];
    
    _shadowBlob = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"blobShadow.png"]];
    _shadowBlob.zPosition = -1.0f;
    
    self.position = position;
    
    _health = 100.0f;
    _movementSpeed = kMovementSpeed;
    
    [self configurePhysicsBody];
}

- (void)reset
{
    self.health = 100.0f;
    self.dying = NO;
    self.attacking = NO;
    self.shadowBlob.alpha = 1.0f;
}

#pragma mark - Overriden methods

- (void) configurePhysicsBody
{
    // Overriden;
}

- (void)performAttackAction
{
    if (self.attacking)
    {
        return;
    }
    self.attacking = YES;
}

- (void) collideWith:(SKPhysicsBody *)other
{
    // Overriden
}

- (void)performDeath
{
    self.health = 0.0f;
    self.dying = YES;
}

#pragma mark - Damage

- (BOOL)applyDamage:(CGFloat)damage fromProjectile:(SKNode *)projectile
{
    return [self applyDamage:damage * projectile.alpha];
}

- (BOOL) applyDamage:(CGFloat)damage
{
    self.health -= damage;
    
    if (self.health > 0.0f)
    {
        MKCharacterScene *scene = [self characterScene];
        
        SKEmitterNode *emitter = [[self damageEmitter] copy];
        
        if (emitter)
        {
            [scene addNode:emitter
               atWorlLayer:MKWorldLayerAboveCharacter];
            emitter.position = self.position;
            MKRunOneShotEmitter(emitter, 0.15f);
        }
        
        return NO;
    }
    
    [self performDeath];
    
    return YES;
}

- (void) setScale:(CGFloat)scale
{
    [super setScale:scale];
    self.shadowBlob.scale = scale;
}

- (void) setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];
    self.shadowBlob.alpha = alpha;
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval
{
    self.shadowBlob.position = self.position;
}

- (void) fadeIn:(CGFloat)duration
{
    SKAction *fadeAction = [SKAction fadeInWithDuration:duration];
    
    self.alpha = 0.0f;
    [self runAction:fadeAction];
    
    self.shadowBlob.alpha = 0.0f;
    [self.shadowBlob runAction:fadeAction];
}

#pragma mark - Working with Scenes

- (void) addToScene:(MKCharacterScene *)scene
{
    [scene addNode:self
       atWorlLayer:MKWorldLayerCharacter];
    [scene addNode:self.shadowBlob
       atWorlLayer:MKWorldLayerBelowCharacter];
}

- (void) removeFromParent
{
    [self.shadowBlob removeFromParent];
    [super removeFromParent];
}

- (MKCharacterScene *)characterScene
{
    MKCharacterScene *scene = (id)[self scene];
    if ([scene isKindOfClass:[MKCharacterScene class]])
    {
        return scene;
    } else
    {
        return nil;
    }
}

#pragma mark - Orientation

- (CGFloat)faceTo:(CGPoint)position
{
    CGFloat ang = MK_POLAR_ADJUST(MKRadiansBetweenPoints(position, self.position));
    SKAction *action = [SKAction rotateToAngle:ang
                                      duration:0];
    [self runAction:action];
    return ang;
}

- (void) moveTowards:(CGPoint)position withTimeInterval:(NSTimeInterval)timeInterval
{
    CGPoint currentPosition = self.position;
    CGFloat dx = position.x - currentPosition.x;
    CGFloat dy = position.y - currentPosition.y;
    CGFloat dt = self.movementSpeed * timeInterval;
    
    CGFloat ang = MK_POLAR_ADJUST(MKRadiansBetweenPoints(position, currentPosition));
    self.zRotation = ang;
    
    CGFloat distRemaining = hypot(dx, dy);
    if (distRemaining < dt)
    {
        self.position = position;
    } else
    {
        self.position = CGPointMake(currentPosition.x - sinf(ang) * dt,
                                    currentPosition.y + cosf(ang) * dt);
    }
}

+ (void)loadSharedAssets
{
    // Overriden
}

- (SKEmitterNode *)damageEmitter
{
    return nil;
}

- (SKAction *)damageAction
{
    return nil;
}

@end
