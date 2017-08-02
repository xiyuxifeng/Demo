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
import MobileCoreServices
 
class ViewController: UIViewController {

    @IBOutlet weak var isUseCustomOverlayView: UISwitch!
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
    @IBOutlet weak var photoLibiaryBtn: UIBarButtonItem!
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    @IBOutlet weak var captureMovieBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!

    var timer: Timer?
    var captureImages = [UIImage]()
    var imagePickerViewController: UIImagePickerController?
    var player: AVPlayer? // 预览视频
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 判断当前的设备是否支持拍照和相册
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            cameraBtn.isEnabled = false
            captureMovieBtn.isEnabled = false
        }
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            photoLibiaryBtn.isEnabled = false
            saveBtn.isEnabled = false
        }
        
        /*
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            photoLibiaryBtn.isEnabled = false
            saveBtn.isEnabled = false
        }*/
    }
    
    // 相册
    @IBAction func showPhotos(_ sender: UIBarButtonItem) {
//        showImagePicker(sourceType: .savedPhotosAlbum, from: sender)
        showImagePicker(sourceType: .photoLibrary, from: sender)
    }

    // 相机
    @IBAction func takePhotos(_ sender: UIBarButtonItem) {
        
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            if !availableTypes.contains(kUTTypeImage as String) {
                showAlert(title: "错误", msg: "相机不支持拍照")
                return
            }
        }
        
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
    
    func showImagePicker(sourceType: UIImagePickerControllerSourceType, from: UIBarButtonItem, isMovie: Bool = false) {
        if imageView.isAnimating {
            imageView.stopAnimating()
        }
        
        captureImages = []
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = true // 是否允许编辑
        imagePickerController.delegate = self
        
        if sourceType == .camera {
            imagePickerController.modalPresentationStyle = .fullScreen
            if isMovie {
                imagePickerController.mediaTypes = [kUTTypeMovie as String]
                imagePickerController.videoQuality = .typeMedium
                imagePickerController.cameraCaptureMode = .video
                imagePickerController.cameraDevice = .rear
                imagePickerController.videoMaximumDuration = 10
            }
        } else {
            imagePickerController.modalPresentationStyle = .popover
            // 默认只显示照片...
            imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        }
        
        let presentationController = imagePickerController.popoverPresentationController
        presentationController?.barButtonItem = from
        presentationController?.permittedArrowDirections = .any
        
        if isUseCustomOverlayView.isOn {
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
        }
        
        self.imagePickerViewController = imagePickerController
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // 录像
    @IBAction func captureMovie(_ sender: UIBarButtonItem) {
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            if !availableTypes.contains(kUTTypeMovie as String) {
                showAlert(title: "错误", msg: "相机不支持录像")
                return
            }
        }
        
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
                    self?.showImagePicker(sourceType: .camera, from: sender, isMovie: true)
                }
            })
        case.authorized:
            showImagePicker(sourceType: .camera, from: sender, isMovie: true)
        }
    }
    
    // 保存到相册
    @IBAction func saveToRollAlbum(_ sender: UIBarButtonItem) {
        var image: UIImage? = imageView.image
        
        if let ig = imageView.animationImages?.first {
            image = ig
        }

        if image != nil {
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(ViewController.image(image:didFinishSavingWithError:contextInfo:)), nil)
        }
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
   
    func finishAndShowImages(isImage: Bool = true) {
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
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            if mediaType == kUTTypeImage as String {
                // 如果是照片的话先显示 在手动保存
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    captureImages.append(image)
                }
                
                if timer?.isValid == true {
                    return
                }
                
                if let dict = info[UIImagePickerControllerMediaMetadata] as? NSDictionary {
                    print(dict)
                }
            } else if mediaType == kUTTypeMovie as String {
                if let url = info[UIImagePickerControllerMediaURL] as? URL { //视频路径
                    if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
                        // 如果是视频的话直接保存
                        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(ViewController.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }
            }
            
            finishAndShowImages()
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func video(videoPath: String, didFinishSavingWithError: Error?, contextInfo: UnsafeMutableRawPointer?) {
        if didFinishSavingWithError != nil {
            showAlert(title: "失败", msg: didFinishSavingWithError!.localizedDescription)
        } else {
            showAlert(title: "成功", msg: "保存视频成功")
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError: Error?, contextInfo: UnsafeMutableRawPointer?) {
        if didFinishSavingWithError != nil {
            showAlert(title: "失败", msg: didFinishSavingWithError!.localizedDescription)
        } else {
            showAlert(title: "成功", msg: "保存照片成功")
        }
    }
    
    func showAlert(title: String, msg: String) {
        let alertViewController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
        })
        alertViewController.addAction(cancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
}

