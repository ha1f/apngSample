//
//  PngIdatChunkData.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

struct PngIdatChunkData {
    let data: Data
    
    init(_ data: Data) {
        self.data = data
    }
}

extension PngIdatChunkData: ByteArrayConvertible {
    var bytes: [UInt8] {
        return data.bytes
    }
}

extension PngIdatChunkData {
    func asPngFdatChunkData(sequenceNumber: UInt32) -> PngFdatChunkData {
        return PngFdatChunkData.init(sequenceNumber: sequenceNumber, frameData: data)
    }
}
