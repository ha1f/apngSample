//
//  PngActlChunkData.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

// animation control(acTL)
struct PngActlChunkData {
    /// same as the number of fcTL chunks, != 0
    let numFrames: UInt32
    
    /// ループ回数、0なら無限
    let numPlays: UInt32
    
    init(_ data: Data) {
        let dataView = DataView(data)
        numFrames = dataView.readUint32()
        numPlays = dataView.readUint32()
    }
}
