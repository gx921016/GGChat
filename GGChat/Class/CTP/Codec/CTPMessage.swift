//
//  CTPMessage.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/15.
//

import Foundation
public class CTPMessage{
    var uid:Int32
    var length:Int
    var body:String
    var type:CTPMsgType
    var to:Int32?
    
    init(uid:Int32,body:String,type:CTPMsgType){
        self.uid = uid
        self.body = body
        self.length = body.lengthOfBytes(using: String.Encoding.utf8)
        self.type = type
    }
    
    init(uid:Int32,body:String,to:Int32,type:CTPMsgType){
        self.uid = uid
        self.body = body
        self.length = body.lengthOfBytes(using: String.Encoding.utf8)
        self.type = .MSG
        self.to = to
    }
}


public enum CTPMsgType:Int8 {
    case MSG = 1
    case HEARBEAT = 2
    case REGISTERED = 3
    case ACK = 4
    case ERROR = 15
}
