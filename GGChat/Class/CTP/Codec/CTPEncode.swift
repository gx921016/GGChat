//
//  CTPEncode.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/12.
//

import Foundation
import NIOCore

public class CTPEncode:MessageToByteEncoder{
    
    public typealias OutboundIn = CTPMessage
    
    public func encode(data: CTPMessage, out: inout ByteBuffer) throws {
        print(data)
        out.writeInteger(data.type.rawValue, endianness: Endianness.big, as: Int8.self)
        switch data.type {
        case .REGISTERED:
            out.writeInteger(Int32(data.length), endianness: Endianness.big, as: Int32.self)
            out.writeInteger(data.uid, endianness: Endianness.big, as: Int32.self)
            out.writeString(data.body)
            break
        case .MSG:
            out.writeInteger(Int32(data.length), endianness: Endianness.big, as: Int32.self)
            out.writeInteger(Int32(data.to!), endianness: Endianness.big, as: Int32.self)
            out.writeInteger(Int32(data.uid), endianness: Endianness.big, as: Int32.self)
            out.writeString(data.body)
            
            break
        case .HEARBEAT:
            out.writeInteger(Int32(data.length), endianness: Endianness.big, as: Int32.self)
            out.writeInteger(data.uid, endianness: Endianness.big, as: Int32.self)
            out.writeString(data.body)
            break
        case .ACK:
            out.writeInteger(Int32(data.length), endianness: Endianness.big, as: Int32.self)
            out.writeInteger(data.uid, endianness: Endianness.big, as: Int32.self)
            out.writeString(data.body)
            break
        case .ERROR:
            break
        }
    }
}
