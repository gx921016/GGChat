//
//  CTPDecode.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/12.
//

import Foundation
import NIOCore
class CTPDecode:ByteToMessageDecoder{
    typealias InboundOut = CTPMessage
    
    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        let type = buffer.readInteger(endianness: Endianness.big, as: Int8.self)
        let msgType =  CTPMsgType(rawValue: type ?? 1) ?? .MSG
        switch msgType {
        case .MSG:
            _ = buffer.readInteger(endianness: Endianness.big, as: Int32.self)
            let uid = buffer.readInteger(endianness: Endianness.big, as: Int32.self)
            let text =   buffer.readString(length: buffer.readableBytes)
            context.fireChannelRead(self.wrapInboundOut(CTPMessage.init(uid:uid ?? 0, body: text ?? "没有", type: msgType)))
        case .HEARBEAT:
            break
        case .REGISTERED:
            break
        default:
            _ = buffer.readInteger(endianness: Endianness.big, as: Int32.self)
            let uid = buffer.readInteger(endianness: Endianness.big, as: Int32.self)
            let text =   buffer.readString(length: buffer.readableBytes)
            context.fireChannelRead(self.wrapInboundOut(CTPMessage.init(uid:uid ?? 0, body: text ?? "没有", type: msgType)))
        }
        
        return .needMoreData
    }
    
    
    
    
    
    
}
