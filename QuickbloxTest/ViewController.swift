//
//  ViewController.swift
//  QuickbloxTest
//
//  Created by Martin Svensson on 2016-01-21.
//  Copyright © 2016 Spinit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: JSQMessagesViewController {
    var groupChatDialog: QBChatDialog?
    var messages : [JSQMessage] = [JSQMessage]()
    let user : QBUPersonalUser! = QBUPersonalUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderDisplayName = "LosGlennos"
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        self.inputToolbar?.contentView?.leftBarButtonItem = nil
        // Do any additional setup after loading the view, typically from a nib.
        signInToChat()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text)
        messages += [message!]
        
        self.finishSendingMessageAnimated(true)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData!
    {
        return self.messages[indexPath.item];
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        let factory = JSQMessagesBubbleImageFactory();
        
        return factory.outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor());
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath);
        
        // This doesn't really do anything, but it's a good point for customization
        let message = self.messages[indexPath.item];
        
        return cell;  
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil;
    }
    
    func signInToChat() {
        let user = QBUUser()
        user.ID = self.user.getUserId()
        user.password = self.user.getPassword()
        
        QBRequest.logInWithUserLogin(self.user.getUsername(), password: user.password!, successBlock: { (response: QBResponse, QBUUser) -> Void in
            QBChat.instance().connectWithUser(user, completion: { (NSError) -> Void in
                let extendedRequest = ["sort_desc": "_id"]
                
                let page = QBResponsePage(limit:100, skip: 0)
                
                QBRequest.dialogsForPage(page, extendedRequest: extendedRequest, successBlock: { (response: QBResponse, dialogs: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, page: QBResponsePage?) -> Void in
                    
                    self.groupChatDialog = dialogs?[0]
                    
                    self.joinChat()
                    
                    }) { (response: QBResponse) -> Void in
                        
                }
            })
            }) { (QBResponse) -> Void in
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func joinChat() {
        groupChatDialog!.joinWithCompletionBlock { (error: NSError?) -> Void in }
    }
    
    func sendMessage(text: String) {
        let message: QBChatMessage = QBChatMessage()
        message.text = text
        let params = NSMutableDictionary()
        params["save_to_history"] = true
        message.customParameters = params
        
        groupChatDialog!.sendMessage(message, completionBlock: { (error: NSError?) -> Void in
            if ((error) != nil) {
                print(error)
            }
        });
    }


}

