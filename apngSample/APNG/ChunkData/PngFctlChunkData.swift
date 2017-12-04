//
//  PngFctlChunkData.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

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
    
    init(sequenceNumber: UInt32, width: UInt32, height: UInt32, xOffset: UInt32, yOffset: UInt32, delayNum: UInt16, delayDen: UInt16, disposeOp: UInt8, blendOp: UInt8) {
        self.sequenceNumber = sequenceNumber
        self.width = width
        self.height = height
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.delayNum = delayNum
        self.delayDen = delayDen
        self.disposeOp = disposeOp
        self.blendOp = blendOp
    }
    
    init(_ data: Data) {
        let dataView = DataView(data)
        sequenceNumber = dataView.readUint32()
        width = dataView.readUint32()
        height = dataView.readUint32()
        xOffset = dataView.readUint32()
        yOffset = dataView.readUint32()
        delayNum = dataView.readUint16()
        delayDen = dataView.readUint16()
        disposeOp = dataView.readUint8()
        blendOp = dataView.readUint8()
    }
    
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

extension PngFctlChunkData: ByteArrayConvertiblesConvertible {
    var convertibles: [ByteArrayConvertible] {
        return [sequenceNumber, width, height, xOffset, yOffset, delayNum, delayDen, disposeOp, blendOp]
    }
}
