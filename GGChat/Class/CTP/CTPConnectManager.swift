//
//  CTPConnectManager.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/11.
//

import Foundation
import UIKit
import NIOCore
import NIOPosix
import Atomics
public class ConnectManager {
    
    static let shared = ConnectManager()
    var timeOut = 60
    let threadPool = NIOThreadPool(numberOfThreads: 6)
    var connectedHandlerMap: Dictionary<SocketAddress, CTPClientHandler> = [:]
    var connectedHandlerArray:Array<CTPClientHandler> = []
    let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    let connectedCondition = NSCondition()
    let handlerIndex = ManagedAtomic<Int>(0)
    private let syncQueue = DispatchQueue(label: "Sync Queue",
                                          qos: .default,
                                          attributes: .concurrent,
                                          autoreleaseFrequency: .inherit,
                                          target: nil)
    
    private var channelFuture: EventLoopFuture<Channel>?
    
    private var isRunning = true
    
    
    private init() {
        threadPool.start()//启动线程池
        
    }
    
    public func connect(serverAddress: String, register:CTPRegister) {
        let addServerList = serverAddress.split(separator: ",")
        threadPool.start()
        updateConnectedServer(serverList: addServerList,register: register)
    }
    
    private func updateConnectedServer(serverList: Array<Substring>,register:CTPRegister) {
        if (serverList.count != 0) {
            
            var newAllServer = Set<SocketAddress>();
            serverList.forEach { serverAddre in
                let addressArr = serverAddre.split(separator: ":");
                if (addressArr.count != 2) {
                    
                }
                do {
                    let socketAddress = try SocketAddress(ipAddress: String(addressArr[0]), port: Int(addressArr[1])!)
                    newAllServer.insert(socketAddress)
                } catch {
                    print("创建SocketAddress失败")
                }
            }
            
            for sockAddre in newAllServer {
                if !connectedHandlerMap.keys.contains(sockAddre){
                    connectAsync(socketAddress: sockAddre, register: register)
                }
            }
            //3、如果newAllServer列表中不存在的连接地址，那么需要从缓存中删除
            for handler in connectedHandlerArray {
                let socketAddress = handler.remoteAddress
                if !newAllServer.contains(socketAddress!){
                    let ctpHandler = connectedHandlerMap[socketAddress!]
                    ctpHandler?.close()
                    self.syncQueue.sync {
                        connectedHandlerMap.removeValue(forKey: socketAddress!)
                        let index =  connectedHandlerArray.firstIndex (where: {$0===handler})!
                        connectedHandlerArray.remove(at: index)
                    }
                }
            }
            
        } else {
            print("没有服务器")
            //清楚所有缓存信息
            clearConnected();
        }
    }
    
    private func connectAsync(socketAddress: SocketAddress,register:CTPRegister) {
        
        threadPool.submit { state in
            let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            let bootstrap = ClientBootstrap(group: group)
                .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
                .channelInitializer { channel in
                    channel.pipeline.addHandlers([ByteToMessageHandler(CTPDecode()),
                                                  MessageToByteHandler(CTPEncode()),
                                                  CTPClientHandler(receiveData: { data in
                        
                    }, register: register)])
                }
            self.connect(b: bootstrap, socketAddress: socketAddress)
        }
    }
    
    private func connect(b: ClientBootstrap, socketAddress: SocketAddress) {
        self.channelFuture = b.connect(host: socketAddress.ipAddress!, port: socketAddress.port!)
        self.channelFuture?.whenSuccess({ channel in
            print(channel.remoteAddress!)
            let handler = channel.pipeline.handler(type: CTPClientHandler.self)
            
            handler.whenSuccess { clientHandler in
                clientHandler.remoteAddress = channel.remoteAddress
                self.addHandler(handler: clientHandler)
             
            }
        })
        
        self.channelFuture?.whenFailure({ error in
            self.channelFuture?.eventLoop.scheduleTask(in: TimeAmount.seconds(3), {
                self.clearConnected()
                self.connect(b: b, socketAddress: socketAddress)
            })
            print("连接服务器失败")
        })
        
        do {
            try! self.channelFuture?.wait()
        } catch {
            self.channelFuture?.eventLoop.scheduleTask(in: TimeAmount.seconds(3), {
                self.clearConnected()
                self.connect(b: b, socketAddress: socketAddress)
            })
        }
        
        
    }
    
    private func addHandler(handler: CTPClientHandler) {
        self.syncQueue.sync {
            connectedHandlerMap[handler.remoteAddress!] = handler
            connectedHandlerArray.append(handler)
            //唤醒线程
            signalAvailableHandler()
        }
        
    }
    
    
    public func chooseHandler()->CTPClientHandler{
        var size = self.connectedHandlerArray.count
        var handles = self.connectedHandlerArray
        while isRunning && size<=0 {
            if(waitingForAvailableHanler()){
                handles = self.connectedHandlerArray
                size = self.connectedHandlerArray.count
            }
        }
        //        if !isRunning {
        //            return
        //        }
        handlerIndex.wrappingIncrement(by: 1, ordering: .relaxed)
        let index = (handlerIndex.load(ordering: .relaxed) + size) % size
        return handles[index]
    }
    
    private func waitingForAvailableHanler() -> Bool {
        connectedCondition.lock()
        let wait = connectedCondition.wait(until: Date(timeIntervalSinceNow: TimeInterval(timeOut)))
        connectedCondition.unlock();
        return wait
    }
    
    private func signalAvailableHandler() {
        connectedCondition.lock()
        connectedCondition.broadcast()
        connectedCondition.unlock()
        
    }
    
    public func reconnect(handler: CTPClientHandler, remotePeer: SocketAddress) {
        handler.close()
        self.syncQueue.sync {
            let index =  connectedHandlerArray.firstIndex (where: {$0===handler})!
            connectedHandlerArray.remove(at: index)
            connectedHandlerMap.removeValue(forKey: remotePeer)
            connectAsync(socketAddress: remotePeer,register: handler.register)
        }
        
    }
    
    /**
     停止
     */
    public func stop() {
        isRunning = false
        for handler in connectedHandlerArray {
            handler.close()
        }
        //唤醒线程
        signalAvailableHandler()
        try! group.syncShutdownGracefully()
        try! threadPool.syncShutdownGracefully()
    }
    
    private func clearConnected() {
        for handler in connectedHandlerArray {
            let socketAddress = handler.remoteAddress!
            handler.close()
            connectedHandlerMap.removeValue(forKey: socketAddress)
            
        }
        connectedHandlerArray.removeAll()
    }
}
