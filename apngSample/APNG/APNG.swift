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

struct ApngFrame {
    let fctl: PngFctlChunkData
    let idat: PngIdatChunkData
}

/// 全てのフレームは必ずIHDRの範囲内
struct ApngImage {
    let chunks: [PngChunk]
    
    private static let signature: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
    
    static func build(ihdr: PngIHDRChunkData, plte: PngPlteChunkData, idat: PngIdatChunkData) -> ApngImage {
        return ApngImage(chunks: [ihdr.asPngChunk(with: .ihdr),
                                  plte.asPngChunk(with: .plte),
                                  idat.asPngChunk(with: .idat),
                                  PngChunk.iend])
    }
    
    func buildFramePng(frame: ApngFrame) -> ApngImage {
        return ApngImage.build(ihdr: self.ihdr!.withSettingFrame(width: frame.fctl.width, height: frame.fctl.height), plte: self.plte!, idat: frame.idat)
    }
    
    var frames: [ApngFrame] {
        var frames = [ApngFrame]()
        for (index, chunk) in chunks.enumerated() {
            if chunk.type == PngChunkType.fcTL.rawValue {
                let nextChunk = chunks[index + 1]
                if nextChunk.type == PngChunkType.idat.rawValue {
                    frames.append(ApngFrame(fctl: PngFctlChunkData(chunk.data), idat: PngIdatChunkData(nextChunk.data)))
                } else if nextChunk.type == PngChunkType.fdAT.rawValue {
                    frames.append(ApngFrame(fctl: PngFctlChunkData(chunk.data), idat: PngIdatChunkData(PngFdatChunkData(nextChunk.data).frameData)))
                }
            }
        }
        return frames
    }
    
    var defaultPngImage: ApngImage {
        let chunks = self.chunks.filter { chunk in
            PngChunkType.defaultTypes.contains { $0.rawValue == chunk.type }
        }
        return ApngImage(chunks: chunks)
    }
    
    var ihdr: PngIHDRChunkData? {
        return chunk(with: .ihdr).map { chunk in
            return PngIHDRChunkData(chunk.data)
        }
    }
    
    var actl: PngActlChunkData? {
        return chunk(with: .actl).map { chunk in
            return PngActlChunkData(chunk.data)
        }
    }
    
    var plte: PngPlteChunkData? {
        return chunk(with: .plte).map { chunk in
            return PngPlteChunkData(chunk.data)
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
    
    private func chunk(with chunkType: PngChunkType) -> PngChunk? {
        return chunks.filter { $0.type == chunkType.rawValue }.first
    }
    
    func asData() -> Data {
        let bytes = ApngImage.signature + chunks.flatMap { $0.asData().map { $0 } }
        return Data(bytes)
    }
}

// debug
extension ApngImage {
    func debugPrint() {
        self.chunks.forEach { chunk in
            print(chunk.type, terminator: ": ")
            switch chunk.type {
            case PngChunkType.ihdr.rawValue:
                print(PngIHDRChunkData(chunk.data))
            case PngChunkType.actl.rawValue:
                print(PngActlChunkData(chunk.data))
            case PngChunkType.fcTL.rawValue:
                print(PngFctlChunkData(chunk.data))
            case PngChunkType.fdAT.rawValue:
                print(PngFdatChunkData(chunk.data))
            case PngChunkType.tEXt.rawValue:
                print(PngTextChunkData(chunk.data))
            case PngChunkType.idat.rawValue:
                print(PngIdatChunkData(chunk.data))
            case PngChunkType.plte.rawValue:
                print(PngPlteChunkData(chunk.data))
            default:
                print(chunk.length)
            }
        }
    }
}
