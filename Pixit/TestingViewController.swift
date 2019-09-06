//
//  TestingViewController.swift
//  Pixit
//
//  Created by Lucky on 07/05/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import GPUImage

class TestingViewController: UIViewController {

    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var highVal: UISlider!
    @IBOutlet weak var lowVal: UISlider!
    
    var convertedImage = UIImage()
    var rawImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myImageView.image = convertedImage
        
    }

    @IBAction func convertImage(_ sender: Any) {
       myImageView.image = convertedImage
        
        lowVal.value = 20
        highVal.value = 110
    }
   
   
    @IBAction func upperBoundChange(_ sender: Any) {
       
        let myImage = rawImage
        
        let resultImage: UIImage = OpenCVWrapperThree.sobelFilter(myImage, lowerB: Double(lowVal.value), upperB: Double(highVal.value))
        
        let invert = ColorInversion()
        myImageView.image = resultImage.filterWithOperation(invert)

    
    }
    
    @IBAction func lowerBoundChange(_ sender: Any) {
        
        let myImage = rawImage
        
        let resultImage: UIImage = OpenCVWrapperThree.sobelFilter(myImage, lowerB: Double(lowVal.value), upperB: Double(highVal.value))
        
        let invert = ColorInversion()
        myImageView.image = resultImage.filterWithOperation(invert)
    
    }
    
    @IBAction func drawImage(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "redraw") as! DrawAdjustedImgView
        nextVC.adjustedImage = rawImage
        nextVC.lowThresh = lowVal.value
        nextVC.highThresh = highVal.value
        
        print("l \(lowVal.value), h \(highVal.value)")
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    
    
    @IBAction func goToHome(_ sender: Any) {
  navigationController?.popToRootViewController(animated: true)
    
    }
    
}
