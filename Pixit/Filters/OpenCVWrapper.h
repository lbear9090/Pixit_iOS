//
//  OpenCVWrapper.h
//  Pixit
//
//  Created by Lucky on 18/04/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

+(UIImage *)SobelFilter:(UIImage *)image;

@end

@interface OpenCVWrapperTwo : NSObject

+(UIImage *)SobelFilter:(UIImage *)image;

@end

@interface OpenCVWrapperThree : NSObject

+(UIImage *)SobelFilter:(UIImage *)image lowerB:(double )lowerB upperB:(double )upperB;

@end

@interface OpenCVWrapperFour : NSObject

+(UIImage *)SobelFilter:(UIImage *)image lowerB:(double )lowerB upperB:(double )upperB;

@end
