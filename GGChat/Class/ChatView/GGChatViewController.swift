//
//  GGChatViewController.swift
//  GGChat
//
//  Created by 高祥 on 2021/11/11.
//

import UIKit
import NIOCore
import NIOPosix
import SnapKit
import YPImagePicker

class GGChatViewController: UIViewController {
    lazy var tv_list:UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tv.backgroundColor = "#F6F7FA".uicolor()
        tv.estimatedRowHeight = 130
        tv.rowHeight = UITableView.automaticDimension
        tv.separatorStyle = .none
        return tv
    }()
    let tf_chatBar = UITextField(frame: CGRect.init(x: 20, y: 50, width: 200, height: 50))
    
    let client = CTPClient(serverAddress: "10.1.2.67:9000",register: CTPRegister(uid: 9999, token: "qwertyu"))
    
    var dataSource:Array<GGChatMessage> = []
    
    var charBar:CharBar?
    //底部工具栏下约束
    var bottomConstraint: Constraint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(note:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        self.charBar = CharBar(returnCallback: { text in
            
            self.client.sendMsg(to: 2443, text: text) { msg in
                let msgModel =  GGChatMessage(direction: GGMessageDirection.Send, type: GGMessageType.Text, from: msg.uid, to: msg.to ?? 0, payload: msg.body)
                self.dataSource.append(msgModel)
                self.tv_list.reloadData()
                self.tv_list.scrollToRow(at: IndexPath(row: self.dataSource.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        })
        self.charBar?.backgroundColor = UIColor.purple
        self.charBar?.delegate = self
        self.tv_list.delegate = self
        self.tv_list.dataSource = self
        
        self.view.addSubview(self.tv_list)
        self.view.addSubview(self.charBar!)
        
        self.updateConstraint()
        
        
        client.receiveData { [self] data in
            let msgModel =  GGChatMessage(direction: GGMessageDirection.Receive, type: GGMessageType.Text, from: data.uid, to: client.register.uid , payload: data.body)
            self.dataSource.append(msgModel)
            self.tv_list.reloadData()
            self.tv_list.scrollToRow(at: IndexPath(row: self.dataSource.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            print(data.type)
            print(data.body)
        }
    }
    
    func updateConstraint(){
        self.tv_list.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(0)
            } else {
                make.top.equalTo(self.topLayoutGuide.snp.top).offset(0)
            }
            make.bottom.equalTo(self.charBar!.snp.top)
        }
        self.charBar!.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            
            if #available(iOS 11.0, *) {
                self.bottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(0).constraint
            } else {
                self.bottomConstraint = make.bottom.equalTo(self.view).constraint
            }
            make.height.equalTo(55)
        }
    }
    
    
    @objc func keyboardWillShow(note: NSNotification) {
        let userInfo = note.userInfo!
        
        let  keyBoardBounds = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let frame = keyBoardBounds
        let intersection = frame.intersection(self.view.frame)
        //弹出键盘执行的方法。
        let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        if(intersection.height>0){
            self.bottomConstraint?.update(offset:  -intersection.height+35)
        }else{
            self.bottomConstraint?.update(offset:  -intersection.height)
        }
        
        UIView.animate(withDuration: 0.0, delay: 0.0, options: options) {
            self.view.layoutIfNeeded()
        } completion: { c in
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.charBar?.endEditing(true)
    }
}

extension GGChatViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let msgModel = self.dataSource[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.cellIdentifier(direction: msgModel.direction, type: msgModel.type))
        if (cell == nil) {
            cell = ChatTableViewCell(direction: msgModel.direction, type: msgModel.type)
        }
        (cell as! ChatTableViewCell).setMsgModel(model: msgModel)
        
        return cell!
    
}

extension GGChatViewController:CharBarDelegate {
    func clickMoreBtn() {
        let endpoint = "oss-cn-beijing.aliyuncs.com"
        var credential = OSSFederationCredentialProvider {
            var token = OSSFederationToken()
            token.tAccessKey = "LTAI5tAU6nGBro6aohrJ5Zde"
            token.tSecretKey = "TJ9qBAdRUgCpld8cb6pJ06HPAZdVI6"
            token.tToken = ""
            return token
        }
        var config = YPImagePickerConfiguration()
    
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta) // Print exif meta data of original image.
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
}

extension String {
    /// 十六进制字符串颜色转为UIColor
    /// - Parameter alpha: 透明度
    func uicolor(alpha: CGFloat = 1.0) -> UIColor {
        // 存储转换后的数值
        var red: UInt64 = 0, green: UInt64 = 0, blue: UInt64 = 0
        var hex = self
        // 如果传入的十六进制颜色有前缀，去掉前缀
        if hex.hasPrefix("0x") || hex.hasPrefix("0X") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 2)...])
        } else if hex.hasPrefix("#") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 1)...])
        }
        // 如果传入的字符数量不足6位按照后边都为0处理，当然你也可以进行其它操作
        if hex.count < 6 {
            for _ in 0..<6-hex.count {
                hex += "0"
            }
        }
        
        // 分别进行转换
        // 红
        Scanner(string: String(hex[..<hex.index(hex.startIndex, offsetBy: 2)])).scanHexInt64(&red)
        // 绿
        Scanner(string: String(hex[hex.index(hex.startIndex, offsetBy: 2)..<hex.index(hex.startIndex, offsetBy: 4)])).scanHexInt64(&green)
        // 蓝
        Scanner(string: String(hex[hex.index(startIndex, offsetBy: 4)...])).scanHexInt64(&blue)
        
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
}
