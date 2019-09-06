//
//  DrawAdjustedImgView.swift
//  Pixit
//
//  Created by Lucky on 11/05/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit

class DrawAdjustedImgView: UIViewController {

    var adjustedImage = UIImage()
    
    var imageArr = [[UIImage]]()
    var timer : Timer?
    var intensityValues = [Int : CGFloat]()
    var densityArray = [Int]()
    var abc = 0
    var timeDaley = 0.0
    var imageDrawn = false
    var imgToSend = UIImage()
    var lowThresh = Float()
    var highThresh = Float()
    
    @IBOutlet weak var sketchView: UIView!
    @IBOutlet weak var goHomeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
      //  goHomeButton.isHidden = true
        drawFirstImage()
    }
    
    func drawFirstImage(){
   
        timeDaley = 0.01
    
    let myImage = adjustedImage
    let resultImage: UIImage = OpenCVWrapper.sobelFilter(myImage)
      //  let resultImage: UIImage = OpenCVWrapperThree.sobelFilter(myImage, lowerB: Double(lowThresh),upperB: Double(highThresh))

    let beginImage = CIImage(image: resultImage)
    
    let filter = CIFilter(name: "CIColorInvert")
    filter?.setValue(beginImage, forKey: kCIInputImageKey)
    
    imgToSend = convert(cmage: (filter?.outputImage!)!)
    
    sketchView.isHidden = false
    splitImage(row: 80, column: 80)
    
    }
    
    func drawOver(){
        
        imageArr.removeAll()
        timeDaley = 0.001
        imageDrawn = true
        
        print("Start")
        
        print("lowerB \(lowThresh), highb \(highThresh)")
        let myImage = adjustedImage
        let resultImage: UIImage = OpenCVWrapperThree.sobelFilter(myImage, lowerB: Double(lowThresh),upperB: Double(highThresh))
        
        let beginImage = CIImage(image: resultImage)
        
        let filter = CIFilter(name: "CIColorInvert")
        filter?.setValue(beginImage, forKey: kCIInputImageKey)
        
        imgToSend = convert(cmage: (filter?.outputImage!)!)
        
        sketchView.isHidden = false
        splitImage(row: 80, column: 80)
        
    }
    
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    
    func splitImage(row : Int , column : Int){
        
        let oImg = imgToSend
        
        let height =  (imgToSend.size.height) /  CGFloat (row)
        let width =  (imgToSend.size.width)  / CGFloat (column)
        
        for y in 0..<row{
            var yArr = [UIImage]()
            
            for x in 0..<column{
                
                UIGraphicsBeginImageContextWithOptions(
                    CGSize(width:width, height:height),
                    false, 0)
                
                let i =  oImg.cgImage?.cropping(to:  CGRect.init(x: CGFloat(x) * width , y:  CGFloat(y) * height  , width: width  , height: height) )
                
                let newImg = UIImage.init(cgImage: i!)
                
                yArr.append(newImg)
                
                UIGraphicsEndImageContext();
            }
            imageArr.append(yArr)
        }
        
        print("Splitting done!")
        
        getImageDensity()
        
        addDelay()
    }
    
    func addDelay(){
        
        guard timer == nil else { return }
        
        timer =  Timer.scheduledTimer(timeInterval: TimeInterval(timeDaley), target: self, selector:#selector(SketchViewController.drawImage), userInfo: nil, repeats: true)
        
        
    }
    
  
   
    
    //MARK: -Get Image Density
    
    func getImageDensity(){
        let row = imageArr.count
        let column = imageArr[0].count
        
        for x in 0..<row{
            
            for y in 0..<column{
                
                let mkey = Int((y*1000) + x)
                
                let color = UIColor(averageColorFrom: imageArr[y][x])
                let r = CIColor(color: color).red
                let g = CIColor(color: color).green
                let b = CIColor(color: color).blue
                let avg = (r+g+b)
                
                let mval = (10.0 - avg)
                
                intensityValues[mkey] = mval
            }
        }
        //Sort Dictionary
        
        for (k,v) in (Array(intensityValues).sorted {$0.1 > $1.1}) {
            
           
                
                if (imageDrawn == false){
                    if (v != 7.3){
                        densityArray.append(k)
                    }
                }else {
                    densityArray.append(k)
                }
                //     print("\(k):\(v)")
            
        }
        abc = densityArray[0]
        
    }
    
    //MARK: -Join Image
    
    
    @objc func drawImage(){
        
        let row = imageArr.count
        let column = imageArr[0].count
        
        let height =  (adjustedImage.size.height) /  CGFloat (row )
        let width =  (adjustedImage.size.width) / CGFloat (column )
        
        let testingImageView = UIImageView()
        
        if (densityArray.count > 0) {
            
            let checker: String = "\(intensityValues[abc]!)"
            if (checker == "7.3"){
                // abc = createNewArray(point: abc)
                abc = densityArray[0]
            }
            
            densityArray = densityArray.filter { $0 != abc }
            
            let x = abc%1000
            let y = (abc-x)/1000
            
            testingImageView.frame = CGRect(x: CGFloat(x) * width, y: CGFloat(y) * height, width: width, height: height)
            
            testingImageView.image = self.imageArr[y][x]
            self.sketchView.addSubview(testingImageView)
            
            //Finding Neighbours
            
            var nebs = findNeighbours(i: y, j: x)
            
            //Finding darkest images from neighbours
            
            var heighest = CGFloat()
            var heighestIndex = 0
            var neighboursLeft = false
            
            for i in 0...(nebs.count-1){
                
                if((heighest < self.intensityValues[nebs[i]]!)&&(densityArray.contains(nebs[i]))){
                    heighest = self.intensityValues[nebs[i]]!
                    heighestIndex = nebs[i]
                    neighboursLeft = true
                }else {
                }
            }
            
            if ((neighboursLeft == false)&&(densityArray.count > 1)){
                //   print("Next for \(abc) is \(createNewArray(point: heighestIndex))")
                abc = densityArray[0]
                
            } else {
                abc = heighestIndex
            }
            
        } else {
            if (imageDrawn == false){
                drawOver()
            }
           
        }
        
        let imgsDrawn = ((densityArray.count)/100)*90
        
        if ((imageDrawn == true)&&(densityArray.count == imgsDrawn)){
            print("Done")

            goHomeButton.isHidden = false
            
            guard timer != nil else { return }
            timer?.invalidate()
            timer = nil
        }
        
    }
    
    
    func findNeighbours(i: Int, j:  Int)-> [Int]{
        
        var neighboursArray: [Int] = []
        let rowLimit = imageArr.count-1
        let coloumnLimit = imageArr[0].count-1
        
        for x in max(0, (i-1))...min((i+1), rowLimit){
            
            for y in max(0, (j-1))...min((j+1), coloumnLimit) {
                
                if ((x != i)||(y != j)){
                    neighboursArray.append((x*1000)+y)
                }
            }
        }
        return neighboursArray
    }
    
    func createNewArray(point: Int)-> Int{
        var abc : [Int] = densityArray.filter { $0 != point }
        
        if abc.count < 1 {
            return point
        }
        else{
            let n = point%1000
            let m = (point-n)/1000
            var number = 0
            
            for i in 0...abc.count-1{
                let x = abc[i]%1000
                let y = (abc[i]-x)/1000
                
                let o = (x - n)*(x - n)
                let p = (y - m)*(y - m)
                
                if(o+p < x+y){
                    number = abc[i]
                    
                }
            }
            
            return number
        }
    }
    
    @IBAction func goHome(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    
    }
    
    
    
}
