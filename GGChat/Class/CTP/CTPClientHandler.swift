//
//  CTPClientHander.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/11.
//

import Foundation
import NIOCore
import NIOPosix
import NIOConcurrencyHelpers
public class CTPClientHandler: ChannelInboundHandler {
    public typealias InboundIn = CTPMessage
    public typealias OutboundOut = CTPMessage
    
    
    public var remoteAddress: SocketAddress?
    public var localAddress: SocketAddress?
    public var channel: Channel?
    public var context: ChannelHandlerContext?
    public var receiveData: (CTPMessage) -> ()
    public var register:CTPRegister
    
    init(receiveData: @escaping (CTPMessage) ->(),register:CTPRegister) {
        self.receiveData = receiveData
        self.register = register
        
    }
    
    
    public func channelActive(context: ChannelHandlerContext) {
        print("channelActive to \(context.remoteAddress!)localAddress\(String(describing: context.localAddress))")
        self.remoteAddress = context.remoteAddress
        self.localAddress = context.localAddress
        self.context = context
        context.writeAndFlush(self.wrapOutboundOut(CTPMessage(uid: register.uid, body: register.token, type: .REGISTERED))).whenFailure { err in
            //TODO:失败处理待定
        }
        //        self.autoLearnTimer?.resume()
        ping()
    }
    func ping(){
        self.channel?.eventLoop.scheduleTask(in: TimeAmount.seconds(60), {
            let data = CTPMessage(uid: self.register.uid, body: "", type: .HEARBEAT)
            self.channel?.writeAndFlush(self.wrapOutboundOut(data))
        }).futureResult.whenComplete({ r in
            self.ping()
        })
    }
    public func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        let state = event as! IdleStateHandler.IdleStateEvent
        
        switch state {
        case .write:
            print("write")
            break
        case .all:
            print("all")
            break
        case .read:
            print("read")
            break
        }
    }
    
    public func channelRegistered(context: ChannelHandlerContext) {
        self.channel = context.channel;
        
    }
    
    public func channelUnregistered(context: ChannelHandlerContext) {
        print("连接已断开")
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        DispatchQueue.main.async {
            let message:CTPMessage = self.unwrapInboundIn(data)
            if ((message.body.count) != 0 && message.type == .MSG){
                //回调
                self.receiveData(message)
            }
        }
    }
    
    public func channelReadComplete(context: ChannelHandlerContext) {
        //        context.flush()
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        context.close(promise: nil)
    }
    
    
    
    public func close() {
        self.context?.close(promise: nil)
    }
}
