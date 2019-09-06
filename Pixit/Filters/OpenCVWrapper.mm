//
//  ImageProcessing.m
//  SobelEdgeApp
//
//  Created by Isao on 2016/06/25.
//  Copyright © 2016年 On The Hand. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import "Pixit-Bridging-Header.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#import <opencv2/imgcodecs/ios.h>

@implementation OpenCVWrapper: NSObject

+(UIImage *)SobelFilter:(UIImage *)image{
    
    //Convert UIImage to cv :: Mat
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    //Convert to grayscale
   cv::Mat gray;
   cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
  
    
    // Edge extraction

    cv::Mat edge;
    cv::Canny(gray, edge, 207, 210);
    //Convert cv :: Mat to UIImage
    UIImage *result = MatToUIImage(edge);
    return result;
}
@end

@implementation OpenCVWrapperTwo: NSObject

+(UIImage *)SobelFilter:(UIImage *)image{
    
    //UIImageをcv::Matに変換
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    //グレースケールに変換
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    
    // エッジ抽出
    cv::Mat edge;
    cv::Canny(gray, edge, 20, 110);
    //cv::Mat を UIImage に変換
    UIImage *result = MatToUIImage(edge);
    return result;
}
@end

@implementation OpenCVWrapperThree: NSObject

+(UIImage *)SobelFilter:(UIImage *)image lowerB: (double )lowerB upperB: (double )upperB{
    
    //UIImageをcv::Matに変換

    cv::Mat mat;
    UIImageToMat(image, mat);
    
    //グレースケールに変換
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    // エッジ抽出
    cv::Mat edge;
    cv::Canny(gray, edge, lowerB, upperB);
    //cv::Mat を UIImage に変換

    UIImage *result = MatToUIImage(edge);
    return result;
}
@end



@implementation OpenCVWrapperFour: NSObject

+(UIImage *)SobelFilter:(UIImage *)image lowerB: (double )lowerB upperB: (double )upperB{
    
    //UIImageをcv::Matに変換
    
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    //グレースケールに変換
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    // エッジ抽出
    cv::Mat edge;
    cv::Canny(gray, edge, lowerB, upperB);
    //cv::Mat を UIImage に変換

    cv::Mat ouImg;
    cv::threshold (edge, ouImg, lowerB, upperB, cv::THRESH_BINARY_INV);

    cv::Mat abc;
    cv::cvtColor(gray, abc, cv::COLOR_GRAY2BGR);

    
    UIImage *result = MatToUIImage(abc);
    return result;
}
@end



