//
//  StartRoundViewController.swift
//  Caption That
//
//  Created by Kevin Turner on 5/29/17.
//  Copyright © 2017 Kevin Turner. All rights reserved.
//



protocol StartRoundViewControllerDelegate {
    func selectedImage(_ image: UIImage)
}

import UIKit
import Photos

class StartRoundViewController: UIViewController  {

    @IBOutlet var collectionView: UICollectionView!
    var assets : PHFetchResult<PHAsset>!
    var selectedImage : PHAsset?
    var selectedIndex : IndexPath?
    var delegate : StartRoundViewControllerDelegate?
    
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectImageButton.isEnabled = false
        self.previewView.layer.cornerRadius = 100
        self.previewView.clipsToBounds = true
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 115, height: 106)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        self.collectionView.collectionViewLayout = flowLayout
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus) in
                if status == .authorized {
                    self.fetchAssets()
                } else {
                    self.showNeedsAccessMessage()
                }
            })
        } else {
            fetchAssets()
        }
    }
    

    

    @IBAction func selectedImageButtonPressed(_ sender: Any) {
        if self.selectedImage != nil {
            PHImageManager.default().requestImage(for: self.selectedImage!, targetSize: CGSize(width: self.view.bounds.width, height: 0.75 * self.view.bounds.width), contentMode: .aspectFit, options: nil, resultHandler: {(image, info) in
                self.delegate?.selectedImage(image!)
            })
        }
    }
    
    func fetchAssets(){
        self.assets = PHAsset.fetchAssets(with: .image, options: nil)
    }
    
    

    
    func showNeedsAccessMessage(){
        let alert = UIAlertController(title: "Enable Photo acces", message: "You will need to grant access to your photos in order to play this game. Please do so under your phone's settings", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updatePreview(){
        if let asset = selectedImage {
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: self.view.bounds.width, height: 0.75 * self.view.bounds.width), contentMode: .aspectFit, options: nil, resultHandler: {(image, info) in
                 self.previewView.image = image
            } )
        }
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





extension StartRoundViewController : UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let uAsset = assets {
            return uAsset.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! ImageCollectionViewCell

            PHImageManager.default().requestImage(for: (assets?[indexPath.row])!, targetSize: CGSize(width: self.view.bounds.width, height: 0.75 * self.view.bounds.width), contentMode: .aspectFit, options: nil, resultHandler: {(image, info) in
            cell.imageView.image = image
        } )
        
        cell.imageView.layer.cornerRadius = 30
        cell.imageView.clipsToBounds = true
        if selectedIndex != nil && indexPath.row == selectedIndex!.row {
            cell.backgroundColor = #colorLiteral(red: 0.2899873257, green: 0.565610826, blue: 0.8873878121, alpha: 1)
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    

}


extension StartRoundViewController : UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = assets[indexPath.row]
        selectedIndex = indexPath
        updatePreview()
        self.selectImageButton.isEnabled = true
        
        collectionView.reloadData()
    }
}
