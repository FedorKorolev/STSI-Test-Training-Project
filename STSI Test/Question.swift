//
//  Question.swift
//  STSI Test
//
//  Created by Фёдор Королёв on 11.03.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

struct Question {
    
    let question: String
    let answers: [String]
    let correctAnswer: Int
    let comments: String
    var imageURL: String?
    

    init(json: [String : Any]) {
        self.question = json["quest"] as! String
        self.correctAnswer = json["otvet"] as! Int
        self.comments = json["comments"] as! String
        self.imageURL = json["realUrl"] as? String
        
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
