//
//  KeyboardManager.swift
//  Test
//
//  Created by wxqdev on 14-11-20.
//  Copyright (c) 2014年 task.iteasysoft.com. All rights reserved.
//


import Foundation
import UIKit

///Manages view animation when keyboard is activated
class KeyboardManager:NSObject,UITextFieldDelegate {
  
    
    var contentView:UIView!
    var navigationBarViewRect:CGRect = CGRectMake(0.0,0.0,0.0,0.0)
    
    //键盘相关
    var  contentViewY:CGFloat = 0.0
    var  editingTextFieldOrTextView:AnyObject?
    var  textViewOrFieldOrgDelegate:AnyObject?

    
    init(controller: UIViewController,navRect:CGRect ) {
        super.init()
        navigationBarViewRect = navRect
        contentView = controller.view
        self.configViews()
    }
    
    /*******************************ContentView  NavigationBarView begin**********************************/
    //配置views
    func configViews()
    {
        contentView.frame =  CGRectMake(0, navigationBarViewRect.origin.y + navigationBarViewRect.height, self.contentView.frame.width
            , self.contentView.frame.height - (navigationBarViewRect.origin.y + navigationBarViewRect.height))
        contentView.backgroundColor = UIColor.colorWithHex("#F5F5F5")//UIColor.ColorMake(red: 245 , green: 245, blue: 245)
    }

    func navigationBarViewHeight() -> CGFloat
    {
        return DeviceInfo.lessIOS7() ? 44 : 64
    }
    /*******************************ContentView  NavigationBarView end**********************************/
    
    
    
    
    /*******************************管理键盘事件 begin*****************************************************/
    //如果开启此功能 则VieController 会自动监听键盘弹起事件 自动将编辑中的view拖动到可见区域
    func enableKeyboardManger() /*default enabled*/
    {
        if (!self.isEnableKeyboardManger())
        {
            return;
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("textFieldDidBeginEditingNotification:"), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("textFieldDidEndEditingNotification:"), name: UITextFieldTextDidEndEditingNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("textFieldDidBeginEditingNotification:"), name: UITextViewTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("textFieldDidEndEditingNotification:"), name: UITextViewTextDidEndEditingNotification, object: nil)
    }
    
    func disableKeyboardManager()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidEndEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidEndEditingNotification, object: nil)
    }
    
    func isEnableKeyboardManger() -> Bool
    {
        return true
    }
    
    
    //键盘将要隐藏
    func keyboardWillHide(notification:NSNotification)
    {
        
        contentView.y =  contentViewY > 0 ? contentViewY : navigationBarViewRect.origin.y + navigationBarViewRect.height;
        
    }
    
    //键盘将要显示
    func keyboardWillShow(notification:NSNotification)
    {
        if (editingTextFieldOrTextView == nil)
        {

            return;

        }
        /*
        获取通知携带的信息
        */
        
        var userInfo:Dictionary = notification.userInfo!
        // Get the origin of the keyboard when it's displayed.
        var aValue:NSValue? = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
        // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
        var keyboardRect:CGRect = aValue!.CGRectValue()
        keyboardRect =   self.contentView.convertRect(keyboardRect, toView: self.contentView)
        
        var editingViewSuperView:UIView? = editingTextFieldOrTextView?.superview
        var textViewRect:CGRect = editingViewSuperView!.convertRect(editingTextFieldOrTextView!.frame, toView: self.contentView)
        var offsetY:CGFloat = (textViewRect.origin.y + textViewRect.size.height) - keyboardRect.origin.y
        
        //输入框未被键盘遮挡 无需调整
        if (offsetY <= 0)
        {
            return;
        }
        offsetY += DeviceInfo.lessIOS7() ? self.navigationBarViewHeight() :0;
        contentView.y -= offsetY + 5 ;
    }
    
    func textFieldDidBeginEditingNotification(notification:NSNotification)
    {
        
        editingTextFieldOrTextView = notification.object
        if (editingTextFieldOrTextView is UITextField)
        {
            
            var textFiled:UITextField = editingTextFieldOrTextView as! UITextField
            
            if (textFiled.delegate == nil)
            {
                textFiled.delegate = self
            }
            
            if (textFiled.returnKeyType == UIReturnKeyType.Default)
            {
                textFiled.returnKeyType = UIReturnKeyType.Done
            }
            
        }
        else if(editingTextFieldOrTextView is UITextView)
        {
            var textView:UITextView = editingTextFieldOrTextView as! UITextView
            if (textView.returnKeyType == UIReturnKeyType.Default)
            {
                textView.returnKeyType = UIReturnKeyType.Done
            }
            //UITextField VS UITextView
           
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        self.endEditing()
        return true
    }
    
    func textFieldDidEndEditingNotification(notification:NSNotification)
    {
        editingTextFieldOrTextView = nil
        textViewOrFieldOrgDelegate = nil
    }
    
    
    func endEditing()
    {
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
    }
    
    /*******************************管理键盘事件 end*****************************************************/
    
    
}