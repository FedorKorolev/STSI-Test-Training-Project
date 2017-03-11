//
//  Question.swift
//  STSI Test
//
//  Created by Фёдор Королёв on 11.03.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

struct Question {
    
    // Properties
    let question: String
    let answers: [String]
    private let correctAnswer: Int
    let comments: String
    
    // Image
    let imageDownloader = ImageDownloader()
    let imageURL: String?
//    var image: UIImage = imageDownloader.downloadImage(url: imageURL)
    
    init(json: [String : Any]) {
        self.question = json["quest"] as! String
        self.correctAnswer = json["otvet"] as! Int
        self.comments = json["comments"] as! String
        
        if let imageURL = json["realUrl"] as? String {
            self.imageURL = imageURL
        } else {
            self.imageURL = nil
        }
        
        let answersAndNils = json["v"] as! [Any]
        var answers = [String]()
        for item in answersAndNils {
            if let answer = item as? String {
                answers.append(answer)
            }
        }
        self.answers = answers
    }
    
    
}
