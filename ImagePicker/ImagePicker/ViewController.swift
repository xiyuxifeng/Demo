 //
//  ViewController.swift
//  ImagePicker
//
//  Created by WangHui on 2017/8/1.
//  Copyright © 2017年 WangHui. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toobar: UIToolbar!
    @IBOutlet weak var delayStep: UIStepper!
    @IBOutlet weak var timerStep: UIStepper!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var takeBtn: UIButton!
    @IBOutlet weak var timerTakeBtn: UIButton!
    @IBOutlet weak var delayBtn: UIButton!
   
    var timer: Timer?
    var captureImages = [UIImage]()
    var imagePickerViewController: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 判断当前的设备是否支持拍照和相册
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            if let toolBarItems = toobar.items, toolBarItems.count > 2 {
                var newItems = Array.init(toolBarItems)
                newItems.remove(at: 2)
                toobar.setItems(newItems, animated: false)
            }
        }
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            if let toolBarItems = toobar.items, toolBarItems.count >= 1 {
                var newItems = Array.init(toolBarItems)
                newItems.remove(at: 0)
                toobar.setItems(newItems, animated: false)
            }
        }
    }
    
    // 相册
    @IBAction func showPhotos(_ sender: UIBarButtonItem) {
        showImagePicker(sourceType: .photoLibrary, from: sender)
    }

    // 相机
    @IBAction func takePhotos(_ sender: UIBarButtonItem) {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .restricted, .denied:
            let alertViewController = UIAlertController(title: "不能访问相机", message: "请在设置->隐私->相机中设置允许此程序访问相机", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: { (_) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            })
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            })
            
            alertViewController.addAction(okAction)
            alertViewController.addAction(cancel)
            self.present(alertViewController, animated: true, completion: nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {[weak self] (allow) in
                if allow {
                    self?.showImagePicker(sourceType: .camera, from: sender)
                }
            })
        case.authorized:
            showImagePicker(sourceType: .camera, from: sender)
        }
    }
    
    
    func showImagePicker(sourceType: UIImagePickerControllerSourceType, from: UIBarButtonItem) {
        if imageView.isAnimating {
            imageView.stopAnimating()
        }
        
        captureImages = []
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self
//        imagePickerController.cameraCaptureMode = .video
//        imagePickerController.mediaTypes

        if sourceType == .camera {
            imagePickerController.modalPresentationStyle = .fullScreen
        } else {
            imagePickerController.modalPresentationStyle = .popover
        }
        
        let presentationController = imagePickerController.popoverPresentationController
        presentationController?.barButtonItem = from
        presentationController?.permittedArrowDirections = .any
        
        if sourceType == .camera {
            imagePickerController.showsCameraControls = false 
            
            // 可以使用自定义的cameraOverlayView
            Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)
            
            delayStep.addTarget(self, action: #selector(delayChange), for: .valueChanged)
            timerStep.addTarget(self, action: #selector(timeChange), for: .valueChanged)

            // load overlayView
            if let frm = imagePickerController.cameraOverlayView?.frame {
                overlayView.frame = frm
            }
            imagePickerController.cameraOverlayView = overlayView
            overlayView = nil
        }
        
        self.imagePickerViewController = imagePickerController
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: - Overlay View Action
    
    func delayChange(step: UIStepper) {
        delayLabel.text = "\(step.value)"
    }
    
    func timeChange(step: UIStepper) {
        timerLabel.text = "\(step.value)"
    }
    
    @IBAction func done(_ sender: UIButton) {
        if timer?.isValid == true {
            timer?.invalidate()
            timer = nil
        }
        finishAndShowImages()
    }
    
    @IBAction func snap(_ sender: UIButton) {
        imagePickerViewController?.takePicture()
    }
    
    @IBAction func delaySnap(_ sender: UIButton) {
        
        doneBtn.isEnabled = false
        takeBtn.isEnabled = false
        delayBtn.isEnabled = false
        timerTakeBtn.isEnabled = false
        
        //  cannot be used until take photo
        imagePickerViewController?.cameraOverlayView?.isUserInteractionEnabled = false
        let fireDate = Date(timeIntervalSinceNow: delayStep.value)
        timer = Timer(fire: fireDate, interval: 1.0, repeats: false, block: { [weak self](_) in
            self?.imagePickerViewController?.takePicture()
            self?.doneBtn.isEnabled = true
        })
        RunLoop.main.add(timer!, forMode: .defaultRunLoopMode)
    }
    
    @IBAction func timerSnap(_ sender: UIButton) {
        doneBtn.isEnabled = false
        takeBtn.isEnabled = false
        delayBtn.isEnabled = false
        timerTakeBtn.isEnabled = false
        
        timer = Timer.scheduledTimer(withTimeInterval: timerStep.value, repeats: true, block: {[weak self] (_) in
            if self?.captureImages.count == 10 {
               return // take max 10 pictures
            }
            self?.imagePickerViewController?.takePicture()
            self?.doneBtn.isEnabled = true
        })
        timer?.fire()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    func finishAndShowImages() {
        if captureImages.count > 0 {
            // only one image
            if captureImages.count == 1 {
                imageView.image = captureImages.first
            } else {
                // mulit images
                imageView.animationImages = captureImages
                imageView.animationDuration = 2.0
                imageView.animationRepeatCount = 0
                imageView.startAnimating()
            }
        }
        
        dismiss(animated: true, completion: nil)

        // clear for next use
        captureImages = []
        imagePickerViewController = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            captureImages.append(image)
        }
        
        if timer?.isValid == true {
            return
        }
        
        if let dict = info[UIImagePickerControllerMediaMetadata] as? NSDictionary {
            print(dict)
        }
        
        finishAndShowImages()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

