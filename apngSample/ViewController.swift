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
        
        // readApngAndShow()
        imageView.frame = view.bounds
        imageView.animationImages = [
            UIImage.fromText(text: "1", fontSize: 50, textColor: .yellow),
            UIImage.fromText(text: "2", fontSize: 50, textColor: .cyan),
            UIImage.fromText(text: "3", fontSize: 50, textColor: .red),
            UIImage.fromText(text: "4", fontSize: 50, textColor: .green),
            UIImage.fromText(text: "5", fontSize: 50, textColor: .blue),
            UIImage.fromText(text: "6", fontSize: 50, textColor: .orange)
            ]
            .flatMap { $0 }
        imageView.animationDuration = 0.5 * 6
        imageView.startAnimating()
    }

    func readApngAndShow() {
        guard let url = Bundle.main
            .path(forResource: "animated", ofType: "png")
            .map({ URL(fileURLWithPath: $0) }) else {
            print("Could not find image")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let pngImage = ApngImage.read(from: data)
            imageView.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat(pngImage.ihdr!.width), height: CGFloat(pngImage.ihdr!.height)))
            
            let maxCount = pngImage.frames.count
            var currentFrameIndex = 0
            self.updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if currentFrameIndex >= maxCount {
                    currentFrameIndex = 0
                }
                let image = pngImage.buildUIImage(from: pngImage.frames[currentFrameIndex])
                self.imageView.image = image
                currentFrameIndex += 1
            }
        } catch(let error) {
            print(error)
        }
        
    }


}

