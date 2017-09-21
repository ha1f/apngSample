//
//  PngFdatChunkData.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

/// frame Data
struct PngFdatChunkData {
    let sequenceNumber: UInt32
    let frameData: Data
    
    init(_ data: Data) {
        let dataView = DataView(data)
        self.sequenceNumber = dataView.readUint32()
        self.frameData = dataView.readToLast()
    }
}
