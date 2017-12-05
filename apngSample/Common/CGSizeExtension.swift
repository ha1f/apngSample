//
//  CGSizeExtension.swift
//  apngSample
//
//  Created by ST20591 on 2017/12/04.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension CGSize {
    func rectOfCenter(in container: CGRect) -> CGRect {
        return CGRect(origin: .init(x: (container.width - width) / 2, y: (container.height - height) / 2), size: self)
    }
    
    func withPadding(_ inset: UIEdgeInsets) -> CGSize {
        return CGSize(width: width + inset.left + inset.right,
                      height: height + inset.top + inset.bottom)
    }
    
    static func covering(_ sizes: [CGSize]) -> CGSize {
        return sizes.reduce(CGSize.zero, { currentMax, size in
            return CGSize(width: max(currentMax.width, size.width), height: max(currentMax.height, size.height))
        })
    }

}
