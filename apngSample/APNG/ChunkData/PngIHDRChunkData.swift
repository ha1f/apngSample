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
    
    init(width: UInt32,
         height: UInt32,
         bitDepth: UInt8,
         colorType: UInt8,
         compression: UInt8,
         filter: UInt8,
         interlace: UInt8) {
        self.width = width
        self.height = height
        self.bitDepth = bitDepth
        self.colorType = colorType
        self.compression = compression
        self.filter = filter
        self.interlace = interlace
    }
    
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
    
    func withSettingFrame(width: UInt32, height: UInt32) -> PngIHDRChunkData {
        return PngIHDRChunkData(width: width,
                                height: height,
                                bitDepth: self.bitDepth,
                                colorType: self.colorType,
                                compression: self.compression,
                                filter: self.filter,
                                interlace: self.interlace)
    }
}

extension PngIHDRChunkData: ByteArrayConvertiblesConvertible {
    var convertibles: [ByteArrayConvertible] {
        return [width, height, bitDepth, colorType, compression, filter, interlace]
    }
}
