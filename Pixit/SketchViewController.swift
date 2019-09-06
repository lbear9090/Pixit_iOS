//
//  SketchViewController.swift
//  Pixit
//
//  Created by Lucky on 18/04/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import CropViewController
import ChameleonFramework
import GPUImage

class SketchViewController: UIViewController, CropViewControllerDelegate {
    
    var croppedImage = UIImage()
    var imageArray = [[UIImage]]()
    var timer : Timer?
    var timerTwo: Timer?
    var intensityValues = [Int : CGFloat]()
    var densityArray = [Int]()
    var imgToDraw = 0
    var imageDrawn = false
    var imgToSend = UIImage()
    var imgDictionary = [Int : [[UIImage]]]()
    var density = [Int]()
    var arrayOfImages = [[UIImage]]()
    var increasing = true
    var secondSplit = false
    
    @IBOutlet weak var cvFilters: UICollectionView!
    //Variables required for Vertical/Hrizontal/Diagonal drawing of images
    var a = 0
    var b = 0
    var q = 0
    var x = 0
    var k = 0
    var j = 0
    
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var adjustImageButton: UIButton!
    @IBOutlet weak var sketchView: UIView!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var cannyButton: UIButton!
    @IBOutlet weak var filterView: UIView!
    
    @IBOutlet weak var imgTest1: UIImageView!
    @IBOutlet weak var imgTest2: UIImageView!
    var imgIndex = 0
    
    @IBAction func onNext(_ sender: Any) {
        imgIndex = (imgIndex + 1) % 15
        setImage(index: imgIndex)
    }
    
    func setImage(index :Int){
        imgTest1.image = croppedImage
        let filter = CVImgFilter()
        var filteredImage = UIImage()
        var oldImage : UIImage? = nil
        var slider1 : Float = 0.0
        var slider2 : Float = 0.0
        if index < 14{
            if index == EFFECT_PIXALIZE{
                slider1 = 10.0
            }else if index == EFFECT_BINARY{
                slider1 = 128.0
            }else if index == EFFECT_BRIGHTNESS{
                slider1 = 0.3
                slider2 = 0.8
            }else if index == EFFECT_INPAINT{
                oldImage = croppedImage
            }
            filteredImage = filter.processImage(croppedImage, oldImage: oldImage, number: Int32(index), sliderValueOne: slider1, sliderValueTwo: slider2)
            imgTest2.image = filteredImage
        }else{
            let myImage = croppedImage
            let resultImage: UIImage = OpenCVWrapper.sobelFilter(myImage)
            
            let beginImage = CIImage(image: resultImage)
            
            let filter = CIFilter(name: "CIColorInvert")
            filter?.setValue(beginImage, forKey: kCIInputImageKey)
            
            imgTest2.image = convert(cmage: (filter?.outputImage!)!)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        cropImages()
        //setImage(index: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sketchView.isHidden = true
        pictureView.isHidden = false
        adjustImageButton.isHidden = true
    }
    
// MARK: -Crop and Resize Image
    
    func cropImages(){
        let cropViewController = CropViewController(image: croppedImage)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        croppedImage = image
        
        if (croppedImage.size.width > self.view.frame.size.width){
            croppedImage = resizeImage(image: croppedImage, newWidth: self.view.frame.size.width)
        } else if (croppedImage.size.height > self.view.frame.size.height)
        {
            croppedImage = resizeImageHeight(image: croppedImage, newHeight: self.view.frame.size.height)
        }
        imageViewWidth.constant = croppedImage.size.width
        imageViewHeight.constant = croppedImage.size.height
        
        pictureView.image = croppedImage
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: false, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizeImageHeight(image: UIImage, newHeight: CGFloat) -> UIImage {
        
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: -Convert Image to Sketch
    
    
    @IBAction func startSketch(_ sender: UIButton) {
 
// Step 1: Add Filters to Image
        
        let myImage = croppedImage
        let resultImage: UIImage = OpenCVWrapper.sobelFilter(myImage)
        
        let beginImage = CIImage(image: resultImage)
        
        let filter = CIFilter(name: "CIColorInvert")
        filter?.setValue(beginImage, forKey: kCIInputImageKey)
        
        imgToSend = convert(cmage: (filter?.outputImage!)!)
        
        cannyButton.isHidden = true
        sketchView.isHidden = false
        pictureView.isHidden = true
        
        splitImage(row: 160, column: 160)
        
    }
    
//Step 2 & 6: Split image into requided number of pieces
    
    func splitImage(row : Int , column : Int){
        
        //Remove previously present image pieces
        
        imageArray.removeAll()
        densityArray.removeAll()
        intensityValues.removeAll()
        
        let oImg = imgToSend
        
        //Calculate size of small image pieces
        
        let height =  (imgToSend.size.height) /  CGFloat (row)
        let width =  (imgToSend.size.width)  / CGFloat (column)
        
        //Careating smaller images and adding them to 'imageArray'
        
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
            imageArray.append(yArr)
        }
        
        
        if (imageDrawn == false){
            
        //If first phase of drawing isn't complete
            
            getImageDensity()
            addDelay()
        }
        else{
            
        //If first phase of drawing is complete move to step 7

            //For second phase we'll use 'arrayOfImages' instead of 'imageArray' and 'density' for 'densityArray'
            
            timer?.invalidate()
            getImageDensity()
            arrayOfImages = imageArray
            density = densityArray
            createDictionary()
        }
    }
    
//Step 3 & 7: Get the amount of darkness in each smaller image of 'imageArray' and store those values in 'intensityValues' dictionary
    
    func getImageDensity(){
       
        let row = imageArray.count
        let column = imageArray[0].count
        
        //Calculate image density(darkness) and store those values in 'intensityValues' dictionary
        
        for x in 0..<row{
            
            for y in 0..<column{
                
                let mkey = Int((y*1000) + x)
                
                let color = UIColor(averageColorFrom: imageArray[y][x])
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
            
            //Storing images into 'densityArray' based on increasing order of their image density
            
            if (imageDrawn == false){
               
                //In first phase, neglecting all white image pieces
                
                if (v != 7.3){
                    densityArray.append(k)
                }
            }else {
                
                // Phase 2
                    //  if (v < 7.6){
                densityArray.append(k)
            }        //    }
            //     print("\(k):\(v)")
        }
        
        //Selecting image with highest density(darkest image)
        
        imgToDraw = densityArray[0]
        
    }
    
    //Delay between drawing each part (smaller images from 'imageArray')
    
    func addDelay(){
        
        guard timer == nil else { return }
        timer =  Timer.scheduledTimer(timeInterval: TimeInterval(0.001), target: self, selector:#selector(SketchViewController.drawImage), userInfo: nil, repeats: true)
    }

//Step 4: Start drawing image
    
    @objc func drawImage(){
        
        let row = imageArray.count
        let column = imageArray[0].count
        
        let height =  (pictureView.frame.size.height) /  CGFloat (row )
        let width =  (pictureView.frame.size.width) / CGFloat (column )
        
        let testingImageView = UIImageView()
        
        
        
        if (densityArray.count > 1) {
            
            //            let checker: String = "\(intensityValues[imgToDraw]!)"
            //            if (checker == "7.3"){
            //                imgToDraw = densityArray[0]
            //            }
            
            //Remove 'imgToDraw' from 'densityArray'
            
            densityArray = densityArray.filter { $0 != imgToDraw }
            
            //If 'imgToDraw' is a all-white image, find the darkest neighbour of 'imgToDraw' from 'densityArray'
            
            let checker: String = "\(intensityValues[imgToDraw]!)"
            
            if (checker == "7.3"){
                imgToDraw = nearestNeighbour()
            }
            
            //Calculate position of 'imgToDraw', according to its origional position on unfiltered image
            
            let x = imgToDraw%1000
            let y = (imgToDraw-x)/1000
            
            testingImageView.frame = CGRect(x: CGFloat(x) * width, y: CGFloat(y) * height, width: width, height: height)
            
            testingImageView.image = self.imageArray[y][x]
            self.sketchView.addSubview(testingImageView)

            //Find all neighbouring images of current image('imgToDraw')
            
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
            
            //If all images haven't been printed and our  current image does not have any immediate neighbour
            
            if ((neighboursLeft == false)&&(densityArray.count > 1)){
                //  imgToDraw = densityArray[0]
                
                imgToDraw = nearestNeighbour()
                
            } else {
                imgToDraw = heighestIndex
            }
        } else {
            
            //All images of 'imageArray' has been drawn
            
            if (imageDrawn == false){
                
                //Phase 1 is complete, start phase 2
                
                drawOver()
            }
        }
    }
    
    // MARK: - Second drawing phase with new filter
   
//Step 5: Start second drawing phase
    
    func drawOver(){
        
        imageArray.removeAll()
        imageDrawn = true
        
        print("Start")
        let myImage = croppedImage
       
        //Apply Sobel filter to origional image
        
        let sobel = SobelEdgeDetection()
        let resultImage: UIImage = myImage.filterWithOperation(sobel)

        let invert = ColorInversion()
        imgToSend = resultImage.filterWithOperation(invert)

//        let resultImage: UIImage = OpenCVWrapperTwo.sobelFilter(myImage)
//
//        let beginImage = CIImage(image: resultImage)
//
//        let filter = CIFilter(name: "CIColorInvert")
//        filter?.setValue(beginImage, forKey: kCIInputImageKey)
//
//        imgToSend = convert(cmage: (filter?.outputImage!)!)

        //Divide Sobel-filtered image into 16 parts
        
        sketchView.isHidden = false
        pictureView.isHidden = true
        splitImage(row: 4, column: 4)
        
    }
    
//Step 8: Split 2nd phase image (1/16th of origional) in 20x20 parts
    
    func createDictionary(){
        if (q == 16){
            addSecondDelay()
            return
        }
        
        let m = density[q]%1000
        let n = (density[q] - m)/1000
        secondSplit(row: 20, column: 20, img: arrayOfImages[n][m])
        
    }
    
    //Splitting images
    
    func secondSplit(row : Int , column : Int, img : UIImage){
        
        imageArray.removeAll()
        
        let oImg = img
        
        let height =  (img.size.height) /  CGFloat (row)
        let width =  (img.size.width)  / CGFloat (column)
        
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
            imageArray.append(yArr)
        }
        imgDictionary[q] = imageArray
        q = q + 1
        
        createDictionary()
    }
    
    //Delay between drawing of second phase drawing
    
    func addSecondDelay(){
        
        guard timerTwo == nil else { return }
        timerTwo =  Timer.scheduledTimer(timeInterval: TimeInterval(0.00001), target: self, selector:#selector(SketchViewController.newDraw), userInfo: nil, repeats: true)
    }
    
//Step 9: Drawing smaller images(1/16th of the origional)
    
    @objc func newDraw(){
        
        if (x == 10){
//           adjustImageButton.isHidden = false
//           self.view.bringSubviewToFront(adjustImageButton)
        }
        if (x<16){
            imageArray = imgDictionary[x]!
        }else{
           
            //Phase 2 complete
            
            print("Done")
            timerTwo?.invalidate()
            return
        }
        
        let row = imageArray.count
        let column = imageArray[0].count
        
        let height =  (arrayOfImages[0][0].size.height) /  CGFloat (row )
        let width =  (arrayOfImages[0][0].size.width) / CGFloat (column )
        
        let testingImageView = UIImageView()
        
        // Get location
        
        let loc = density[x]
        let r = loc%1000
        let s = (loc-r)/1000
        let xLoc = (r*20)+a
        let yLoc = (s*20)+b
        
        
        testingImageView.frame = CGRect(x: CGFloat(xLoc) * width, y: CGFloat(yLoc) * height, width: width, height: height)
        
        /*
         if (x%3 == 2){
         
         //        if ((x%3 == 2)||(x%3 == 1)||(x%3 == 0)){
         
         if (a < 20){
         testingImageView.image = self.imageArray[b][a]
         self.sketchView.addSubview(testingImageView)
         }
         
         if (k < 39){
         
         if(j <= k){
         let i = k - j
         if ((i < 20) && (j < 20)){
         b = i
         a = j
         }
         j = j+1
         }else {
         j = 0
         k = k + 1
         }
         }else {
         x = x + 1
         a = 0
         b = 0
         k = 0
         j = 0
         }
         
         }  else  if (x%3 == 0){ */
        
        //   if ((x%3 == 2)||(x%3 == 1)||(x%3 == 0)){
        
        if (x%2 == 0){
            
            if (b < 20){
                
                testingImageView.image = self.imageArray[b][a]
                self.sketchView.addSubview(testingImageView)
            } else {
                x = x+1
                b = 0
                a = 0
                return
            }
            // Start
            if (b < row){
                
                if increasing == true{
                    if (a < column-1){
                        a = a+1
                    } else {
                        b = b+1
                        a = column-1
                        increasing = false
                    }
                    
                } else {
                    if (a > 0){
                        a = a-1
                    } else {
                        b = b+1
                        a = 0
                        increasing = true
                    }
                }
            }
        }  else {
            if (a < 20){
                testingImageView.image = self.imageArray[b][a]
                self.sketchView.addSubview(testingImageView)
            } else {
                x = x+1
                b = 0
                a = 0
                return
            }
            if (a < row){
                
                if increasing == true{
                    if (b < column-1){
                        b = b+1
                    } else {
                        a = a+1
                        b = column-1
                        increasing = false
                    }
                    
                } else {
                    if (b > 0){
                        b = b-1
                    } else {
                        a = a+1
                        b = 0
                        increasing = true
                    }
                }
            }
        }
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func nearestNeighbour() -> Int{
        
        var tempDistance = 10000000
        var tempNumber = 0
        
        let m = imgToDraw%1000
        let n = (imgToDraw-m)/1000
        
        for i in 0...densityArray.count-1 {

            let x = densityArray[i]%1000
            let y = (densityArray[i]-x)/1000
        
            let dist = ((x-m)*(x-m) + (y-n)*(y-n))
            
            if (dist < tempDistance){
                tempDistance = dist
                tempNumber = densityArray[i]
            }
        }
        return tempNumber
    }
    
    
    func findNeighbours(i: Int, j:  Int)-> [Int]{
        
        var neighboursArray: [Int] = []
        let rowLimit = imageArray.count-1
        let coloumnLimit = imageArray[0].count-1
        
        for x in max(0, (i-1))...min((i+1), rowLimit){
            
            for y in max(0, (j-1))...min((j+1), coloumnLimit) {
                
                if ((x != i)||(y != j)){
                    neighboursArray.append((x*1000)+y)
                }
            }
        }
        return neighboursArray
    }
    
    
    @IBAction func adjustImage(_ sender: Any) {
        
        let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "tuneImage") as! TestingViewController
        secondVC.convertedImage = imgToSend
        secondVC.rawImage = croppedImage
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
    
    @IBAction func onCloseFilter(_ sender: Any) {
        cannyButton.isHidden = false
        filterView.isHidden = true
    }
}

extension SketchViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellFilter", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
