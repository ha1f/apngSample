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
    
    var uint8Array: [UInt8] {
        return data.map { $0 }
    }
    
    init(_ data: Data) {
        self.data = data
        self.currentIndex = data.startIndex
    }
    
    convenience init(_ data: UInt32) {
        let bytes = (0..<4).map { i -> UInt8 in
            let shiftNum = 8*(3-i)
            return UInt8((data >> shiftNum) & 0xff)
        }
        self.init(Data(bytes))
    }
    
    func rewind() {
        currentIndex = data.startIndex
    }
    
    private func read(_ length: Int) throws -> Data {
        // TODO: check bounds
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
    
    func readUint32() -> UInt32 {
        let value = try! read(4)
            .reduce(0) { (current, value) -> UInt32 in
                current << 8 + UInt32(value)
        }
        return value
    }
    
    func readString(lenth: Int) -> String {
        let characters = try! read(lenth)
            .map { Character(UnicodeScalar($0)) }
        return String(characters)
    }
    
    func readData(length: Int) -> Data {
        return try! read(length)
    }
    
    func skip(length: Int) {
        currentIndex = currentIndex.advanced(by: length)
    }
}
