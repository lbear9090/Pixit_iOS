//
//  ViewController.swift
//  Pixit
//
//  Created by Lucky on 18/04/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit

class ViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate   {
    
    let imagePicker = UIImagePickerController()
    var pickedImage = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func openCamera(_ sender: Any) {
        
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
//                pickedImage = #imageLiteral(resourceName: "aaa.jpg")
//                let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "SketchView") as! SketchViewController
//                secondVC.croppedImage = pickedImage
//                self.navigationController?.pushViewController(secondVC, animated: true)

    }
    
    @IBAction func openGallery(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let userPickedInfo = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)]as? UIImage {
            
            pickedImage = userPickedInfo
            let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "SketchView") as! SketchViewController
            secondVC.croppedImage = pickedImage
            self.navigationController?.pushViewController(secondVC, animated: true)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
