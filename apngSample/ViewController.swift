//
//  ViewController.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        read()
    }

    func read() {
        guard let url = Bundle.main
            .path(forResource: "animated", ofType: "png")
            .map({ URL(fileURLWithPath: $0) }) else {
            print("Could not find image")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let pngImage = ApngImage.read(from: data)
            
            print(pngImage.defaultPngImage.debugPrint())
            
            let sampleFrame = pngImage.buildFramePng(frame: pngImage.frames[5])
            print("********sample frame*******")
            sampleFrame.debugPrint()
            
            let image = UIImage(data: sampleFrame.asData())
            let imageView = UIImageView()
            imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            imageView.image = image
            self.view.addSubview(imageView)
        } catch(let error) {
            print(error)
        }
        
    }


}

