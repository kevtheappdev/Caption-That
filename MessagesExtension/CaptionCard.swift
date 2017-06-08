//
//  CaptionCard.swift
//  Caption That
//
//  Created by Kevin Turner on 6/7/17.
//  Copyright © 2017 Kevin Turner. All rights reserved.
//

import UIKit

protocol CaptionCardDelegate : class {
    func tappedCard(withCaption caption: String)
}

class CaptionCard: UIView {
    weak var delegate : CaptionCardDelegate?
    
 
  var label: UILabel
    
    override init(frame: CGRect){
        label = UILabel()
        super.init(frame: frame)
          self.addSubview(label)
        label.numberOfLines = 0
        label.textColor = UIColor.white
        self.backgroundColor = UIColor.black
        self.layer.cornerRadius = 20
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(CaptionCard.tapped))
        self.addGestureRecognizer(tapper)
     
    }
    
    func tapped(){
        self.delegate?.tappedCard(withCaption: self.label.text!)
    }
    
    override func layoutSubviews() {
        label.frame = CGRect(x: 20, y: 0, width: self.frame.size.width - 40, height: self.frame.size.height)
        
        //self.backgroundColor = UIColor.blue
      
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
