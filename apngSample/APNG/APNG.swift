//
//  APNG.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation
import UIKit

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
    
    func buildFramePng(frame: ApngFrame) -> ApngImage {
        let ihdr = self.ihdr!.withSettingFrame(width: frame.fctl.width, height: frame.fctl.height)
        let chunks = [
            ihdr.asPngChunk(with: .ihdr),
            self.plte?.asPngChunk(with: .plte) ?? [],
            self.chunk(with: .tRNS).map { [$0]} ?? [],
            frame.idat.asPngChunk(with: .idat)
            ].flatMap { $0 }
            + self.chunks.filter { chunk in
                PngChunkType.defaultTypes.contains(where: { chunk.type == $0.rawValue })
                    && chunk.type != PngChunkType.ihdr.rawValue
                    && chunk.type != PngChunkType.idat.rawValue
                    && chunk.type != PngChunkType.plte.rawValue
                    && chunk.type != PngChunkType.tRNS.rawValue
             }
        return ApngImage(chunks: chunks)
    }
    
    /// disposeOpには非対応
    func buildUIImage(from frame: ApngFrame) -> UIImage? {
        let apngImage = buildFramePng(frame: frame)
        let size = CGSize(width: CGFloat(self.ihdr!.width), height: CGFloat(self.ihdr!.height))
        return UIGraphicsImageRenderer(size: size).image { context in
            let frameImageOffset = CGPoint(x: CGFloat(frame.fctl.xOffset), y: CGFloat(frame.fctl.yOffset))
            let frameImageSize = CGSize(width: CGFloat(frame.fctl.width), height: CGFloat(frame.fctl.height))
            let frameImageRect = CGRect(origin: frameImageOffset, size: frameImageSize)
            apngImage.asUIImage()?.draw(in: frameImageRect)
        }
    }
    
    var isApng: Bool {
        for chunk in chunks {
            if chunk.type == PngChunkType.acTL.rawValue {
                return true
            }
            if chunk.type == PngChunkType.idat.rawValue {
                // actl must be before idat
                return false
            }
        }
        return false
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
    
    var idat: PngIdatChunkData? {
        return chunk(with: .idat).map { chunk in
            return PngIdatChunkData(chunk.data)
        }
    }
    
    var actl: PngActlChunkData? {
        return chunk(with: .acTL).map { chunk in
            return PngActlChunkData(chunk.data)
        }
    }
    
    var plte: PngPlteChunkData? {
        return chunk(with: .plte).map { chunk in
            return PngPlteChunkData(chunk.data)
        }
    }
    
    /// signatureは飛ばす
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
            
            print("verify", chunk.verifyCrc())
            
            // iDOTは無視
            if chunk.type == PngChunkType.iDOT.rawValue {
                continue
            }
            
            // 必要に応じて連結
            if chunk.type == PngChunkType.idat.rawValue && chunks.last?.type == PngChunkType.idat.rawValue {
                let oldChunk = chunks.removeLast()
                chunks.append(oldChunk.concated(with: chunk)!)
            } else if chunk.type == PngChunkType.fdAT.rawValue && chunks.last?.type == PngChunkType.fdAT.rawValue {
                let oldChunk = chunks.removeLast()
                chunks.append(oldChunk.concated(with: chunk)!)
            } else {
                chunks.append(chunk)
            }
            
            if type == PngChunkType.iend.rawValue {
                break
            }
        }
        return chunks
    }
    
    static func from(images: [UIImage]) -> ApngImage? {
        var sequenceNumber: UInt32 = 0
        guard let firstImage = images.first else {
            return nil
        }
        guard let basePngImage = from(image: firstImage) else {
            return nil
        }
        
        let actl = PngActlChunkData(numFrames: UInt32(images.count), numPlays: 0)
        
        let imageSize = CGSize.covering(images.map { $0.size })
        let imageSizeWidth = UInt32(imageSize.width)
        let imageSizeHeight = UInt32(imageSize.height)
        
        let fctl = PngFctlChunkData(sequenceNumber: sequenceNumber, width: imageSizeWidth, height: imageSizeHeight, xOffset: 0, yOffset: 0, delayNum: 1, delayDen: 2, disposeOp: PngFctlChunkData.DisposeOption.background.rawValue, blendOp: PngFctlChunkData.BlendOption.source.rawValue)
        sequenceNumber += 1
        
        var newChunks = basePngImage.chunks.filter { $0.type != PngChunkType.iend.rawValue && $0.type != PngChunkType.iDOT.rawValue }
        let additionalChunks = [actl.asPngChunk(with: .acTL), fctl.asPngChunk(with: .fcTL)].flatMap { $0 }
        newChunks.insert(contentsOf: additionalChunks, at: newChunks.index(where: { $0.type == PngChunkType.idat.rawValue })!)
        
        images.dropFirst().forEach { image in
            // delayNum/delayDen seconds
            let fctl = PngFctlChunkData(sequenceNumber: sequenceNumber, width: imageSizeWidth, height: imageSizeHeight, xOffset: 0, yOffset: 0, delayNum: 1, delayDen: 2, disposeOp: PngFctlChunkData.DisposeOption.background.rawValue, blendOp: PngFctlChunkData.BlendOption.source.rawValue)
            sequenceNumber += 1
            newChunks.append(contentsOf: fctl.asPngChunk(with: .fcTL))
            
            let fdat = from(image: image)!.idat!.asPngFdatChunkData(sequenceNumber: sequenceNumber)
            sequenceNumber += 1
            newChunks.append(contentsOf: fdat.asPngChunk(with: .fdAT))
        }
        
        newChunks.append(PngChunk.iend)
        return ApngImage(chunks: newChunks)
    }
    
    static func from(image: UIImage) -> ApngImage? {
        return UIImagePNGRepresentation(image).map { read(from: $0) }
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
    
    func asUIImage() -> UIImage? {
        return UIImage(data: asData())
    }
    
    /// 呼び出し側でキャッシュしてください
    func getFrames() -> [ApngFrame] {
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
    
}

// debug
extension ApngImage {
    func debugPrint() {
        self.chunks.forEach { chunk in
            print(chunk.type, terminator: ": ")
            switch chunk.type {
            case PngChunkType.ihdr.rawValue:
                print(PngIHDRChunkData(chunk.data))
            case PngChunkType.acTL.rawValue:
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
