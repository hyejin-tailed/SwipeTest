//
//  ViewController.swift
//  SwipeTest
//
//  Created by sini-air on 08/02/2019.
//  Copyright © 2019 sini-air. All rights reserved.
//

let  MAX_CARD_STACK = 3;
let  SEPERATOR_Y_DISTANCE = 6;

typealias cardDataTP = (month: String, day: String, title: String, name: String, location: String, commentCount: String, imageURL: String)

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var swipeViewArea: UIView!
    var currentIndex = 0
    var currentCardsArray = [CardView]()
    var allCardsArray = [CardView]()
    var cardDatas: [CardModel] {
        var temp = [CardModel]()
        for i in 0..<9 {
            let day = "" + String(i + 1)
            let title = "Title " + String(i)
            let name = "Name " + String(i)
            let commentCount = String(i)
            let imageURL = "img" + String(i)
            let location = "My Camera" + String(i)
            temp.append(CardModel((month: "Jan", day: day, title: title, name: name, location: location, commentCount: commentCount, imageURL: imageURL)))
        }
        return temp
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.layoutIfNeeded()
        loadCards()
    }
    
    func loadCards() {
        if cardDatas.count > 0 {
            let stackCount = (cardDatas.count > MAX_CARD_STACK) ? MAX_CARD_STACK : cardDatas.count
            for ( i, model ) in cardDatas.enumerated() {
                let newCard = makeCard(at: i, model: model)
                allCardsArray.append(newCard)
                if i < stackCount {
                    currentCardsArray.append(newCard)
                }
            }
            
            for ( i, _ ) in currentCardsArray.enumerated() {
                if i > 0 {
                    swipeViewArea.insertSubview(currentCardsArray[i], belowSubview: currentCardsArray[i - 1])
                }else {
                    swipeViewArea.addSubview(currentCardsArray[i])
                }
            }
            cardAnimate()
        }
    }
    
    func makeCard(at index: Int , model :CardModel) -> CardView {
        let card = CardView(frame: CGRect(x: 0, y: 0, width: swipeViewArea.frame.size.width , height: swipeViewArea.frame.size.height) ,model : model)
        card.delegate = self
        return card
    }
    
    func cardAnimate() {
        for (i,card) in currentCardsArray.enumerated() {
            UIView.animate(withDuration: 0.3, animations: {
                if i == 0 {
                    card.isUserInteractionEnabled = true
                }
                var frame = card.frame
                frame.origin.y = CGFloat(i * SEPERATOR_Y_DISTANCE)
                card.frame = frame
            })
        }
    }
    
    @IBAction func didTapUnCheck (_ sender: Any) {
        currentCardsArray.first?.leftClickAction()
    }
    
    @IBAction func didTapCheck(_ sender: Any) {
        currentCardsArray.first?.rightClickAction()
    }
    
    @IBAction func didTapUndo (_ sender: Any) {
        if currentIndex > 0 {
            currentIndex =  currentIndex - 1
            if currentCardsArray.count == MAX_CARD_STACK {
                currentCardsArray.last?.rollBackCard()
                currentCardsArray.removeLast()
            }
            let undoCard = allCardsArray[currentIndex]
            undoCard.layer.removeAllAnimations()
            swipeViewArea.addSubview(undoCard)
            undoCard.makeUndoAction()
            currentCardsArray.insert(undoCard, at: 0)
            cardAnimate()
        }
    }
    
    func removeAndAdd() {
        currentCardsArray.remove(at: 0)
        currentIndex = currentIndex + 1
        
        if (currentIndex + currentCardsArray.count) < allCardsArray.count {
            let card = allCardsArray[currentIndex + currentCardsArray.count]
            var frame = card.frame
            frame.origin.y = CGFloat(MAX_CARD_STACK * SEPERATOR_Y_DISTANCE)
            card.frame = frame
            currentCardsArray.append(card)
            swipeViewArea.insertSubview(currentCardsArray[MAX_CARD_STACK - 1], belowSubview: currentCardsArray[MAX_CARD_STACK - 2])
        }
        
        cardAnimate()
    }
}

extension ViewController : CardDelegate{
    func moveLeft(card: CardView) {
        removeAndAdd()
    }
    func moveRight(card: CardView) {
        removeAndAdd()
    }
}

