//
//  ViewController.swift
//  QuickbloxTest
//
//  Created by Martin Svensson on 2016-01-21.
//  Copyright © 2016 Spinit. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: JSQMessagesViewController, QBChatDelegate {
    var groupChatDialog: QBChatDialog?
    var messages : [JSQMessage] = [JSQMessage]()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    var avatars = Dictionary<String, UIImage>()
    var password: String!
    var username: String!
    var userId: String!
    var user : QBUUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        QBChat.instance().addDelegate(self)
        self.senderId = String("1234")
        self.senderDisplayName = username
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        self.inputToolbar?.contentView?.leftBarButtonItem = nil
        // Do any additional setup after loading the view, typically from a nib.
        signInToChat()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text)
        messages += [message!]
        
        let qbMessage: QBChatMessage = QBChatMessage()
        qbMessage.text = text
        let params = NSMutableDictionary()
        params["save_to_history"] = true
        qbMessage.customParameters = params
        
        groupChatDialog!.sendMessage(qbMessage, completionBlock: { (error: NSError?) -> Void in
            if ((error) != nil) {
                print(error)
            }
        });
        
        self.finishSendingMessageAnimated(true)
    }
    
    func chatRoomDidReceiveMessage(message: QBChatMessage, fromDialogID dialogID: String) {
        let text = message.text
        let senderId = String(message.senderID)
        let senderName = message.senderNick
        
        if (senderId != self.userId) {
            let jsqMessage = JSQMessage(senderId: senderId, displayName: senderName, text: text)
            messages += [jsqMessage!]
        }
        
        self.finishReceivingMessageAnimated(true)
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
        let factory = JSQMessagesBubbleImageFactory()
        if (self.messages[indexPath.item].senderId == self.senderId) {
            return factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        } else {
            return factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath);
        
        // This doesn't really do anything, but it's a good point for customization
        let message = self.messages[indexPath.item];
        
        return cell;  
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    func signInToChat() {
        let user = QBUUser()
        user.password = self.password
        user.ID = UInt(self.userId)!
        
        QBRequest.logInWithUserLogin(self.username!, password: self.password!, successBlock: { (response: QBResponse, signedInUser: QBUUser?) -> Void in
            QBChat.instance().connectWithUser(user, completion: { (NSError) -> Void in
                let extendedRequest = ["sort_desc": "_id"]
                
                let page = QBResponsePage(limit:100, skip: 0)
                
                QBRequest.dialogsForPage(page, extendedRequest: extendedRequest, successBlock: { (response: QBResponse, dialogs: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, page: QBResponsePage?) -> Void in
                    
                    self.groupChatDialog = dialogs?[0]
                    
                    self.joinChat()
                    
                    }) { (response: QBResponse) -> Void in
                       var qbResponse = response
                }
            })
            }) { (response: QBResponse) -> Void in
                let successfulLogin = response.success
                if (!successfulLogin) {
                    let backToLoginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController")
                    self.presentViewController(backToLoginVC!, animated: true, completion: nil)
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func joinChat() {
        groupChatDialog!.joinWithCompletionBlock {
            (error: NSError?) -> Void in
                print(error)
        }
    }
    
    func sendMessage(text: String) {
        
    }


}

