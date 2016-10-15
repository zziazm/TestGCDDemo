//
//  untitled.m
//  HD_PingKe
//
//  Created by kevin kong  on 12-1-16.
//  Copyright 2012 DongYI. All rights reserved.
//

#import "UIImage+Scale.h"
#define HDPK_MAJORIZATION_INDEX_IMAGE_BROWSER_LOGIC 1

//#define MAX_IMAGEPIX          600.0
//#define SMALL_IMAGEPIX       240.0 
#define MAX_IMAGEPIX          600.0
#define SMALL_IMAGEPIX       240.0 
@implementation UIImage(pirvate)

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

-(UIImage *)imageAtRect:(CGRect)rect
{
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
	UIImage* subImage = [UIImage imageWithCGImage: imageRef];
	CGImageRelease(imageRef);
	
	return subImage;
	
}

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize {
	
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
		
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;
		
		if (widthFactor > heightFactor) 
			scaleFactor = widthFactor;
		else
			scaleFactor = heightFactor;
		
		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;
		
		// center the image
		
		if (widthFactor > heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		} else if (widthFactor < heightFactor) {
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}
	}
	
	
	// this is actually the interesting part:
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) NSLog(@"could not scale image");
	
	
	return newImage ;
}


- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
	
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
		
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;
		
		if (widthFactor < heightFactor) 
			scaleFactor = widthFactor;
		else
			scaleFactor = heightFactor;
		
		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;
		
		// center the image
		
		if (widthFactor < heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		} else if (widthFactor > heightFactor) {
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}
	}
	
	
	// this is actually the interesting part:
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) NSLog(@"could not scale image");
	
	
	return newImage ;
}


- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
	
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	
	//   CGSize imageSize = sourceImage.size;
	//   CGFloat width = imageSize.width;
	//   CGFloat height = imageSize.height;
	
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	
	//   CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	// this is actually the interesting part:
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if(newImage == nil) NSLog(@"could not scale image");
	
	
	return newImage ;
}


- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
	return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees 
{   
	// calculate the size of the rotated view's containing box for our drawing space
	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
	CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
//	[rotatedViewBox release];
	
	// Create the bitmap context
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	//   // Rotate the image context
	CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
	
}


- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;       
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }       
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}
//- (UIImage *)compressedSmallImage {
//	
//	CGSize imageSize = self.size;
//	
//    CGFloat width = imageSize.width;
//	
//    CGFloat height = imageSize.height;
//	
//	
//	if (width <= SMALL_IMAGEPIX && height<= SMALL_IMAGEPIX) {
//		
//		// no need to compress.
//		
//		return self;
//		
//	}
//	
//	
//	if (width == 0 || height == 0) {
//		
//		// void zero exception
//		
//		return self;
//		
//	}
//	
//	
//    UIImage *newImage = nil;
//	
//	CGFloat widthFactor = SMALL_IMAGEPIX / width;
//	
//	CGFloat heightFactor = SMALL_IMAGEPIX / height;
//	
//	CGFloat scaleFactor = 0.0;
//	
//	if (widthFactor > heightFactor)
//		
//		scaleFactor = heightFactor; // scale to fit height
//	
//	else
//		
//		scaleFactor = widthFactor; // scale to fit width
//	
//	CGFloat scaledWidth  = width * scaleFactor;
//	
//	CGFloat scaledHeight = height * scaleFactor;
//	
//	
//	CGSize targetSize = CGSizeMake(scaledWidth, scaledHeight);
//	
//	
//	
//    UIGraphicsBeginImageContext(targetSize); // this will crop
//	
//	
//	
//    CGRect thumbnailRect = CGRectZero;
//	
//    thumbnailRect.size.width  = scaledWidth;
//	
//    thumbnailRect.size.height = scaledHeight;
//	
//	
//	
//    [self drawInRect:thumbnailRect];
//	
//	
//	
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//	
//	
//    //pop the context to get back to the default
//	
//    UIGraphicsEndImageContext();
//	
//    return newImage;
//	
//}


//- (UIImage *)compressedImage {
//	
//	CGSize imageSize = self.size;
//	
//    CGFloat width = imageSize.width;
//	
//    CGFloat height = imageSize.height;
//	
//	
//	if (width <= MAX_IMAGEPIX && height<= MAX_IMAGEPIX) {
//		
//		// no need to compress.
//		
//		return self;
//		
//	}
//	
//	
//	if (width == 0 || height == 0) {
//		
//		// void zero exception
//		
//		return self;
//		
//	}
//	
//	
//    UIImage *newImage = nil;
//	
//	CGFloat widthFactor = MAX_IMAGEPIX / width;
//	
//	CGFloat heightFactor = MAX_IMAGEPIX / height;
//	
//	CGFloat scaleFactor = 0.0;
//	
//	if (widthFactor > heightFactor)
//		
//		scaleFactor = heightFactor; // scale to fit height
//	
//	else
//		
//		scaleFactor = widthFactor; // scale to fit width
//	
//	CGFloat scaledWidth  = width * scaleFactor;
//	
//	CGFloat scaledHeight = height * scaleFactor;
//	
//	
//	CGSize targetSize = CGSizeMake(scaledWidth, scaledHeight);
//	
//	
//	
//    UIGraphicsBeginImageContext(targetSize); // this will crop
//	
//	
//	
//    CGRect thumbnailRect = CGRectZero;
//	
//    thumbnailRect.size.width  = scaledWidth;
//	
//    thumbnailRect.size.height = scaledHeight;
//	
//	
//	
//    [self drawInRect:thumbnailRect];
//	
//	
//	
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//	
//	
//    //pop the context to get back to the default
//	
//    UIGraphicsEndImageContext();
//	
//    return newImage;
//	
//}



- (NSData *)compressedData:(CGFloat)compressionQuality {
	
	assert(compressionQuality<=1.0 && compressionQuality >=0);
	
	return UIImageJPEGRepresentation(self, compressionQuality);
	
}



- (CGFloat)compressionQuality {
	
	NSData *data = UIImageJPEGRepresentation(self, 1.0);
	
	NSUInteger dataLength = [data length];
	
	if(dataLength>50000.0) 
	{
		// 5K
		return 1.0-50000.0/dataLength;
		
	} else {
		
		return 1.0;
		
	}
	
}



- (NSData *)compressedData {
	
	CGFloat quality = [self compressionQuality];
	
	return [self compressedData:quality];
	
}
- (UIImage *)compressedImage {  
    CGSize imageSize = self.size;  
    CGFloat width = imageSize.width;  
    CGFloat height = imageSize.height;  
	
    if (width <= MAX_IMAGEPIX && height <= MAX_IMAGEPIX) {  
        // no need to compress.  
        return self;  
    }  
	
    if (width == 0 || height == 0) {  
        // void zero exception  
        return self;  
    }  
	
    UIImage *newImage = nil;  
    CGFloat widthFactor = MAX_IMAGEPIX / width;  
    CGFloat heightFactor = MAX_IMAGEPIX / height;  
    CGFloat scaleFactor = 0.0;  
	
    if (widthFactor > heightFactor)  
        scaleFactor = heightFactor; // scale to fit height  
    else  
        scaleFactor = widthFactor; // scale to fit width  
	
    CGFloat scaledWidth  = width * scaleFactor;  
    CGFloat scaledHeight = height * scaleFactor;  
    CGSize targetSize = CGSizeMake(scaledWidth - 1, scaledHeight - 1);  
	
    UIGraphicsBeginImageContext(targetSize); // this will crop  
	
    CGRect thumbnailRect = CGRectZero;  
    thumbnailRect.size.width  = scaledWidth;  
    thumbnailRect.size.height = scaledHeight;  
	
    [self drawInRect:thumbnailRect];  
	
    newImage = UIGraphicsGetImageFromCurrentImageContext();  
	
    //pop the context to get back to the default  
    UIGraphicsEndImageContext();  
	
    return newImage;  
	
}  
- (UIImage *)compressedSmallImage 
{
	CGSize imageSize = self.size;  
    CGFloat width = imageSize.width;  
    CGFloat height = imageSize.height;  
	
    if (width <= SMALL_IMAGEPIX && height <= SMALL_IMAGEPIX) {  
        // no need to compress.  
        return self;  
    }  
	
	
    if (width == 0 || height == 0) {  
        // void zero exception  
        return self;  
    }  
	
    UIImage *newImage = nil;  
    CGFloat widthFactor = SMALL_IMAGEPIX / width;  
    CGFloat heightFactor = SMALL_IMAGEPIX / height;  
    CGFloat scaleFactor = 0.0;  
	
    if (widthFactor > heightFactor)  
        scaleFactor = heightFactor; // scale to fit height  
    else  
        scaleFactor = widthFactor; // scale to fit width  
	
    CGFloat scaledWidth  = width * scaleFactor;  
    CGFloat scaledHeight = height * scaleFactor;  
    CGSize targetSize = CGSizeMake(scaledWidth - 1, scaledHeight - 1);  
	
    UIGraphicsBeginImageContext(targetSize); // this will crop  
	
    CGRect thumbnailRect = CGRectZero;  
    thumbnailRect.size.width  = scaledWidth;  
    thumbnailRect.size.height = scaledHeight;  
	
    [self drawInRect:thumbnailRect];  
	
    newImage = UIGraphicsGetImageFromCurrentImageContext();  
	
    //pop the context to get back to the default  
    UIGraphicsEndImageContext();  
	
    return newImage;  
}
- (UIImage *)getImageFromImage:(UIImage*)bigImage
{
	
	CGSize targetSize = CGSizeMake(bigImage.size.width/8,  bigImage.size.height/8);
    UIImage *sourceImage = bigImage;
    UIImage *newImage = nil;      
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.4;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.4;
            }
    }      
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
	
}
- (UIImage *) scaleProportionalToSize: (CGSize)size1
{
    if(self.size.width>self.size.height)
    {
        NSLog(@"LandScape");
        size1=CGSizeMake((self.size.width/self.size.height)*size1.height,size1.height);
    }
    else
    {
        NSLog(@"Potrait");
        size1=CGSizeMake(size1.width,(self.size.height/self.size.width)*size1.width);
    }
	
    return [self scaleToSize:size1];
}

- (UIImage *) scaleToSize: (CGSize)size
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
	
    if(self.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), self.CGImage);
    }
    else
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
	
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
	
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
	
    UIImage *image = [UIImage imageWithCGImage: scaledImage];
	
    CGImageRelease(scaledImage);
	
    return image;
}

-(UIImage*)getSubImage:(CGRect)rect  
{  
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);  
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));  
	
    UIGraphicsBeginImageContext(smallBounds.size);  
    CGContextRef context = UIGraphicsGetCurrentContext();  
    CGContextDrawImage(context, smallBounds, subImageRef);  
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];  
    UIGraphicsEndImageContext();  
	
    return smallImage;  
}  

-(UIImage *)getRatio_One_One:(UIImage *)convertImage{
	if (convertImage==nil) 
		return nil;

	CGSize imageSize = convertImage.size;
	if (imageSize.width==imageSize.height) {
		return convertImage;
	}
	float minValue = MIN(imageSize.width,imageSize.height);
	CGRect newFrame = CGRectZero;
	newFrame.origin.x = (imageSize.width-minValue)/2.0;
	newFrame.origin.y = (imageSize.height-minValue)/2.0;
	newFrame.size.width = newFrame.size.height = minValue;

#if HDPK_MAJORIZATION_INDEX_IMAGE_BROWSER_LOGIC
	return [self getSubImage:newFrame];
#else	
	return [convertImage getSubImage:newFrame];
#endif
}

+(UIImage*)compressImageDownToPhoneScreenSize:(UIImage*)theImage{
	
	UIImage * bigImage = theImage;
	
	float actualHeight = bigImage.size.height;
	float actualWidth = bigImage.size.width;
	
	float imgRatio = actualWidth / actualHeight;
	float maxRatio = 480.0 / 640;
	
	if( imgRatio != maxRatio ){
		if(imgRatio < maxRatio){
			imgRatio = 480.0 / actualHeight;
			actualWidth = imgRatio * actualWidth;
			actualHeight = 480.0;
			
		} else {
			imgRatio = 320.0 / actualWidth;
			actualHeight = imgRatio * actualHeight; 
			actualWidth = 320.0;
		}
		
	}
	
	
	CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
	UIGraphicsBeginImageContext(rect.size);
	[bigImage drawInRect:rect]; // scales image to rect
	theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//RETURN
	return theImage;
	
}
@end
