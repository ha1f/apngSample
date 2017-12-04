//
//  CGRectExtension.swift
//  apngSample
//
//  Created by ST20591 on 2017/12/04.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension CGRect {
    func withPadding(_ inset: UIEdgeInsets) -> CGRect {
        return CGRect(x: self.origin.x - inset.left,
                      y: self.origin.y - inset.top,
                      width: width + inset.left + inset.right,
                      height: height + inset.top + inset.bottom)
    }
}
