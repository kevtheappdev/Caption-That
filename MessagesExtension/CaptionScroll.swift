
//
//  CaptionScroll.swift
//  Caption That
//
//  Created by Kevin Turner on 6/7/17.
//  Copyright © 2017 Kevin Turner. All rights reserved.
//

import UIKit

protocol CaptionScrollDataSource : class {
    func CaptionScrollCard(atIndex index: Int) -> CaptionCard
    func numberOfCaptions() -> Int
}

class CaptionScroll: UIScrollView {
    var cards = [CaptionCard]()

    weak var datasource : CaptionScrollDataSource? {
        didSet {
            reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
   
    }
    
    
    private func clearCards(){
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    func reloadData(){
        clearCards()
        
        var i = 0
        guard let total = self.datasource?.numberOfCaptions() else {
            return
        }
        
        var offset = 50
        repeat {
            if let datasource = self.datasource {
                let card = datasource.CaptionScrollCard(atIndex: i)
                card.frame = CGRect(origin: CGPoint(x: offset, y: 30), size: card.frame.size)
                offset = offset + Int(card.frame.size.width) + 50
                
                self.addSubview(card)
            } else {
                return
            }
            
            i += 1
            
        } while i < total
        
        self.contentSize = CGSize(width: CGFloat(offset), height: self.frame.size.height)
    }
    

}
