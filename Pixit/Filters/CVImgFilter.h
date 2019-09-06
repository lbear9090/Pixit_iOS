//
//  CVImgFilter.h
//  Pixit
//
//  Created by Lucky on 2019/3/27.
//  Copyright © 2019 Lucky. All rights reserved.
//

#ifdef __cplusplus

//#include <opencv2/contrib/contrib.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/core/mat.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/opencv_modules.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/photo/photo.hpp>

#endif
#import <UIKit/UIKit.h>

#define EFFECT_PIXALIZE         0
#define EFFECT_CARTOON          1
#define EFFECT_GRAY             2
#define EFFECT_SOFTFOCUS        3
#define EFFECT_INVERSE          4
#define EFFECT_SEPIA            5
#define EFFECT_PENCILSKETCH     6
#define EFFECT_RETRO            7
#define EFFECT_FILMGRAIN        8
#define EFFECT_BINARY           9
#define EFFECT_SKETCH           10
#define EFFECT_PINHOLECAMERA    11
#define EFFECT_BRIGHTNESS       12
#define EFFECT_INPAINT          13

@interface CVImgFilter : NSObject

-(UIImage *)processImage:(UIImage *)inputImage oldImage:(UIImage *)maskImage number:(int)randomNumber sliderValueOne:(float)valueOne sliderValueTwo:(float)valueTwo;

#ifdef __cplusplus

-(cv::Mat)retroEffectConversion:(cv::Mat)inputMat;
-(cv::Mat)pinholeCameraConversion:(cv::Mat)inputMat;
-(cv::Mat)softFocusConversion:(cv::Mat)inputMat;
-(cv::Mat)cartoonMatConversion:(cv::Mat)inputMat;
-(cv::Mat)inpaintConversion:(cv::Mat)inputMat mask:(cv::Mat)maskMat;
-(cv::Mat)brightnessContrastEnhanceConversion:(cv::Mat)inputMat betaValue:(float)beta alphaValue:(float)alpha;
-(cv::Mat)pixalizeMatConversion:(cv::Mat)inputMat pixelValue:(int)pixelSize;
-(cv::Mat)binaryMatConversion:(cv::Mat)inputMat thresholdValue:(float)value;
-(cv::Mat)sketchConversion:(cv::Mat)inputMat;
-(cv::Mat)inverseMatConversion:(cv::Mat)inputMat;
-(cv::Mat)sepiaConversion:(cv::Mat)inputMat;
-(cv::Mat)pencilSketchConversion:(cv::Mat)inputMat;
-(cv::Mat)grayMatConversion:(cv::Mat)inputMat;
-(cv::Mat)filmGrainConversion:(cv::Mat)inputMat;

#endif



@end
