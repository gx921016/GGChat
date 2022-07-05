//
//  BubbleView.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/19.
//

import UIKit

class BaseBubbleView: UIImageView {
    
    public var msgType:GGMessageType
    public var msgDirection:GGMessageDirection
    init(direction: GGMessageDirection,msgType:GGMessageType) {
        self.msgType = msgType
        self.msgDirection = direction
        super.init(frame: CGRect.zero)
        
    }
    
    func setupBubbleBackgroundImage(){
        let executableFile = Bundle.main.infoDictionary?[kCFBundleExecutableKey as String]
        if  self.msgDirection == .Send {
            self.image = createStretchImage(imageName: "chat_sender_bg")
        }else{
            self.image = createStretchImage(imageName: "chat_receiver_bg")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func createStretchImage(imageName:String)->UIImage{
        let image =  UIImage(named: imageName)
        let newImage = image?.resizableImage(withCapInsets: UIEdgeInsets(top: (image?.size.height)!  * 0.5, left: (image?.size.height)! * 0.5, bottom: (image?.size.height)!  * 0.5, right: (image?.size.height)! * 0.5), resizingMode: UIImage.ResizingMode.stretch) ?? nil
        return newImage!
    }
    
    public func setMsgModel(model:GGChatMessage){
        
    }
}
