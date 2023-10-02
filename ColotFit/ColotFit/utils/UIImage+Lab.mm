//
//  ImageColoriser
//
//  Created by Maksym Shcheglov.
//  Copyright © 2021 Maksym Shcheglov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+Lab.h"
#include "lcms2.h"

struct Rgb {
    float r, g, b;
    Rgb() {}
    Rgb(float r, float g, float b) : r(r), g(g), b(b) {}
};

struct Lab {
    float l, a, b;
    Lab() {}
    Lab(float l, float a, float b) : l(l), a(a), b(b) {}
};

Lab &rgb2lab(cmsHTRANSFORM &xform, Rgb &rgbColor) {
    Lab labColor;
    float rgbValues[3];
    float labValues[3];
    rgbValues[0] = rgbColor.r / 255.0;
    rgbValues[1] = rgbColor.g / 255.0;
    rgbValues[2] = rgbColor.b / 255.0;
    cmsDoTransform(xform, rgbValues, labValues, 1);
    Lab lab = Lab(labValues[0], labValues[1], labValues[2]);
    return lab;
}

Rgb &lab2rgb(cmsHTRANSFORM &xform, Lab &labColor) {
    float rgbValues[3];
    float labValues[3];
    labValues[0] = labColor.l;
    labValues[1] = labColor.a;
    labValues[2] = labColor.b;
    cmsDoTransform(xform, labValues, rgbValues, 1);
    Rgb rgb = Rgb(rgbValues[0] * 255.0, rgbValues[1] * 255.0, rgbValues[2] * 255.0);
    return rgb;
}

@implementation UIImage (Lab)

+ (cmsHTRANSFORM)lab2rgbTransform {
    static cmsHTRANSFORM lab2rgbTransform = nil;
    if (lab2rgbTransform == nil) {
        NSString *rgbProfilePath = [[NSBundle mainBundle] pathForResource:@"sRGB_ICC_v4_Appearance.icc" ofType:nil];
        cmsHPROFILE rgbProfile = cmsOpenProfileFromFile([rgbProfilePath fileSystemRepresentation], "r");
        cmsHPROFILE labProfile = cmsCreateLab4Profile(NULL);
        lab2rgbTransform = cmsCreateTransform(labProfile, TYPE_Lab_FLT, rgbProfile, TYPE_RGB_FLT, INTENT_PERCEPTUAL, 0);
        cmsCloseProfile(labProfile);
        cmsCloseProfile(rgbProfile);
    }
    return lab2rgbTransform;
}

+ (cmsHTRANSFORM)rgb2labTransform {
    static cmsHTRANSFORM rgb2labTransform = nil;
    if (rgb2labTransform == nil) {
        NSString *rgbProfilePath = [[NSBundle mainBundle] pathForResource:@"sRGB_v4_ICC_preference.icc" ofType:nil];
        cmsHPROFILE rgbProfile = cmsOpenProfileFromFile([rgbProfilePath fileSystemRepresentation], "r");
        cmsHPROFILE labProfile = cmsCreateLab4Profile(NULL);
        rgb2labTransform = cmsCreateTransform(rgbProfile, TYPE_RGB_FLT, labProfile, TYPE_Lab_FLT, INTENT_PERCEPTUAL, 0);
        cmsCloseProfile(labProfile);
        cmsCloseProfile(rgbProfile);
    }
    return rgb2labTransform;
}

- (NSArray<NSArray<NSNumber*>*>*)toLab {
    cmsHTRANSFORM xform = [UIImage rgb2labTransform];
    CGImageRef imageRef = self.CGImage;
    NSData *data        = (NSData *)CFBridgingRelease(CGDataProviderCopyData(CGImageGetDataProvider(imageRef)));
    unsigned char *pixels = (unsigned char *)[data bytes];
    NSMutableArray* resL = [NSMutableArray new];
    NSMutableArray* resA = [NSMutableArray new];
    NSMutableArray* resB = [NSMutableArray new];
    NSUInteger step = CGImageGetBitsPerPixel(imageRef) / 8;
    for(NSUInteger i = 0; i < [data length]; i += step) {
        Rgb rgb(pixels[i], pixels[i + 1], pixels[i + 2]);
        Lab lab = rgb2lab(xform, rgb);
        [resL addObject:@(lab.l)];
        [resA addObject:@(lab.a)];
        [resB addObject:@(lab.b)];
    }
    return @[resL, resA, resB];
}

+ (UIImage*)imageFromLab:(NSArray<NSArray<NSNumber*>*>*)lab size:(CGSize)size {
    cmsHTRANSFORM xform = [UIImage lab2rgbTransform];

    NSInteger bufferSize = lab[0].count * 4;
    unsigned char *pixels = (unsigned char *)malloc(bufferSize);

    for(NSUInteger i = 0; i < size.width * size.height; i++) {
        Lab labValue(lab[0][i].doubleValue, lab[1][i].doubleValue, lab[2][i].doubleValue);
        Rgb rgb = lab2rgb(xform, labValue);

        NSUInteger offset = i * 4;
        pixels[offset]   = rgb.r;
        pixels[offset + 1]   = rgb.g;
        pixels[offset + 2]   = rgb.b;
        pixels[offset + 3]   = 255.0;
    }

    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, pixels, bufferSize, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();

    CGImageRef rgbImageRef = CGImageCreate(size.width, size.height, 8, 32, size.width * 4, colorspace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big, provider, NULL, false, kCGRenderingIntentDefault);

    UIImage *newImage   = [UIImage imageWithCGImage:rgbImageRef];

    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorspace);
    CGImageRelease(rgbImageRef);

    return newImage;
}

@end

