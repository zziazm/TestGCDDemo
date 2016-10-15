//
//  untitled.h
//  HD_PingKe
//
//  Created by kevin kong  on 12-1-16.
//  Copyright 2012 DongYI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage(pirvate)
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (UIImage *)compressedImage;
- (UIImage *)compressedSmallImage ;

- (CGFloat)compressionQuality;

- (NSData *)compressedData;

- (NSData *)compressedData:(CGFloat)compressionQuality;

- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)getImageFromImage:(UIImage*)bigImage;
- (UIImage *)getRatio_One_One:(UIImage *)convertImage;
@end
