//
//  CharBar.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/15.
//

import UIKit

@objc protocol CharBarDelegate : NSObjectProtocol {
    func clickMoreBtn()
}

class CharBar: UIView {
    lazy var tf_chatBar:UITextField = {
        let tf = UITextField(frame: CGRect.zero)
        tf.delegate = self
        tf.backgroundColor = UIColor.lightGray
        tf.layer.cornerRadius = 4
        return tf
}()
    
    lazy var btn_more:UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage(named: "chatBar_more"), for: UIControl.State.normal)
        btn.setImage(UIImage(named: "msgJianPan"), for: UIControl.State.selected)
        btn.addTarget(self, action: #selector(btnMoreTap), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    
    weak open var delegate: CharBarDelegate? // default is nil. weak reference
    
    var returnCallback: (_ text:String) -> ()?
    
    init(returnCallback: @escaping (_ text:String) ->()){
        
        
        self.returnCallback = returnCallback
        super.init(frame: CGRect.zero)
        self.addSubview(self.tf_chatBar)
        self.addSubview(self.btn_more)
        
        self.tf_chatBar.snp.makeConstraints { make in
            make.left.equalTo(self).offset(50)
            make.right.equalTo(self).offset(-100)
            make.centerY.equalTo(self)
            make.height.equalTo(45)
        }
        
        self.btn_more.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self.tf_chatBar.snp.right).offset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func btnMoreTap()  {
      print("aaaaa")
        
        if self.delegate != nil && (self.delegate?.responds(to: #selector(CharBarDelegate.clickMoreBtn)))!{
            self.delegate?.clickMoreBtn()
        }
      
    }
}

extension CharBar:UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.returnCallback(textField.text!)
        textField.text = ""
        return true
    }
}
