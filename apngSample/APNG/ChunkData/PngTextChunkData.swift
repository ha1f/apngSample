//
//  PngTextChunkData.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

struct PngTextChunkData {
    let keyword: String
    let text: String
    
    func asData() {
        // TODO: fix language code
        // keyword.utf8.bytes + [0] + text.utf8.bytes
        // String(data: <#T##Data#>, encoding: String.Encoding.isoLatin1)
    }
    
    init(_ data: Data) {
        let splitted = data.split(separator: 0, maxSplits: 1, omittingEmptySubsequences: false)
        keyword = String(data: splitted.first!, encoding: String.Encoding.ascii)!
        text = String(data: splitted.last!, encoding: String.Encoding.isoLatin1)!
    }
}
