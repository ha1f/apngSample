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
        var value = data
        self.init(Data(bytes: &value, count: 4))
    }
    
    func rewind() {
        currentIndex = data.startIndex
    }
    
    private func read(_ length: Int) -> Data {
        // TODO: check bounds
        let seekedIndex = currentIndex.advanced(by: length)
        let subdata = data.subdata(in: currentIndex..<seekedIndex)
        currentIndex = seekedIndex
        return subdata
    }
    
    func readUint8() -> UInt8 {
        return read(1).first ?? 0
    }
    
    func readUint32() -> UInt32 {
        let value = read(4)
            .reduce(0) { (current, value) -> UInt32 in
                current << 8 + UInt32(value)
        }
        return value
    }
    
    func readString(lenth: Int) -> String {
        let characters = read(lenth)
            .map { Character(UnicodeScalar($0)) }
        return String(characters)
    }
    
    func readData(length: Int) -> Data {
        return read(length)
    }
    
    func skip(length: Int) {
        currentIndex = currentIndex.advanced(by: length)
    }
}
