//
//  ViewController.swift
//  QuickbloxTest
//
//  Created by Martin Svensson on 2016-01-21.
//  Copyright © 2016 Spinit. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: JSQMessagesViewController, QBChatDelegate, UINavigationBarDelegate {
    var groupChatDialog: QBChatDialog?
    var messages : [JSQMessage] = [JSQMessage]()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    var avatars = Dictionary<String, UIImage>()
    var password: String!
    var email: String!
    var userId: String!
    var user : QBUUser!
    var alert : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 44))
        navigationBar.backgroundColor = UIColor.whiteColor()
        navigationBar.delegate = self
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "Chat"
        
        let leftButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "backButtonClicked:")
        navigationItem.leftBarButtonItem = leftButton
        
        navigationBar.items = [navigationItem]
        
        self.view.addSubview(navigationBar)
        
        alert = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        alert.frame = CGRectMake(0, 0, 24, 24)
        view.addSubview(alert)
        alert.startAnimating()
        
        QBChat.instance().addDelegate(self)
        self.senderId = self.userId
        self.senderDisplayName = self.email
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        self.inputToolbar?.contentView?.leftBarButtonItem = nil
        // Do any additional setup after loading the view, typically from a nib.
        signInToChat()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: NSDate.distantPast(), text: text)
        messages += [message!]
        
        let qbMessage: QBChatMessage = QBChatMessage()
        qbMessage.senderNick = self.senderDisplayName
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
        let senderName = message.customParameters!.valueForKeyPath("user_nick") as! String
        
        if (senderId != self.userId) {
            let jsqMessage = JSQMessage(senderId: senderId, displayName: senderName, text: text)
            messages += [jsqMessage!]
            self.finishReceivingMessageAnimated(true)
        }
        
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
        if (self.messages[indexPath.item].senderId == self.userId) {
            return factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        } else {
            return factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        // This doesn't really do anything, but it's a good point for customization
        let message = self.messages[indexPath.item];
        if (message.senderId == self.userId) {
            cell.textView?.textColor = UIColor.blackColor()
        } else {
            cell.textView?.textColor = UIColor.whiteColor()
        }
        
        
        
        return cell;  
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        if (messages[indexPath.item].senderId != self.userId) {
            return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("XX", backgroundColor: UIColor.jsq_messageBubbleLightGrayColor(), textColor: UIColor.whiteColor(), font: UIFont.boldSystemFontOfSize(14), diameter: 30)
        }
        return nil
    }
    
    func signInToChat() {
        let user = QBUUser()
        user.password = self.password
        user.ID = UInt(self.userId)!
        
        QBRequest.logInWithUserEmail(self.email!, password: self.password!, successBlock: { (response: QBResponse, signedInUser: QBUUser?) -> Void in
            let test = signedInUser;
            QBChat.instance().connectWithUser(test!, completion: { (NSError) -> Void in
                
                let extendedRequest = ["sort_desc": "_id"]
                
                let page = QBResponsePage(limit:100, skip: 0)
                
                QBRequest.dialogsForPage(page, extendedRequest: extendedRequest, successBlock: { (response: QBResponse, dialogs: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, page: QBResponsePage?) -> Void in
                    
                    self.groupChatDialog = dialogs?[0]
                    self.navigationItem.title = self.groupChatDialog!.name
                    
                    self.joinChat()
                    
                    }) { (response: QBResponse) -> Void in
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
            if ((error) != nil) {
                print(error)
            } else {
                /*QBRequest.messagesWithDialogID(self.groupChatDialog!.ID!, extendedRequest: nil, forPage: QBResponsePage(limit:20, skip: 0), successBlock: {(response: QBResponse, qbMessages: [QBChatMessage]?, responsePage: QBResponsePage?) in
                    for i in 0...qbMessages!.count - 1 {
                        let senderUserID = qbMessages![i].senderID
                        let jsqMessage = JSQMessage(senderId: String(senderUserID), displayName: "Test Testsson", text: qbMessages![i].text)
                        self.messages += [jsqMessage!]
                    }
                    
                    }, errorBlock: {(response: QBResponse!) in })*/
            }
        }
    }
    
    func backButtonClicked(sender: UIBarButtonItem) {
        let loginViewController : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController")
        self.showViewController(loginViewController as! UIViewController, sender: loginViewController)
    }
}

