//
//  ViewController.swift
//  BlurImageFilterSample
//
//  Created by Justin Sato on 2020/05/07.
//  Copyright © 2020 justin. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyingGaussianBlur()
    }

    private func applyingGaussianBlur() {
        guard
            let ciImage = CIImage(image: UIImage(named: "coco_singing")!)
        else {
            return
        }
        // Due to Core Image's coordinate system mismatch with UIKit, this filtering approach may yield unexpected results when displayed in a UIImageView with contentMode. Be sure to back it with a cgImage so that it handles contentMode properly.
        // https://developer.apple.com/documentation/coreimage/ciimage/1437833-cropped
        
        let resultImage = ciImage.applyingGaussianBlur(sigma: 5)
        let croppedImage = resultImage.cropped(to: ciImage.extent)
        self.imageView.image = UIImage(ciImage: croppedImage)
        
        
    }

}

