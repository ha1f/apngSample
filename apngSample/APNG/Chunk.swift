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
    
    func verifyCrc() -> Bool {
        return crc == calcCrc()
    }
    
    func asData() -> Data {
        let bytes = length.bytes + type.utf8.map { $0 } + data.map { $0 } + crc.bytes
        return Data(bytes: bytes)
    }
    
    private func calcCrc() -> UInt32 {
        return Data(type.utf8.map { $0 } + data.map { $0 }).calcCrc32()
    }
}

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

// animation control(acTL)
struct PngActlChunkData {
    /// same as the number of fcTL chunks, != 0
    let numFrames: UInt32
    
    /// ループ回数、0なら無限
    let numPlays: UInt32
}

/// frame control(fcTL)
struct PngFctlChunkData {
    let sequenceNumber: UInt32
    let width: UInt32
    let height: UInt32
    let xOffset: UInt32
    let yOffset: UInt32
    /// 0なら最速
    let delayNum: UInt16
    /// 0なら100として扱う
    let delayDen: UInt16
    /// フレームを描画した後にフレーム領域を廃棄するか?
    let disposeOp: UInt8
    let blendOp: UInt8
    
    enum DisposeOption: UInt8 {
        /// 次のフレームを描画する前に消去しません。出力バッファをそのまま使用します。
        case none = 0
        /// 次のフレームを描画する前に、出力バッファのフレーム領域を完全に透過な黒で塗りつぶします。
        case background = 1
        /// 次のフレームを描画する前に、出力バッファのフレーム領域をこのフレームに入る前の状態に戻します。
        case previous = 2
    }
    
    enum BlendOption: UInt8 {
        /// アルファ値を含めた全ての要素をフレームの出力バッファ領域に上書きします。
        case source = 0
        /// 書き込むデータのアルファ値を使って出力バッファに合成します。このとき、PNG 仕様 への拡張 Version 1.2.0 のアルファチャンネル処理 に書いてある通り上書き処理をします。サンプルコードの 2 つ目の項目を参照してください。
        case over = 1
    }
}

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
