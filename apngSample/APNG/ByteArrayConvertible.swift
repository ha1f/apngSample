//
//  ByteArrayConvertible.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

protocol ByteArrayConvertiblesConvertible: ByteArrayConvertible {
    var convertibles: [ByteArrayConvertible] { get }
}

extension ByteArrayConvertiblesConvertible {
    var bytes: [UInt8] {
        return convertibles.flatMap { $0.bytes }
    }
}

protocol ByteArrayConvertible {
    var bytes: [UInt8] { get }
}

extension ByteArrayConvertible {
    func asData() -> Data {
        return Data(bytes)
    }
    
    func asPngChunk(with type: PngChunkType) -> PngChunk {
        return PngChunk.create(type: type, data: asData())
    }
}

extension String.UTF8View {
    var bytes: [UInt8] {
        return map { $0 }
    }
}

extension Data: ByteArrayConvertible {
    var bytes: [UInt8] {
        return map { $0 }
    }
}

extension UInt32: ByteArrayConvertible {
    var bytes: [UInt8] {
        return (0..<4).map { i -> UInt8 in
            let shiftNum = 8*(3-i)
            return UInt8((self >> shiftNum) & 0xff)
        }
    }
}

extension UInt16: ByteArrayConvertible {
    var bytes: [UInt8] {
        return (0..<2).map { i -> UInt8 in
            let shiftNum = 8*(1-i)
            return UInt8((self >> shiftNum) & 0xff)
        }
    }
}

extension UInt8: ByteArrayConvertible {
    var bytes: [UInt8] {
        return [self]
    }
}
