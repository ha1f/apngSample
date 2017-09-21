//
//  PngIHDRChunkData.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

// IHDR
struct PngIHDRChunkData {
    let width: UInt32
    let height: UInt32
    let bitDepth: UInt8
    let colorType: UInt8
    let compression: UInt8
    let filter: UInt8
    let interlace: UInt8
    
    init(_ data: Data) {
        let dataView = DataView(data)
        width = dataView.readUint32()
        height = dataView.readUint32()
        bitDepth = dataView.readUint8()
        colorType = dataView.readUint8()
        compression = dataView.readUint8()
        filter = dataView.readUint8()
        interlace = dataView.readUint8()
    }
}
