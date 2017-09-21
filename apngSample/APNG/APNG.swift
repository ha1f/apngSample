//
//  APNG.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

struct PngImage {
    let chunks: [PngChunk]
    
    enum ChunkType: String {
        case ihdr = "IHDR"
        case actl = "acTL"
        case plte = "PLTE"
        case tRNS = "tRNS"
        case fcTL = "fcTL"
        case idat = "IDAT"
        case fdAT = "fdAT"
        case tEXt = "tEXt"
        case iend = "IEND"
    }
    
    init(chunks: [PngChunk]) {
        self.chunks = chunks
    }
    
    private static let signature: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
    
    private static func readChunks(from data: Data) -> [PngChunk] {
        let dataView = DataView(data)
        dataView.skip(length: PngImage.signature.count)
        var chunks = [PngChunk]()
        while true {
            let length = dataView.readUint32()
            let type = dataView.readString(lenth: 4)
            let data = dataView.readData(length: Int(length))
            let crc = dataView.readUint32()
            let chunk = PngChunk(length: length, type: type, data: data, crc: crc)
            chunks.append(chunk)
            if type == ChunkType.iend.rawValue {
                break
            }
        }
        return chunks
    }
    
    static func read(from data: Data) -> PngImage {
        let chunks = readChunks(from: data)
        return PngImage(chunks: chunks)
    }
    
    var ihdr: PngIHDR? {
        return chunk(with: ChunkType.ihdr.rawValue).map { chunk -> PngIHDR in
            let dataView = DataView(chunk.data)
            return PngIHDR(
                width: dataView.readUint32(),
                height: dataView.readUint32(),
                bitDepth: dataView.readUint8(),
                colorType: dataView.readUint8(),
                compression: dataView.readUint8(),
                filter: dataView.readUint8(),
                interlace: dataView.readUint8(),
                crc: dataView.readUint32())
        }
    }
    
    private func chunk(with chunkTypeString: String) -> PngChunk? {
        return chunks.filter { $0.type == chunkTypeString }.first
    }
}

enum PngColorType: Int {
    case png8 = 3
    case png24 = 2
    case png32 = 6
}

struct PngChunk {
    let length: UInt32
    let type: String
    let data: Data
    let crc: UInt32
    
    func verifyCrc() -> Bool {
        return crc == calcCrc()
    }
    
    private func calcCrc() -> UInt32 {
        return Data(type.utf8.map { $0 } + data.map { $0 }).calcCrc32()
    }
}

struct PngIHDR {
    let width: UInt32
    let height: UInt32
    let bitDepth: UInt8
    let colorType: UInt8
    let compression: UInt8
    let filter: UInt8
    let interlace: UInt8
    let crc: UInt32
}
