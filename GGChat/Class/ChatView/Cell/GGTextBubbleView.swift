//
//  GGTextBubbleView.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/19.
//

import UIKit

class GGTextBubbleView: BaseBubbleView {
    public var textLabel:UILabel = {
        let tmpLabel = UILabel(frame: CGRect.zero)
        tmpLabel.numberOfLines = 0
        return tmpLabel
    }()
    override init(direction: GGMessageDirection, msgType: GGMessageType) {
        super.init(direction: direction, msgType: msgType)
        self._setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setupSubviews(){
        self.setupBubbleBackgroundImage()
        
        self.addSubview(self.textLabel)
        
        self.textLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(-10)
        }
        
        if self.msgDirection == .Send{
            self.textLabel.snp.makeConstraints { make in
                make.left.equalTo(self).offset(10)
                make.right.equalTo(self).offset(-15)
            }
        }else{
            self.textLabel.snp.makeConstraints { make in
                make.left.equalTo(self).offset(15)
                make.right.equalTo(self).offset(-10)
            }
        }
    }
     override func setMsgModel(model:GGChatMessage){
         super.setMsgModel(model: model)
        self.textLabel.text = model.payload
    }
}
