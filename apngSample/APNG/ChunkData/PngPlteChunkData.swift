//
//  PngPlteChunkData.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/22.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

struct PngPlteChunkData {
    let palettes: [UInt8]
    
    init(_ data: Data) {
        palettes = data.map { $0 }
    }
}

extension PngPlteChunkData: ByteArrayConvertible {
    var bytes: [UInt8] {
        return palettes
    }
}
