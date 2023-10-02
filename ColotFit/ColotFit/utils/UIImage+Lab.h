//
//  ImageColoriser
//
//  Created by Maksym Shcheglov.
//  Copyright © 2021 Maksym Shcheglov. All rights reserved.
//

#ifndef UIImage_Lab_h
#define UIImage_Lab_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage(Lab)

- (NSArray<NSArray<NSNumber*>*>*)toLab;
+ (UIImage*)imageFromLab:(NSArray<NSArray<NSNumber*>*>*)lab size:(CGSize)size NS_SWIFT_NAME(image(from:size:));

@end
NS_ASSUME_NONNULL_END

#endif /* UIImage_Lab_h */
