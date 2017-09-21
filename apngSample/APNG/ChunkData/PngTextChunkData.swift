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
    
    init(_ data: Data) {
        let splitted = data.split(separator: 0, maxSplits: 1, omittingEmptySubsequences: false)
        keyword = String(data: splitted.first!, encoding: String.Encoding.isoLatin1)!
        text = String(data: splitted.last!, encoding: String.Encoding.isoLatin1)!
    }
}

extension PngTextChunkData: ByteArrayConvertible {
    var bytes: [UInt8] {
        return keyword.data(using: .isoLatin1)!.bytes + [0] + text.data(using: .isoLatin1)!.bytes
    }
}

/*
 Title    画像のタイトル
 Short (one line) title or caption for image
 Author    作者の名前
 Name of image's creator
 Description    画像の説明
 Description of image (possibly long)
 Copyright    著作権の通知
 Copyright notice
 Creation Time    画像の作成日時
 Time of original image creation
 Software    作成に使用したソフト
 Software used to create the image
 Disclaimer    公的な使用の拒否について？
 Legal disclaimer
 Warning    注意事項
 Warning of nature of content
 Source    画像の作成に用いたもの
 Device used to create the image
 Comment    雑多なコメント、例）GIFコメントからの転換
 Miscellaneous comment; conversion from GIF comment
 */
