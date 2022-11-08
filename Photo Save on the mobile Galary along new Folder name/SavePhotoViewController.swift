//
//  SavePhotoViewController.swift
//  PhotoEditorForPassport
//
//  Created by Pawan iOS on 17/10/2022.]
//

import UIKit
import Photos
import Foundation
import GoogleMobileAds

class SavePhotoViewController: UIViewController {
    
    // MARK: - IBOutlets, Variables & Constants
    @IBOutlet weak var slider       : UISlider!
    @IBOutlet weak var pngLabel     : UILabel!
    @IBOutlet weak var jpgLabel     : UILabel!
    @IBOutlet weak var imageSize    : UILabel!
    @IBOutlet weak var bottomView   : UIView!
    @IBOutlet weak var jpgButton    : UIButton!
    @IBOutlet weak var pngButton    : UIButton!
    @IBOutlet weak var centralView  : UIView!
    @IBOutlet weak var saveButton   : UIButton!
    @IBOutlet weak var saveImage    : UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveImageView: UIVisualEffectView!
    @IBOutlet weak var mobAdView: UIView!
    
    var imageType                   : String?
    var finalImage                  : UIImage?
    var sliderValueBeforeSet        : Int?
    var imageSizeForResize          : CGSize?
    var folderName                  = "Passport Photo"
    var imagesArray                 = [UIImage]()
    
    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isOpaque = false
        view.backgroundColor = .clear
        mobAdView.backgroundColor = .clear
        
        pngButton.isSelected = true
        centralView.layer.cornerRadius = 50
        saveImage.image = finalImage
        centralView.layer.masksToBounds = true
        
        pngButton.setImage(UIImage(named: "Group 33507"), for: .normal)
        pngButton.setImage(UIImage(named: "Group 33506"), for: .selected)
        
        jpgButton.setImage(UIImage(named: "Group 33507"), for: .normal)
        jpgButton.setImage(UIImage(named: "Group 33506"), for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        OpenAds.SharedInstance.appOpenBool = true
        GoogleAdsMethods.sharedIntance.delegate = self
        GoogleAdsMethods.sharedIntance.loadNativeAd()
        
    }
    // MARK: - IBActions
    
    @IBAction func exitActionButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        sliderValueBeforeSet = Int(sender.value)
        imageSize.text = "\(sliderValueBeforeSet!) Kb"
        
    }
    
    @IBAction func pngButtonAction(_ sender: UIButton) {
        imageType = "png"
        if pngButton.isSelected {
            pngButton.isSelected = false
            jpgButton.isSelected = true
            pngLabel.textColor = UIColor(red: 0.514, green: 0.529, blue: 0.533, alpha: 1)
            jpgLabel.textColor = UIColor(red: 0.29, green: 0.616, blue: 1, alpha: 1)
        } else {
            pngButton.isSelected = true
            pngLabel.textColor = UIColor(red: 0.29, green: 0.616, blue: 1, alpha: 1)
            jpgLabel.textColor = UIColor(red: 0.514, green: 0.529, blue: 0.533, alpha: 1)
            jpgButton.isSelected = false
        }
    }
    
    @IBAction func jpgButtonAction(_ sender: UIButton) {
        imageType = "jpg"
        if jpgButton.isSelected {
            jpgButton.isSelected = false
            pngButton.isSelected = true
            jpgLabel.textColor = UIColor(red: 0.514, green: 0.529, blue: 0.533, alpha: 1)
            pngLabel.textColor = UIColor(red: 0.29, green: 0.616, blue: 1, alpha: 1)
        } else {
            jpgButton.isSelected = true
            pngButton.isSelected = false
            jpgLabel.textColor = UIColor(red: 0.29, green: 0.616, blue: 1, alpha: 1)
            pngLabel.textColor = UIColor(red: 0.514, green: 0.529, blue: 0.533, alpha: 1)
        }
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        let imageName =  nameTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        if imageName!.isEmpty == true {
            alertMessage(Message: "Couldn't set image Name")
            nameTextField.text?.removeAll()
        } else {
            let sliderValue = sliderValueBeforeSet ?? 200
            
            imageSizeForResize = CGSize(width: sliderValue, height: sliderValue)
            
            finalImage = finalImage?.resizeImage(size: imageSizeForResize)
            if createAlbum() == true {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                if Reachability.isConnectedToNetwork() {
                    GoogleAdsMethods.sharedIntance.interstitialDelegate = self
                if GoogleAdsMethods.sharedIntance.interstitialAd != nil {
                    GoogleAdsMethods.sharedIntance.interstitialAd?.present(fromRootViewController: self)
                    }
                } else {
                    let photoGalleryViewController = PhotoGalleryViewController()
                    photoGalleryViewController.modalPresentationStyle = .fullScreen
                    photoGalleryViewController.galleryImagesArry = self.imagesArray
                    self.present(photoGalleryViewController, animated: true, completion: nil)
                }
                
//                }
                
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func createAlbum() -> Bool {
        SDPhotosHelper.createAlbum(withTitle: self.folderName) { (success, error) in
            if success {
                print("Created album : \(self.folderName)")
            } else {
                if let error = error {
                    print("Error in creating album : \(error.localizedDescription)")
                }
            }
        }
       return true
    }
    
    private func saveImageForGallery() {
        
        guard let image = self.finalImage else {
            print("Couldn't get image")
            return
        }
        
        SDPhotosHelper.addNewImage(image, toAlbum: self.folderName, onSuccess: { [self] ( identifier) in
            print("Saved image successfully, identifier is \(identifier)")
            imagesArray.append(image)
            
        }) { (error) in
            if let error = error {
                print("Error in creating album : \(error.localizedDescription)")
            }
        }
    }
    
    private func alertMessage( Message: String ) {
        let alert = UIAlertController(title: "Alert", message: Message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension UIImage {
        func resizeImage(size: CGSize!) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in:rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

extension SavePhotoViewController: GoogleNativeAdProtocal {
    func didDisplayNativeAd(nativeAdView: GADNativeAdView, adHeight: CGFloat) {
        self.mobAdView.addNativeAdd(nativeAdView: nativeAdView, adInTableView: false)
    }
    
    func didDisplayingBannerAd(bannerAdView: GADBannerView, adHeight: CGFloat) {
        self.mobAdView.addBannerAdd(bannerAdView: bannerAdView)
    }
    
    func adLoaderFial(didFailToReceiveAdWithError error: Error) {
    }
}

extension SavePhotoViewController: GoogleInterstitialAdProtocol {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        GoogleAdsMethods.sharedIntance.loadInterstitialAd()
        self.saveImageForGallery()
        let photoGalleryViewController = PhotoGalleryViewController()
        photoGalleryViewController.modalPresentationStyle = .fullScreen
        photoGalleryViewController.galleryImagesArry = self.imagesArray
        self.present(photoGalleryViewController, animated: true, completion: nil)
        
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        GoogleAdsMethods.sharedIntance.loadInterstitialAd()
        self.saveImageForGallery()
        let photoGalleryViewController = PhotoGalleryViewController()
        photoGalleryViewController.modalPresentationStyle = .fullScreen
        photoGalleryViewController.galleryImagesArry = self.imagesArray
        self.present(photoGalleryViewController, animated: true, completion: nil)
    }
}
