
//
//  WaitingViewController.swift
//  Caption That
//
//  Created by Kevin Turner on 6/6/17.
//  Copyright © 2017 Kevin Turner. All rights reserved.
//

import UIKit
import CloudKit

class WaitingViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    var roundID : String? {
        didSet {
            fetchResponses()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingView.startAnimating()
        
    }
    
    
    func fetchResponses(){
        let publicDB = CKContainer.default().publicCloudDatabase
        let roundID = CKRecordID(recordName: self.roundID!)
        
        publicDB.fetch(withRecordID: roundID, completionHandler: ({(record, error) in
            if error == nil {
            let responses = record!["responses"] as! NSArray
                for response in responses {
                    print(response as! String)
                }
            } else {
                print(error!)
            }
        }))
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
