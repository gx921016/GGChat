//
//  GGChatMessage.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/19.
//

import UIKit

public class GGChatMessage {
    var direction:GGMessageDirection
    var type:GGMessageType
    var from:Int32
    var to:Int32
    var payload:String
    init(direction:GGMessageDirection,type:GGMessageType,from:Int32,to:Int32,payload:String) {
        self.direction = direction
        self.type = type
        self.from = from
        self.to = to
        self.payload = payload
    }
    
}
public enum GGMessageDirection:Int8 {
    case Send = 0
    case Receive = 1
}

public enum GGMessageType:Int8 {
    case Text = 0
    case Image = 1
    case Video = 2
    case Voice = 3
}
