//
//  SwipeView.swift
//  SwipeView
//
//  Created by WangHui on 2017/4/7.
//  Copyright © 2017年 WangHui. All rights reserved.
//

import UIKit

enum DeleteType: Int {
    case label = 1, image
}

@IBDesignable class SwipeView: UIView {

    let infoViewTag: Int = 999888 // subView 不要使用这个tag 这个tag对应的View会被添加到conV上
    
    fileprivate var sWide: CGFloat = 85 //滑动宽度
    fileprivate var initCenter: CGPoint = CGPoint.zero //起始中心位置
    fileprivate var panGesture: UIPanGestureRecognizer!
    fileprivate var tapGesture2: UITapGestureRecognizer!
    
    fileprivate var conV: UIView!  // 滑动前展示页面视图
    
    fileprivate var swipV: UIView! // 滑动出来的视图
    fileprivate var tapGesture: UITapGestureRecognizer! // 滑动视图点击手势
    
    fileprivate var imageView: UIImageView! // swipV的子视图
    fileprivate var label: UILabel! // swipV的子视图
    
    fileprivate var startSwipeBlock: ((_ view: SwipeView) -> Void)? // 开始滑动的block
    fileprivate var endSwipeBlock: ((_ view: SwipeView) -> Void)? // 结束滑动的block
    
    fileprivate var deleteBlock: (() -> Void)? // 点击滑动出来的View
    
    @IBInspectable var deleteType: Int = DeleteType.label.rawValue {
        didSet {
            if deleteType == DeleteType.image.rawValue {
                imageView.isHidden = false
                label.isHidden = true
            } else {
                imageView.isHidden = true
                label.isHidden = false
            }
        }
    }
    
    @IBInspectable var title: String = NSLocalizedString("Delete", comment: "") {
        didSet {
            label.text = title
        }
    }
    
    @IBInspectable var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    @IBInspectable var conVBgColor: UIColor = UIColor.white {
        didSet {
            conV.backgroundColor = conVBgColor
        }
    }
    
    // 是否已滑动出去
    var state: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // 处理特定的View 将其添加到conV上 对于已经画好的XIB
        if let infoView = viewWithTag(infoViewTag) {
            conV.addSubview(infoView)
            infoView.snp.makeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets.zero)
            })
        }
    }
    
    fileprivate func setUI() {
        
        backgroundColor = UIColor.clear
        
        conV = UIView(frame: CGRect.zero)
        conV.backgroundColor = UIColor.cyan
        
        swipV = UIView(frame: CGRect.zero)
        swipV.backgroundColor = UIColor.red
        
        imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .center
        
        label = UILabel(frame: CGRect.zero)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
        label.textAlignment = .center
        
        label.text = title
        imageView.image = image
        
        addSubview(swipV)
        addSubview(conV)

        swipV.addSubview(imageView)
        swipV.addSubview(label)
        
        conV.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }

        swipV.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(0)
            make.width.equalTo(sWide)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        label.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        deleteType = DeleteType.label.rawValue

        // 拖动conV
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        panGesture.delegate = self
        
        // 点击conV
        tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(goBack))
        tapGesture2.delegate = self
        
        // 点击swipV
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.delegate = self
        
        conV.addGestureRecognizer(panGesture)
        conV.addGestureRecognizer(tapGesture2)
        
        swipV.addGestureRecognizer(tapGesture)
        
        setCornerRadius([self], radius: 10)
    }
    
    func startSwipe(_ block: @escaping (_ view: SwipeView) -> Void) -> Self {
        startSwipeBlock = block
        return self
    }
    
    func endSwipe(_ block: @escaping (_ view: SwipeView) -> Void) -> Self {
        endSwipeBlock = block
        return self
    }
    
    func tap(_ block: @escaping () -> Void) -> Self {
        deleteBlock = block
        return self
    }

    // 取消滑动状态
    func goBack() {
        if state {
            UIView.animate(withDuration: 0.2, animations: {
                self.conV.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
            }, completion: { (_) in
                self.state = false
            })
        }
    }
}

// MARK: - 手势
extension SwipeView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer && gestureRecognizer.view === conV {
            let pan = gestureRecognizer as! UIPanGestureRecognizer
            let vel = pan.velocity(in: conV)
            
            if fabs(vel.x) > fabs(vel.y) {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    
    func panAction(_ gesture: UIPanGestureRecognizer) {
        
        let directionPoint = gesture.velocity(in: conV)
        var tranPoint = gesture.translation(in: conV)
        
        switch gesture.state {
        case .began:
            startSwipeBlock?(self)
            initCenter = conV.center
        case .changed:
            // 横向滑动时
            if fabs(directionPoint.y) < fabs(directionPoint.x) {
                if state == false {
                    if -tranPoint.x > sWide {
                        // 向左滑动 划出的时候
                        tranPoint.x = -sWide
                    } else if tranPoint.x > 0 {
                        // 向右滑动 
                        tranPoint.x = 0
                    }
                    conV.center = CGPoint(x: initCenter.x + tranPoint.x, y: initCenter.y)
                } else {
                    // 滑回去
                    if tranPoint.x < 0 {
                        tranPoint.x = 0
                    } else if tranPoint.x > sWide {
                        tranPoint.x = sWide
                    }
                    conV.center = CGPoint(x: initCenter.x + tranPoint.x, y: initCenter.y)
                }
            }
        default:
            if state == false {
                if -tranPoint.x > sWide / 3 { // 滑出去
                    UIView.animate(withDuration: 0.2, animations: {
                        self.conV.center = CGPoint(x: self.initCenter.x - self.sWide, y: self.initCenter.y)
                    }, completion: { (_) in
                        self.state = true
                        self.endSwipeBlock?(self)
                    })
                } else { // 滑回去
                    UIView.animate(withDuration: 0.2, animations: { 
                        self.conV.center = self.initCenter
                    }, completion: { (_) in
                        self.state = false
                        self.endSwipeBlock?(self)
                    })
                }
            } else {
                //滑动回去
                UIView.animate(withDuration: 0.2, animations: {
                    self.conV.center = CGPoint(x: self.initCenter.x + self.sWide, y: self.initCenter.y)
                }, completion: { (_) in
                    self.state = false
                    self.endSwipeBlock?(self)
                })
            }
        }
    }
    
    func tapAction(_ gesture: UITapGestureRecognizer) {
        print("tap")
        deleteBlock?()
    }
}

// MARK: - Helper Method
extension SwipeView {
    fileprivate func setCornerRadius(_ views: [UIView], radius: CGFloat) {
        for v in views {
            v.layer.shouldRasterize = true
            v.layer.rasterizationScale = UIScreen.main.scale
            v.layer.cornerRadius = radius
            v.layer.masksToBounds = true
        }
    }
}
