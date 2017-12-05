//
//  ViewController.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    var updateTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(self.imageView)
        
        let imageSize = CGSize(width: 100, height: 100)
        
        let images = [
            UIImage.fromText(text: "1", fontSize: 100, textColor: .yellow)?.resized(to: imageSize, contentMode: .center),
            UIImage.fromText(text: "2", fontSize: 100, textColor: .cyan)?.resized(to: imageSize, contentMode: .center),
            UIImage.fromText(text: "3", fontSize: 100, textColor: .red)?.resized(to: imageSize, contentMode: .center),
            UIImage.fromText(text: "4", fontSize: 100, textColor: .green)?.resized(to: imageSize, contentMode: .center),
            UIImage.fromText(text: "5", fontSize: 100, textColor: .blue)?.resized(to: imageSize, contentMode: .center),
            UIImage.fromText(text: "6", fontSize: 100, textColor: .orange)?.resized(to: imageSize, contentMode: .center)
        ].flatMap { $0 }
        
        let data = ApngImage.from(images: images)!.asData()
        
//         let data = readApngDataFromFile()!
        
        readApngAndShow(data)
    }
    
    func readApngDataFromFile() -> Data? {
        guard let url = Bundle.main
            .path(forResource: "animated", ofType: "png")
            .map({ URL(fileURLWithPath: $0) }) else {
                print("Could not find image")
                return nil
        }
        return try? Data(contentsOf: url)
    }
    
    

    func readApngAndShow(_ data: Data) {
        let pngImage = ApngImage.read(from: data)
        pngImage.debugPrint()
        
        imageView.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat(pngImage.ihdr!.width), height: CGFloat(pngImage.ihdr!.height)))
        imageView.center = view.center
        
        let pngFrames = pngImage.getFrames()
        
        if pngImage.isApng {
            let maxCount = pngFrames.count
            var currentFrameIndex = 0
            self.updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if currentFrameIndex >= maxCount {
                    currentFrameIndex = 0
                }
                print(currentFrameIndex, pngFrames[currentFrameIndex])
                let image = pngImage.buildUIImage(from: pngFrames[currentFrameIndex])
                self.imageView.image = image
                currentFrameIndex += 1
            }
        } else {
            imageView.image = pngImage.asUIImage()
        }
    }


}

