//
//  UMengManager.swift
//  Joy
//
//  Created by AngleKeen on 2017/10/18.
//  Copyright © 2017年 AngleKeen. All rights reserved.
//

/* 使用说明
* 集成SDK   http://dev.umeng.com/social/ios/quick-integration
* 配置 跳转白名单
* 配置 URL Scheme
* 在 didFinishLaunching 中调用 registerUM 方法
* 在 controller 中 初始化 AKShareModel, 调用 showSharView 方法掉起分享
*/

import UIKit

/// 请求数据回调闭包
typealias finishBlock = (_ succeed:Bool, _ response:Any?)-> ()

class UMengManager: NSObject {

   
   static let shareManager = UMengManager()
   var sourceTarget:UIViewController?
   
   override init() {
       super.init()
       NotificationCenter.default.addObserver(self, selector: #selector(UMengManager.UMengShareSucceed), name: NSNotification.Name(rawValue: "UMengShareSucceed"), object: nil)
   }
   
   /// 调起UMeng分享界面
   ///
   /// - Parameters:
   ///   - object: 分享数据 AKShareModel
   ///   - type: 分享类型 AKShareType
   ///   - target: 调起界面的控制器
   class func showShareView(object:AKShareModel, type:AKShareType, target:UIViewController!) {
       UMengManager.shareManager.sourceTarget = target
       //调起SDK分享界面
       UMSocialUIManager.showShareMenuViewInWindow { (plaform, info) in
           //执行分享
           self.share(plaform: plaform, type: type, object: object, target: target)
       }
   }

   
   /// 分享Action
   ///
   /// - Parameters:
   ///   - plaform: 分享平台
   ///   - type: 分享类型
   ///   - object: 分享内容
   ///   - target: 调起界面的控制器
   class func share(plaform:UMSocialPlatformType, type:AKShareType, object:AKShareModel, target:UIViewController!) {
       //WEB
       if type == .Web {
           let shareObject = UMSocialMessageObject()
           let shareMedial = UMShareWebpageObject()
           shareMedial.title = object.title
           shareMedial.descr = object.desc
           shareMedial.webpageUrl = object.shareUrl
           shareMedial.thumbImage = object.thum
           shareObject.shareObject = shareMedial
           
           UMSocialManager.default().share(to: plaform, messageObject: shareObject, currentViewController:target, completion: { (result, error) in
               if error != nil {
                   print(error)
               }else{
                   print(result)
               }
           })
       //图片
       }else if type == .Image {
           let shareObject = UMSocialMessageObject()
           let shareMedial = UMShareImageObject()
           shareMedial.title = object.title
           shareMedial.descr = object.desc
           shareMedial.shareImage = object.image
           shareObject.shareObject = shareMedial
           
           UMSocialManager.default().share(to: plaform, messageObject: shareObject, currentViewController:target, completion: { (result, error) in
               if error != nil {
                   print(error)
               }else{
                   print(result)
               }
           })
       //文本
       }else if type == .Text {
           let shareObject = UMSocialMessageObject()
           shareObject.text = object.text
           
           UMSocialManager.default().share(to: plaform, messageObject: shareObject, currentViewController:target, completion: { (result, error) in
               if error != nil {
                   print(error)
               }else{
                   print(result)
               }
           })
       }
   }
   
   /// 分享成功回调
   @objc func UMengShareSucceed() {
       if let target = sourceTarget {
        // TODO: 提示分享成功
//           JoyToast.toastWithTitle(title: "分享成功", onView: target.view)
       }
   }
   
   /// 注册UMengSDK
   class func registerUM() {
       UMSocialManager.default().openLog(true)
    // TODO: appKey 、 appSecret
//       UMSocialManager.default().umSocialAppkey = joy_um_ios_key
//       UMSocialManager.default().umSocialAppSecret = joy_um_ios_secret
    
       self.setUMSharePlaform()
       self.setUMSharViewPlaform()
   }
   
   /// 注册第三个平台Key
   class func setUMSharePlaform() {
    // TODO: 各平台appKey、appSecret
//       UMSocialManager.default().setPlaform(.wechatSession, appKey: joy_wx_app_id, appSecret: joy_wx_app_secret, redirectURL: nil)
//       UMSocialManager.default().setPlaform(.wechatTimeLine, appKey: joy_wx_app_id, appSecret: joy_wx_app_secret, redirectURL: nil)
//       UMSocialManager.default().setPlaform(.QQ, appKey: joy_qq_ios_key, appSecret: joy_qq_ios_secret, redirectURL: nil)
//       UMSocialManager.default().setPlaform(.qzone, appKey: joy_qq_ios_key, appSecret: joy_qq_ios_secret, redirectURL: nil)
//       UMSocialManager.default().setPlaform(.sina, appKey: joy_sina_ios_key, appSecret: joy_sina_ios_secret, redirectURL: nil)
   }
   
   /// 设置分享平台
   class func setUMSharViewPlaform() {
       UMSocialUIManager.setPreDefinePlatforms([NSNumber(integerLiteral:UMSocialPlatformType.wechatSession.rawValue),NSNumber(integerLiteral:UMSocialPlatformType.wechatTimeLine.rawValue),NSNumber(integerLiteral:UMSocialPlatformType.QQ.rawValue),NSNumber(integerLiteral:UMSocialPlatformType.sina.rawValue)])
   }
    
    /// 第三方登录
    class func getUserInfoFromPlatform(platformType: UMSocialPlatformType, target: UIViewController!, finishBlock:@escaping finishBlock) {
        UMSocialManager.default().getUserInfo(with: platformType, currentViewController: target) { (result, error) in
            if (error == nil) {
                //获取用户的个人信息
                let userInfo = result as! UMSocialUserInfoResponse
                //调用本地登录接口
                let authData = [
                    "authData" : [
                        "weixin" : [
                            "openid" : userInfo.openid,
                            "access_token" : userInfo.accessToken,
                        ]
                    ]
                ]
                // TODO: 调用自己的登录
//                AVUser.loginOrSignUp(withAuthData: authData, platform: LeanCloudSocialPlatformWeiXin, block: { (user, error) in
//                    if error == nil {
//                        finishBlock(true, user)
//                    }else{
//                        finishBlock(false, error)
//                    }
//                })
            }else{
                finishBlock(false, error)
            }
        }
    }
    
    class func UMLoginWithAuthData(authData: Dictionary<String, Any>, platform: String!, finishBlock:@escaping finishBlock) {
        // TODO: 根据第三方授权信息进行登录操作
//        AVUser.loginOrSignUp(withAuthData: authData, platform: platform, block: { (user, error) in
//            if error == nil {
//                Customer.getUserInfo(userId: AVUser.current()?.objectId ?? "", finishBlock: { (succeed, customerResult) in
//                    if succeed {
//                        LoginManager.shareManager.currentUser = customerResult as? Customer
//                        LCChatManager.shareManager.setupConversationsCellOperation()
//                        LCChatKitManager.invokeThisMethodAfterLoginSuccess(withClientId: LoginManager.shareManager.currentUser?.user_id, success: {
//                            print("LoginSuccess...")
//                        }, failed: { (error) in
//                            print(error!)
//                        })
//                    }
//                    finishBlock(succeed, customerResult)
//                })
//            }else{
//                finishBlock(false, error)
//            }
//        })
    }
    
    class func updateCustomer(finishBlock:@escaping finishBlock) {
        // TODO: 更新用户信息
//        Customer.getUserInfo(userId: AVUser.current()?.objectId ?? "", finishBlock: { (succeed, customerResult) in
//            finishBlock(succeed,customerResult)
//            if succeed {
//                LoginManager.shareManager.currentUser = customerResult as? Customer
//                LCChatManager.shareManager.setupConversationsCellOperation()
//                LCChatKitManager.invokeThisMethodAfterLoginSuccess(withClientId: LoginManager.shareManager.currentUser?.user_id, success: {
//                print("LoginSuccess...")
//                }, failed: { (error) in
//                    print(error!)
//                })
//            }
//        })
    }
    
    class func cancelAuth(platformType: UMSocialPlatformType, finishBlock:@escaping finishBlock){
        UMSocialManager.default().cancelAuth(with: platformType) { (result, error) in
            if error == nil {
                print(result)
                finishBlock(true, error)
            }else{
                finishBlock(false, error)
            }
        }
    }
}


//MARK:ShareModel
enum AKShareType:NSInteger {
   
   case Web = 0
   case Text = 1
   case Image = 2
   case Music = 3
   case Video = 4
}
class AKShareModel: NSObject {
   //web类型使用
   var title:String?
   var desc:String?
   var thum:UIImage?
   var shareUrl:String?
   
   //分享图片
   var image:UIImage?
   
   //分享文本
   var text:String?
   
}

