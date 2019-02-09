//
//  CardModel.swift
//  SwipeTest
//
//  Created by sini-air on 08/02/2019.
//  Copyright © 2019 sini-air. All rights reserved.
//


struct CardModel {
    var month: String
    var day: String
    var title: String
    var name: String
    var location: String
    var commentCount: String
    var imageURL: String
    
    init(_ tp: cardDataTP) {
        self.month = tp.month
        self.day = tp.day
        self.title = tp.title
        self.location = tp.location
        self.name = tp.name
        self.commentCount = tp.commentCount
        self.imageURL = tp.imageURL
        
    }
}
