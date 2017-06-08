//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Kevin Turner on 5/22/17.
//  Copyright © 2017 Kevin Turner. All rights reserved.
//

import UIKit
import Messages
import PhotosUI
import CloudKit

class MessagesViewController: MSMessagesAppViewController {
    var cpm : CaptionPhotoMessage?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
   
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        
        if let selectedMessage = conversation.selectedMessage {
            let cpm = CaptionPhotoMessage(message: selectedMessage) ?? CaptionPhotoMessage()
            self.cpm = cpm
            
            
            if cpm.senderID == conversation.localParticipantIdentifier.uuidString {
                //waiting interface
            } else {
                //Open captioning interface
                guard let captionVC = instantiateVC(withId: "caption") as? CaptionViewController else {
                    fatalError("Cannot present VC")
                }
                
                adddChildVC(captionVC)
                captionVC.delegate = self
                captionVC.cpm = cpm
            }
            
        }
    }
    

    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    @IBAction func startRound(_ sender: Any) {
        guard let startRoundVC = instantiateVC(withId: "startround") as? StartRoundViewController else {
            fatalError("could not initizlize")
        }
        
        
        requestPresentationStyle(.expanded)
        startRoundVC.delegate = self
        
        adddChildVC(startRoundVC)
    }
    
  
    
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
        
        if presentationStyle == .compact {
            
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    // MARK : Convenience
    private func instantiateVC(withId id: String) -> UIViewController
    {
        return storyboard!.instantiateViewController(withIdentifier: id)
        
    }
    
    func adddChildVC(_ viewController: UIViewController){
        self.addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        viewController.view.frame = self.view.bounds
        self.view.addSubview(viewController.view)
        self.view.bringSubview(toFront: viewController.view)
    }
    
    
  func removeAllChildViewControllers() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
    
    
    func composeMessage(withImage image: UIImage, roundID: String, caption: String, session: MSSession? = nil) -> MSMessage
    {
        guard let conversation = activeConversation else {
            fatalError("could not get active conversation")
        }
        
        
        
        var components = URLComponents()
        print("session : \(session)")
        let message = MSMessage(session: session ?? MSSession())
        message.url = components.url!
    
        
        
         let roundID = NSUUID().uuidString
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "roundID", value: roundID))
        queryItems.append(URLQueryItem(name: "senderID", value: conversation.localParticipantIdentifier.uuidString))
        
        components.queryItems = queryItems
        
        let layout = MSMessageTemplateLayout()
        
        layout.image = image
        layout.caption = caption
        
        message.layout = layout
        message.url = components.url!
        
        saveImage(image, roundID: roundID)
        
        return message
    }
    
    
    func saveImage(_ image: UIImage, roundID: String){
        let searchPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documents = searchPaths.first
        
        guard let docPath = documents else {
            fatalError("Documents Path not found")
        }
        
        let imagePath = docPath.appendingPathComponent("round.png")
        
        guard let imageData = UIImagePNGRepresentation(image) else {
            fatalError("Could not get image data")
        }
        
        try? imageData.write(to: imagePath)
        
        let roundRecordID = CKRecordID(recordName: roundID)
        let roundRecord = CKRecord(recordType: "Round", recordID: roundRecordID)
        
        
        let imageAsset = CKAsset(fileURL: imagePath)
        roundRecord["image"] = imageAsset
        roundRecord["responses"] = [""] as NSArray
        
        let myContainer = CKContainer.default()
        let publicDatabase = myContainer.publicCloudDatabase
        publicDatabase.save(roundRecord, completionHandler: {(record, error) in
            if let error  = error {
                print("failed")
                print(error)
            } else {
                print(roundID)
            }
        })
    }
    
    

}

extension MessagesViewController : CaptionViewControllerDelegate
{
    func captionSelected(withImage image: UIImage) {
        DispatchQueue.main.async {
              self.removeAllChildViewControllers()
    
            let message = self.composeMessage(withImage: image, roundID: self.cpm!.roundID, caption: "Selected caption", session: self.activeConversation?.selectedMessage?.session)
            self.activeConversation?.insert(message, completionHandler: nil)
        
        self.dismiss()
        }
      
    }
}



extension MessagesViewController : StartRoundViewControllerDelegate
{
    func selectedImage(_ image: UIImage) {
       removeAllChildViewControllers()
        
        guard let conversation = activeConversation else {
            fatalError("Conversation could not be loaded")
        }
        
        var components = URLComponents()
        
        let roundID = NSUUID().uuidString
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "roundID", value: roundID))
        queryItems.append(URLQueryItem(name: "senderID", value: conversation.localParticipantIdentifier.uuidString))
        
        components.queryItems = queryItems
        
        let message = composeMessage(withImage: image, roundID: roundID, caption: "Image Selected", session: conversation.selectedMessage?.session)
      
        
        
        

        
        conversation.insert(message, completionHandler: {(error) in
            if #available(iOSApplicationExtension 11.0, *) {
                self.dismiss()
            } else {
                // Fallback on earlier versions
                self.dismiss()
            }
        })
    }
}
