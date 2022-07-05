//
//  CTPClient.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/12.
//

import Foundation
import UIKit
import NIOCore
class CTPClient{
    private var serverAddress:String
    public var register:CTPRegister
    private var handler:CTPClientHandler?
    var timer: Timer?
    init(serverAddress:String,register: CTPRegister){
        self.serverAddress = serverAddress
        self.register = register
        connect(register: register)
    }
    
    private func connect(register:CTPRegister){
        ConnectManager.shared.connect(serverAddress: serverAddress, register: register)
    }
    
    private func getHandler()->CTPClientHandler{
        return ConnectManager.shared.chooseHandler()
    }
    
    public func receiveData(receiveCallback: @escaping (CTPMessage) ->()){
        let handler =  self.getHandler()
        handler.receiveData = receiveCallback
    }
    
    public func sendMsg(to:Int32,text:String,success:@escaping (CTPMessage)->()){
        let msg = CTPMessage(uid: self.register.uid, body: text ,to: to,type: .MSG)
        let handler =  self.getHandler()
        try? handler.channel?.writeAndFlush(handler.wrapOutboundOut(msg)).wait()
        print(msg.body)
        
        DispatchQueue.main.async {
            success(msg)
        }
        
        
        
    }
    
    
    public func close(){
        ConnectManager.shared.stop()
    }
}
