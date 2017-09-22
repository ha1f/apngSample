//
//  ChunkType.swift
//  apngSample
//
//  Created by ST20591 on 2017/09/21.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

enum PngChunkType: String {
    // png
    case ihdr = "IHDR"
    case plte = "PLTE"
    case idat = "IDAT"
    case iend = "IEND"
    
    // Transparency
    
    case tRNS = "tRNS"
    
    // Colour space
    case cHRM = "cHRM"
    case gAMA = "gAMA"
    case iCCP = "iCCP"
    case sBIT = "sBIT"
    case sRGB = "sRGB"
    
    // textual
    
    case iTXt = "iTXt"
    case tEXt = "tEXt"
    case zTXt = "zTXt"
    
    // Miscellaneous
    case bKGD = "bKGD"
    case hIST = "hIST"
    case pHYs = "pHYs"
    case sPLT = "sPLT"
    
    // time
    case tIME = "tIME"
    
    //
    case fRAc = "fRAc"
    case gIFg = "gIFg"
    case gIFt = "gIFt"
    case gIFx = "gIFx"
    case oFFs = "oFFs"
    case pCAL = "pCAL"
    case sCAL = "sCAL"
    
    // apng specific
    case actl = "acTL"
    case fcTL = "fcTL"
    case fdAT = "fdAT"
    
    var isDefaultType: Bool {
        return PngChunkType.defaultTypes.contains { $0.rawValue == self.rawValue }
    }
    
    static let defaultTypes: [PngChunkType] = [
        ihdr,
        plte,
        idat,
        iend,
        tRNS,
        cHRM,
        gAMA,
        iCCP,
        sBIT,
        sRGB,
        iTXt,
        tEXt,
        zTXt,
        bKGD,
        hIST,
        pHYs,
        sPLT,
        tIME
    ]
}

enum PngColorType: Int {
    case png8 = 3
    case png24 = 2
    case png32 = 6
}
