//
//  CaptionPhotoMessage.swift
//  Caption That
//
//  Created by Kevin Turner on 6/6/17.
//  Copyright © 2017 Kevin Turner. All rights reserved.
//

import UIKit
import Messages
import CloudKit

class CaptionPhotoMessage {
    var roundID : String
    var senderID : String
    var caption : String? {
        didSet {
            
        }
    }
    var count = 0
    var image : UIImage? {
        didSet {
            saveImage()
        }
    }
    
    
    var record : CKRecord?
    
 
    
    var cancelAction : (() -> ())!
    var error : Error?
    
    init(roundID: String, senderID: String){
        self.roundID = roundID
        self.senderID = senderID
    }
  
    
    
    
    
    func deleteLastReponse(){
        let publicDb = CKContainer.default().publicCloudDatabase
        if let record = self.record {
            publicDb.fetch(withRecordID: record.recordID, completionHandler: ({(record, error) in
                if error != nil {
                    self.error = error
                } else {
                    let responses = record!["responses"] as! NSArray
                    let newResponses = NSMutableArray()
                    for response in responses {
                        if (response as! String) != self.caption {
                            newResponses.add(response)
                        }
                    }
                    
                    record!["responses"] = newResponses.copy() as! NSArray
                    
                    publicDb.save(record!, completionHandler: ({(save) in
                        print("success")
                    }))
                    
                    
                }
            }))
        }
    }
    
    
    
    
    
    init?(message: MSMessage) {
   
        
        guard let url = message.url else {
            return nil
        }
    
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
    
        
        guard let qItems = components.queryItems else {
            return nil
        }
        
        var rID : String?
        var sID : String?
  
        for item in qItems {
            if item.name == "roundID" {
                guard let roundID = item.value else {
                    return nil
                }
                rID = roundID
            } else if item.name == "senderID" {
                guard let senderID = item.value else {
                    return nil
                }
                sID = senderID
            } else {
                continue
            }
            
            
 
        }
        
        
        guard let roundID = rID else {
            return nil
        }
        
        guard let senderID = sID else {
            return nil
        }
        
        self.roundID = roundID
        self.senderID = senderID
        
      
    }
    

    

    init(){
        roundID = ""
        senderID = ""
    }
    
    func deleteImage(){
        let recordID = CKRecordID(recordName: self.roundID)
        
        let publicDB = CKContainer.default().publicCloudDatabase
        publicDB.delete(withRecordID: recordID, completionHandler: ({(record, error) in
            if let error = error {
                print(error)
            } else {
                print("success")
            }
        }))
    }
    
    
    
    func saveImage(){
        count += 1
        self.caption = "Starting Round.."
        self.cancelAction = self.deleteImage
        
        if self.image != nil {
            let searchPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documents = searchPaths.first
            
            guard let docPath = documents else {
                fatalError("Documents Path not found")
            }
            
            let imagePath = docPath.appendingPathComponent("round.png")
            
            guard let imageData = UIImagePNGRepresentation(image!) else {
                fatalError("Could not get image data")
            }
            
            try? imageData.write(to: imagePath)
            
            print(roundID)
            
            let roundRecordID = CKRecordID(recordName: roundID)
            let roundRecord = CKRecord(recordType: "Round", recordID: roundRecordID)
            
            
            let imageAsset = CKAsset(fileURL: imagePath)
            roundRecord["image"] = imageAsset
            roundRecord["responses"] = [""] as NSArray
            
            let myContainer = CKContainer.default()
            let publicDatabase = myContainer.publicCloudDatabase
            publicDatabase.save(roundRecord, completionHandler: {(record, error) in
                if let error = error {
                    print("failed")
                    print(error)
                    self.error = error
                } else {
                    print(self.roundID)
                }
                
              
            })
        }
    }

 
    

}
