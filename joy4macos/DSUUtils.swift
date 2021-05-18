//
//  DSUUtils.swift
//  joy4macos
//
//  Created by Marco Dijkslag on 16/05/2021.
//

import Foundation

class DSUUtils {
    
    static public func getUInt8fromCGFloat(num: CGFloat) -> UInt8 {
        if num < 0 {
            return UInt8(bitPattern: Int8(max((num + 1) * 127, 0)))
        } else {
            return UInt8(min(num * 127 + 128, 255))
        }
    }
    
    static public func radiansToDegree(num: CGFloat) -> CGFloat {
        return num * (180.0 / CGFloat.pi)
    }
    
    static public func getUInt8arrayFromCGFloat(num: CGFloat) -> [UInt8] {
        return DSUUtils.toByteArray(Float(num))
    }
    
    static public func getTimestampUInt8array(timeStamp: UInt64) -> [UInt8] {
        return [
            UInt8(truncatingIfNeeded: timeStamp) & 0xFF,
            UInt8(truncatingIfNeeded: timeStamp >> 8) & 0xFF,
            UInt8(truncatingIfNeeded: timeStamp >> 16) & 0xFF,
            UInt8(truncatingIfNeeded: timeStamp >> 24) & 0xFF,
            UInt8(truncatingIfNeeded: timeStamp >> 32) & 0xFF,
            UInt8(truncatingIfNeeded: timeStamp >> 40) & 0xFF,
            UInt8(truncatingIfNeeded: timeStamp >> 48) & 0xFF,
            UInt8(truncatingIfNeeded: timeStamp >> 56) & 0xFF,
        ]
    }
    
    static public func toByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }
    }
}
