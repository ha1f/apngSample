//
//  DataView.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

class DataView {
    private let data: Data
    private var currentIndex: Data.Index
    
    init(_ data: Data) {
        self.data = data
        self.currentIndex = data.startIndex
    }
    
    func rewind() {
        currentIndex = data.startIndex
    }
    
    private func read(_ length: Int) throws -> Data {
        guard currentIndex.distance(to: data.endIndex) >= length else {
            fatalError("tried to read out of bounds of the data")
        }
        let seekedIndex = currentIndex.advanced(by: length)
        let subdata = data.subdata(in: currentIndex..<seekedIndex)
        currentIndex = seekedIndex
        return subdata
    }
    
    func readToLast() -> Data {
        let subdata = data.subdata(in: currentIndex..<data.endIndex)
        currentIndex = data.endIndex
        return subdata
    }
    
    func readUint8() -> UInt8 {
        return try! read(1).first ?? 0
    }
    
    func readUint16() -> UInt16 {
        let value = try! read(2)
            .reduce(0) { (current, value) -> UInt16 in
                current << 8 + UInt16(value)
        }
        return value
    }
    
    func readUint32() -> UInt32 {
        let value = try! read(4)
            .reduce(0) { (current, value) -> UInt32 in
                current << 8 + UInt32(value)
        }
        return value
    }
    
    func readString(lenth: Int, encoding: String.Encoding = .ascii) -> String {
        return String(data: try! read(lenth), encoding: encoding)!
    }
    
    func readData(length: Int) -> Data {
        return try! read(length)
    }
    
    func skip(length: Int) {
        currentIndex = currentIndex.advanced(by: length)
    }
}
