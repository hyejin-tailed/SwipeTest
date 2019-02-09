//
//  CardView.swift
//  SwipeTest
//
//  Created by sini-air on 08/02/2019.
//  Copyright © 2019 sini-air. All rights reserved.
//

let EXCUTE_MARGIN = (UIScreen.main.bounds.size.width/2) * 0.5
let SCALE_STRENGTH : CGFloat = 3
let MIN_SCALE_RANGE : CGFloat = 0.8
let MAX_SCALE_RANGE : CGFloat = 1.2

protocol CardDelegate: AnyObject {
    func moveLeft(card: CardView)
    func moveRight(card: CardView)
}

import UIKit

class CardView: UIView {
    var centerX: CGFloat = 0
    var centerY: CGFloat = 0
    var originalPoint: CGPoint = .zero
    var overlayIcon = UIImageView()
    var isChecked = false
    weak var delegate: CardDelegate?
    
    public init(frame: CGRect, model: CardModel) {
        super.init(frame: frame)
        setData(model)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("required init error")
    }
    
    func setData(_ model:CardModel) {
        layer.cornerRadius = 30
        layer.shadowRadius = 3
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 1, height: 3)
        layer.shadowColor = UIColor.darkGray.cgColor
        clipsToBounds = true
        isUserInteractionEnabled = false
        
        originalPoint = center
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.startDrag))
        addGestureRecognizer(panGestureRecognizer)
        let width = self.frame.size.width
        
        let photoImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: width, height: width))
        photoImageView.image = UIImage(named: model.imageURL)
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true;
        addSubview(photoImageView)
        
        let dateLabel = UILabel(frame:CGRect(x: 20, y: 20, width: width - 40, height: 0))
        dateLabel.text = model.month + " " + model.day
        dateLabel.textColor = .white
        dateLabel.font = UIFont(name: "AppleSDGothicNeo-Regilar", size: 25)
        dateLabel.sizeToFit()
        addSubview(dateLabel)
        
        let titleLabel = UILabel(frame:CGRect(x: 20, y: width - 40, width: width - 40, height: 0))
        titleLabel.text = model.title
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        titleLabel.sizeToFit()
        addSubview(titleLabel)
        
        let profileArea = UIView(frame:CGRect(x: 0, y: width, width: width, height: 100))
        profileArea.backgroundColor = .white
        addSubview(profileArea)
        
        let profileImageView = UIImageView(frame:CGRect(x: 20, y: 10, width: 60, height: 60))
        profileImageView.image = UIImage(named: model.imageURL)
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 30
        profileImageView.clipsToBounds = true
        profileArea.addSubview(profileImageView)
        
        let nameLabel = UILabel(frame:CGRect(x: 100, y: 12, width: width - 100, height: 0))
        nameLabel.text = model.name
        nameLabel.textColor = .black
        nameLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        nameLabel.sizeToFit()
        profileArea.addSubview(nameLabel)
        
        let loacationLabel = UILabel(frame:CGRect(x: 100, y: 40, width: width - 100, height: 0))
        loacationLabel.text = model.location
        loacationLabel.textColor = .gray
        loacationLabel.font = UIFont(name: "AppleSDGothicNeo-Regilar", size: 15)
        loacationLabel.sizeToFit()
        profileArea.addSubview(loacationLabel)
        
        let likeCountLabel = UILabel(frame:CGRect(x: 0, y: 60, width: width - 40, height: 0))
        likeCountLabel.text = "❤️ " + model.commentCount
        likeCountLabel.textColor = .gray
        likeCountLabel.font = UIFont(name: "AppleSDGothicNeo-Regilar", size: 15)
        likeCountLabel.sizeToFit()
        likeCountLabel.frame = CGRect(x: width - likeCountLabel.frame.size.width - 20, y: 60, width: likeCountLabel.frame.size.width, height: likeCountLabel.frame.size.height)
        profileArea.addSubview(likeCountLabel)
        
        overlayIcon = UIImageView(frame:CGRect(x: 0, y: 0, width: width, height: width))
        overlayIcon.alpha = 0
        addSubview(overlayIcon)
    }
    
    @objc func startDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
        centerX = gestureRecognizer.translation(in: self).x
        centerY = gestureRecognizer.translation(in: self).y
        switch gestureRecognizer.state {
        case .began:
            originalPoint = self.center;
            break;
        case .changed:
            let rotationStrength = min(centerX / UIScreen.main.bounds.size.width, 1)
            let rotationAngel = .pi/6 * rotationStrength
            let scale = max(1 - abs(rotationStrength) / SCALE_STRENGTH, MIN_SCALE_RANGE)
            center = CGPoint(x: originalPoint.x + centerX, y: originalPoint.y + centerY)
            let transforms = CGAffineTransform(rotationAngle: rotationAngel)
            let scaleTransform: CGAffineTransform = transforms.scaledBy(x: scale, y: scale)
            self.transform = scaleTransform
            updateOverlay(centerX)
            break;
        case .ended:
            afterSwipeAction()
            break;
            
        case .possible:break
        case .cancelled:break
        case .failed:break
        }
    }
    func updateOverlay(_ distance: CGFloat) {
        overlayIcon.image = distance > 0 ? #imageLiteral(resourceName: "checkOverlay") : #imageLiteral(resourceName: "skipOverlay")
        overlayIcon.alpha = min(abs(distance) / 100, 0.5)
    }
    
    func afterSwipeAction() {
        if centerX > EXCUTE_MARGIN {
            rightAction()
        } else if centerX < -EXCUTE_MARGIN {
            leftAction()
        } else {
            self.center = self.originalPoint
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [], animations: {
                self.transform = CGAffineTransform(rotationAngle: 0)
                self.overlayIcon.alpha = 0
            })
        }
    }
    
    func rightAction() {
        let finishPoint = CGPoint(x: frame.size.width*2, y: 2 * centerY + originalPoint.y)
        UIView.animate(withDuration: 0.3, animations: {
            self.center = finishPoint
        }, completion: {(_) in
            self.removeFromSuperview()
        })
        isChecked = true
        delegate?.moveRight(card: self)
    }
    
    func leftAction() {
        let finishPoint = CGPoint(x: -frame.size.width * 2, y: 2 * centerY + originalPoint.y)
        UIView.animate(withDuration: 0.3, animations: {
            self.center = finishPoint
        }, completion: {(_) in
            self.removeFromSuperview()
        })
        isChecked = false
        delegate?.moveLeft(card: self)
    }
    
    func rightClickAction() {
        overlayIcon.image = #imageLiteral(resourceName: "checkOverlay")
        let finishPoint = CGPoint(x: center.x + frame.size.width * 2, y: center.y)
        overlayIcon.alpha = 0.5
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: 1)
            self.overlayIcon.alpha = 1.0
        }, completion: {(_ complete: Bool) -> Void in
            self.removeFromSuperview()
        })
        isChecked = true
        delegate?.moveRight(card: self)
    }
    
    func leftClickAction() {
        overlayIcon.image = #imageLiteral(resourceName: "skipOverlay")
        let finishPoint = CGPoint(x: center.x - frame.size.width * 2, y: center.y)
        overlayIcon.alpha = 0.5
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: -1)
            self.overlayIcon.alpha = 1.0
        }, completion: {(_ complete: Bool) -> Void in
            self.removeFromSuperview()
        })
        isChecked = false
        delegate?.moveLeft(card: self)
    }
    
    func makeUndoAction() {
        overlayIcon.image = isChecked ? #imageLiteral(resourceName: "checkOverlay") : #imageLiteral(resourceName: "skipOverlay")
        overlayIcon.alpha = 1.0
        self.alpha = 0
        self.center = self.originalPoint
        let transforms = CGAffineTransform(rotationAngle: 0)
        let scaleTransform: CGAffineTransform = transforms.scaledBy(x: MAX_SCALE_RANGE, y: MAX_SCALE_RANGE)
        self.transform = scaleTransform
        self.overlayIcon.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.alpha = 1
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        })
    }
    
    func rollBackCard(){
        UIView.animate(withDuration: 0.3) {
            self.removeFromSuperview()
        }
    }

}
