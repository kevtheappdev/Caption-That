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


protocol ViewControllerCallback : class {
    func finishedActions(withModel model: CaptionPhotoMessage)
}

class MessagesViewController: MSMessagesAppViewController {
    var cpm : CaptionPhotoMessage?
    var sendAction : (() -> ())?
    
    
    
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

            if cpm.senderID == conversation.localParticipantIdentifier.uuidString {
                guard let waitingVC = instantiateVC(withId: "waiting") as? WaitingViewController else {
                    fatalError("Could not instantiate viewcontroller")
                }
                waitingVC.roundID = cpm.roundID
                adddChildVC(waitingVC)
            } else {
                //Open captioning interface
                guard let captionVC = instantiateVC(withId: "caption") as? CaptionViewController else {
                    fatalError("Cannot present VC")
                }
                
                captionVC.callBackDelegate = self
                adddChildVC(captionVC)
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
        
        guard let conversation = activeConversation else {
            fatalError("No conversation found")
        }
        
        let roundID = NSUUID().uuidString
        
        let cpm = CaptionPhotoMessage(roundID: roundID, senderID: conversation.localParticipantIdentifier.uuidString)
        startRoundVC.cpm = cpm
        
        requestPresentationStyle(.expanded)
        startRoundVC.callbackDelegate = self
        //startRoundVC.delegate = self
        
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
        self.cpm?.cancelAction()
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
    
    
    func composeMessage(withImage image: UIImage, roundID: String, caption: String, senderID: String, session: MSSession? = nil) -> MSMessage
    {
      
        
        
        
        var components = URLComponents()

        let message = MSMessage(session: session ?? MSSession())
        message.url = components.url!
    
        
        
             
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "roundID", value: roundID))
        queryItems.append(URLQueryItem(name: "senderID", value: senderID))
        
        components.queryItems = queryItems
        
        let layout = MSMessageTemplateLayout()
        
        layout.image = image
        layout.caption = caption
        
        message.layout = layout
        message.url = components.url!
        
        
        
        return message
    }
    
    
    func composeMessage(withModel model: CaptionPhotoMessage) -> MSMessage
    {
        
        let session = activeConversation?.selectedMessage?.session
        
        var components = URLComponents()
        
        let message = MSMessage(session: session ?? MSSession())
        message.url = components.url!
        
        
        
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "roundID", value: model.roundID))
        queryItems.append(URLQueryItem(name: "senderID", value: model.senderID))
        
        components.queryItems = queryItems
        
        let layout = MSMessageTemplateLayout()
        
        layout.image = model.image
        layout.caption = model.caption
        
        message.layout = layout
        message.url = components.url!
        
        
        
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


extension MessagesViewController : ViewControllerCallback
{
    func finishedActions(withModel model: CaptionPhotoMessage) {
        self.cpm = model
        
        if cpm?.error != nil {
            let alert = UIAlertController(title: "Something went wrong...", message: "We couldn't complete the requested action, please make sure your internet connection is valid", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
          
        } else {
            let message = composeMessage(withModel: cpm!)
            
            guard let conversation = activeConversation else {
                fatalError("Failed to load the conversation")
            }
            
            conversation.insert(message, completionHandler: ({(error) in
                if error != nil {
                    fatalError("Could not insert message")
                } else {
                    self.dismiss()
                }
            }))
        }
    }
}

//extension MessagesViewController : CaptionViewControllerDelegate
//{
//    func captionSelected(withImage image: UIImage) {
//        DispatchQueue.main.async {
//              self.removeAllChildViewControllers()
//            
//            let message = self.composeMessage(withImage: image, roundID: self.cpm!.roundID, caption: "Selectes caption", senderID: self.cpm!.senderID, session: self.activeConversation?.selectedMessage?.session)
//            self.activeConversation?.insert(message, completionHandler: nil)
//        
//             self.dismiss()
//        }
//      
//    }
//    
//    func captionSelected(_ caption: String){
//        guard let roundIDString = self.cpm?.roundID else {
//            return
//        }
//        
//        let publicDB = CKContainer.default().publicCloudDatabase
//        let roundID = CKRecordID(recordName: roundIDString)
//        
//        publicDB.fetch(withRecordID: roundID, completionHandler: ({(record, error) in
//            if error == nil {
//                let responses = record!["responses"] as! NSArray
//                print(responses)
//                for response in responses {
//                    let userResponse = response as! String
//                    print("response is \(userResponse)")
//                }
//            } else {
//                print(error!)
//            }
//        }))
//    }
//}



//extension MessagesViewController : StartRoundViewControllerDelegate
//{
//    func selectedImage(_ image: UIImage) {
//       removeAllChildViewControllers()
//        
//        guard let conversation = activeConversation else {
//            fatalError("Conversation could not be loaded")
//        }
//        
//  
//        //FIX ME : remove any other creation of roundID
//        let roundID = NSUUID().uuidString
//        
//
//        
//        let message = composeMessage(withImage: image, roundID: roundID, caption: "Image Selected", senderID: conversation.localParticipantIdentifier.uuidString, session: conversation.selectedMessage?.session)
//        
//        saveImage(image, roundID: roundID)
//        
//        conversation.insert(message, completionHandler: {(error) in
//            if #available(iOSApplicationExtension 11.0, *) {
//                self.dismiss()
//            } else {
//                // Fallback on earlier versions
//                self.dismiss()
//            }
//        })
//    }
//}
