//
//  ChatTableViewCell.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/19.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    private var direction:GGMessageDirection
    private var type:GGMessageType
    private var model:GGChatMessage?
    lazy private var bubbleView:BaseBubbleView = {
        let tmpBubbleView = _getBubbleView(type: type)
        tmpBubbleView.isUserInteractionEnabled = true
        tmpBubbleView.clipsToBounds = true
        return tmpBubbleView
    }()
    
    lazy private var headImage:UIImageView = {
        let tmpImage = UIImageView(frame: CGRect.zero)
        tmpImage.layer.cornerRadius = 20
        tmpImage.backgroundColor = .orange
        return tmpImage
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func setMsgModel(model:GGChatMessage){
        self.model = model
        self.bubbleView.setMsgModel(model: model)
    }
    init(direction:GGMessageDirection,type:GGMessageType){
        self.direction = direction
        self.type = type
        
    
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: ChatTableViewCell.cellIdentifier(direction: direction, type: type))
        self.contentView.backgroundColor = "#F6F7FA".uicolor()
        self.contentView.addSubview(self.headImage)
        self.contentView .addSubview(self.bubbleView)
        self.contentView.setNeedsUpdateConstraints()
        self.contentView.updateConstraintsIfNeeded()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if self.direction == .Send {
            self.headImage.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 40, height: 40))
                make.right.equalTo(self.contentView).offset(-15)
                make.top.equalTo(self.contentView).offset(5)
            }
            self.bubbleView.snp.makeConstraints { make in
                make.top.equalTo(self.contentView)
                make.bottom.equalTo(self.contentView).offset(-15)
                make.width.lessThanOrEqualTo(240)
                make.right.equalTo(self.headImage.snp.left).offset(-10)
            }
        }else{
            self.headImage.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 40, height: 40))
                make.left.equalTo(self.contentView).offset(15)
                make.top.equalTo(self.contentView).offset(5)
            }
            
            self.bubbleView.snp.makeConstraints { make in
                make.top.equalTo(self.contentView)
                make.bottom.equalTo(self.contentView).offset(-15)
                make.width.lessThanOrEqualTo(240)
                make.left.equalTo(self.headImage.snp.right).offset(10)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func cellIdentifier(direction:GGMessageDirection,type:GGMessageType)->String{
        var identifier = "GGMsgCellSend"
        if direction == .Receive{
            identifier = "GGMsgCellReceive"
        }
        if type == .Text {
            identifier = "text\(identifier)"
        }
        return identifier
    }
    
    func _getBubbleView(type:GGMessageType)->BaseBubbleView {
        var bubbleView:BaseBubbleView
        switch type {
        case .Text:
            bubbleView = GGTextBubbleView(direction: self.direction, msgType: type)
        default:
            bubbleView = GGTextBubbleView(direction: self.direction, msgType: type)
        }
        return bubbleView
    }
}
