//
//  APNG.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation


// https://www.w3.org/TR/PNG/
// https://developer.mozilla.org/ja/docs/Animated_PNG_graphics

//

/// 全てのフレームは必ずIHDRの範囲内
struct ApngImage {
    let chunks: [PngChunk]
    
    private static let signature: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
    
    var defaultPngImage: ApngImage {
        let chunks = self.chunks.filter { chunk in
            PngChunkType.defaultTypes.contains { $0.rawValue == chunk.type }
        }
        return ApngImage(chunks: chunks)
    }
    
    var ihdr: PngIHDRChunkData? {
        return chunk(with: PngChunkType.ihdr.rawValue).map { chunk -> PngIHDRChunkData in
            return PngIHDRChunkData(chunk.data)
        }
    }
    
    private static func readChunks(from data: Data) -> [PngChunk] {
        let dataView = DataView(data)
        dataView.skip(length: ApngImage.signature.count)
        var chunks = [PngChunk]()
        while true {
            let length = dataView.readUint32()
            let type = dataView.readString(lenth: 4)
            let data = dataView.readData(length: Int(length))
            let crc = dataView.readUint32()
            let chunk = PngChunk(length: length, type: type, data: data, crc: crc)
            chunks.append(chunk)
            if type == PngChunkType.iend.rawValue {
                break
            }
        }
        return chunks
    }
    
    static func read(from data: Data) -> ApngImage {
        let chunks = readChunks(from: data)
        return ApngImage(chunks: chunks)
    }
    
    private func chunk(with chunkTypeString: String) -> PngChunk? {
        return chunks.filter { $0.type == chunkTypeString }.first
    }
    
    func asData() -> Data {
        let bytes = ApngImage.signature + chunks.flatMap { $0.asData().map { $0 } }
        return Data(bytes)
    }
    
    func debugPrint() {
        self.chunks.forEach { chunk in
            print(chunk.type, chunk.length)
        }
    }
}
