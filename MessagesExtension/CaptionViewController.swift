//
//  CaptionViewController.swift
//  Caption That
//
//  Created by Kevin Turner on 6/6/17.
//  Copyright © 2017 Kevin Turner. All rights reserved.
//

import UIKit
import CloudKit
import Messages

protocol CaptionViewControllerDelegate : class {
    func captionSelected(withImage image: UIImage)
}

class CaptionViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    weak var delegate : CaptionViewControllerDelegate?
    var cpm : CaptionPhotoMessage?{
        didSet {
            fetchImage(withID: cpm!.roundID)
        }
    }
    
    var currentRound : CKRecord?
    
    let captions = ["When he nut in yo eye", "When the acid finally kicks in", "When you feeling really good about yourself but then you look in the mirror", "Funny joke"]

    @IBOutlet weak var scrollView: CaptionScroll!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.datasource = self 
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchImage(withID id: String){
        let publicDB = CKContainer.default().publicCloudDatabase
        let roundID = CKRecordID(recordName: id)
        
        publicDB.fetch(withRecordID: roundID, completionHandler: {(record, error) in
            if let error = error {
                print(error)
            } else {
                let asset = record!["image"] as! CKAsset
                let imageData = try! Data(contentsOf: asset.fileURL)
                self.currentRound = record
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    // Update UI
                    self.imageView.image = image
                }
           }
        })
    }
  
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CaptionViewController : CaptionScrollDataSource
{
    func numberOfCaptions() -> Int {
        return 3
    }
    
    func CaptionScrollCard(atIndex index: Int) -> CaptionCard {
        
        let card = CaptionCard()
                card.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
       
        card.label.text = captions[index]
        card.delegate = self
       
        return card
    }
}


extension CaptionViewController : CaptionCardDelegate
{
    func tappedCard(withCaption caption: String) {
        if let round = self.currentRound {
            let responses = round["responses"] as! NSArray
            var newResponses : NSArray
            if responses[0] as! String == "" {
                newResponses = [caption] as NSArray
            } else {
                newResponses = responses.adding(caption) as NSArray
            }
            
            round["responses"] = newResponses
            
            let publicDb = CKContainer.default().publicCloudDatabase
            publicDb.save(round, completionHandler: {(saved, error) in
                if let error = error {
                    print(error)
                    let alert = UIAlertController(title: "Cannot Load response", message: "Something went wrong as we tried to send your response. Please check your internet connection later and try again later.", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                } else {
                 print("Success")
                }
                
                self.delegate?.captionSelected(withImage: self.imageView.image!)
            })
            
            
        }

        
    }
}
