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

struct CaptionPhotoMessage {
    var roundID : String
    var senderID : String
    var image : UIImage?
    var message : MSMessage?
    
    
    
    init?(message: MSMessage) {
        self.message = message
        
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

}
