//
//  MKUtilites.m
//  Goblin's cave
//
//  Created by Андрей Рычков on 26.11.13.
//  Copyright (c) 2013 Андрей Рычков. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#pragma mark Loading Images

CGImageRef MKCreateCGImageFromFile(NSString *path)
{
    UIImage *uiImage = [UIImage imageWithContentsOfFile: path];
    if (!uiImage) {
        NSLog(@"UIImage imageWithContentsOfFile failed on file %@",path);
    }
    return CGImageRetain(uiImage.CGImage);
}

CGImageRef MKGetCGImageNamed(NSString *name)
{
    name = name.lastPathComponent;
    UIImage *uiImage = [UIImage imageNamed:name];
    NSCAssert1(uiImage,@"Couldn't find bundle image resource '%@'", name);
    return uiImage.CGImage;
}

#pragma mark - Bitmap Contexts

CGContextRef MKCreateARGBBitmapContext(CGImageRef inImage)
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace = NULL;
    void *bitmapData = NULL;
    int bitmapByteCount = 0;
    int bitmapBytesPerRow = 0;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (int)(pixelsWide * 4);
    bitmapByteCount = (int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL) {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate(bitmapData,
                                    pixelsWide,
                                    pixelsHigh,
                                    8,      // bits per component
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    if (context == NULL) {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // When finished, release the colorspace before returning.
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

#pragma mark - Data Maps

void* MKCreateDataMap(NSString *mapName)
{
    CGImageRef inImage = MKGetCGImageNamed(mapName);
    // Create the bitmap context.
    CGContextRef cgctx = MKCreateARGBBitmapContext(inImage);
    
    if (cgctx == NULL) {    // error creating context
        return NULL;
    }
    
    // Get image width, height. We'll use the entire image.
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap context.
    void *data = CGBitmapContextGetData(cgctx);
    
    // When finished, release the context.
    CGContextRelease(cgctx);
    
    return data;
}

#pragma mark - Point Calculations

CGFloat MKDistanceBetweenPoints(CGPoint first, CGPoint second)
{
    return hypotf(second.x - first.x, second.y - first.y);
}

CGFloat MKRadiansBetweenPoints(CGPoint first, CGPoint second)
{
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return atan2f(deltaY, deltaX);
}

CGPoint MKPointByAddingCGPoints(CGPoint first, CGPoint second)
{
    return CGPointMake(first.x + second.x, first.y + second.y);
}

#pragma mark - Loading from a Texture Atlas

NSArray *MKLoadFramesFromAtlas(NSString *atlasName, NSString *baseFileName, int numberOfFrames)
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numberOfFrames];
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:atlasName];
    for (int i = 1; i <= numberOfFrames; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%@%04d.png", baseFileName, i];
        SKTexture *texture = [atlas textureNamed:fileName];
        [frames addObject:texture];
    }
    
    return frames;
}

#pragma mark - Emitters

void MKRunOneShotEmitter(SKEmitterNode *emitter, CGFloat duration)
{
    [emitter runAction:[SKAction sequence:@[
                                            [SKAction waitForDuration:duration],
                                            [SKAction runBlock:^{
        emitter.particleBirthRate = 0;
    }],
                                            [SKAction waitForDuration:emitter.particleLifetime + emitter.particleLifetimeRange],
                                            [SKAction removeFromParent],
                                            ]]];
}



#pragma mark - NSValue Category

@implementation NSValue (MKAdventureAdditions)
- (CGPoint)apa_CGPointValue
{
    return [self CGPointValue];
}

+ (instancetype)mk_valueWithCGPoint:(CGPoint)point
{
    return [self valueWithCGPoint:point];
}
@end



#pragma mark - SKEmitterNode Category

@implementation SKEmitterNode (APAAdventureAdditions)

+ (instancetype)mk_emitterNodeWithEmitterNamed:(NSString *)emitterFileName
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]
                                                       pathForResource:emitterFileName
                                                       ofType:@"sks"]];
}

@end