//
//  Chunk.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

struct PngChunk {
    let length: UInt32
    let type: String
    let data: Data
    let crc: UInt32
    
    static let iend = PngChunk.create(type: .iend, data: Data())
    
    static func create(type: PngChunkType, data: Data) -> PngChunk {
        return PngChunk(length: UInt32(data.count),
                        type: type.rawValue,
                        data: data,
                        crc: calcCrc(type.rawValue, data))
    }
    
    func concated(_ other: PngChunk) -> PngChunk? {
        guard type == other.type else {
            return nil
        }
        let concatData = data + other.data
        return PngChunk(length: length + other.length, type: type, data: concatData, crc: PngChunk.calcCrc(type, concatData))
    }
    
    func verifyCrc() -> Bool {
        return crc == calcCrc()
    }
    
    func asData() -> Data {
        let bytes = length.bytes + type.utf8.bytes + data.bytes + crc.bytes
        return Data(bytes: bytes)
    }
    
    private static func calcCrc(_ type: String, _ data: Data) -> UInt32 {
        return Data(type.utf8.bytes + data.bytes).calcCrc32()
    }
    
    private func calcCrc() -> UInt32 {
        return PngChunk.calcCrc(type, data)
    }
}

/*
 IHDR 13
 acTL 8
 PLTE 297
 tRNS 19
 fcTL 26
 IDAT 3797
 fcTL 26
 fdAT 4124
 fcTL 26
 fdAT 3718
 fcTL 26
 fdAT 3226
 fcTL 26
 fdAT 3588
 fcTL 26
 fdAT 3721
 fcTL 26
 fdAT 3570
 fcTL 26
 fdAT 3621
 fcTL 26
 fdAT 3826
 fcTL 26
 fdAT 3129
 fcTL 26
 fdAT 637
 fcTL 26
 fdAT 680
 fcTL 26
 fdAT 450
 fcTL 26
 fdAT 28
 fcTL 26
 fdAT 3286
 fcTL 26
 fdAT 2907
 fcTL 26
 fdAT 2922
 fcTL 26
 fdAT 2965
 fcTL 26
 fdAT 3151
 fcTL 26
 fdAT 658
 fcTL 26
 fdAT 698
 fcTL 26
 fdAT 803
 fcTL 26
 fdAT 929
 fcTL 26
 fdAT 3502
 fcTL 26
 fdAT 3669
 fcTL 26
 fdAT 2948
 fcTL 26
 fdAT 3881
 fcTL 26
 fdAT 3902
 fcTL 26
 fdAT 3881
 fcTL 26
 fdAT 3880
 fcTL 26
 fdAT 132
 fcTL 26
 fdAT 3925
 fcTL 26
 fdAT 17
 fcTL 26
 fdAT 3881
 tEXt 27
 IEND 0
 */
