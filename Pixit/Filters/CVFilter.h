//
//  CVFilter.h
//  Pixit
//
//  Created by Lucky on 2019/3/27.
//  Copyright © 2019 Lucky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>


#ifdef __cplusplus

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/core/core.hpp>
using namespace cv;

#include <list>
using namespace std;

#endif

@interface CVFilter : NSObject
{
    
}

#ifdef __cplusplus
+ (void)filterBlurHomogeneous:(Mat)image with:(int)kernel_size;
+ (void)filterBlurGaussian:(Mat)image with:(int)kernel_size;
+ (void)filterBlurMedian:(Mat)image with:(int)kernel_size;
+ (void)filterBlurBilateral:(Mat)image with:(int)kernel_size;
+ (void)filterLaplace:(Mat)image with:(int)kernel_size;
+ (void)filterSobel:(Mat)image with:(int)kernel_size;
+ (void)filterCanny:(Mat)image with:(int)kernel_size andLowThreshold:(int)lowThreshold;

+ (void)filterBlurHomogeneousAccelerated:(Mat)image with:(int)kernel_size;
+ (void)filterBlurGaussianAccelerated:(Mat)image with:(int)kernel_size;
#endif


@end
