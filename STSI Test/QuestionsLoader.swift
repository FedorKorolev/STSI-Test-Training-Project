//
//  QuestionsLoader.swift
//  STSI Test
//
//  Created by Фёдор Королёв on 11.03.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import Foundation

class QuestionsLoader {
    func loadData(variant: Int) -> [Question] {
        let pathToFile = Bundle.main.path(forResource: "quiestions1-10", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: pathToFile))
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        let biletsJson = json as! [String : Any]
        let bilets = biletsJson["bilets"] as! [Any]
        let allQuestionsInSelectedVariant = bilets[variant] as! [ [String : Any] ]
        
        var questions = [Question]()
        
        for json in allQuestionsInSelectedVariant {
            questions.append(Question(json: json))
        }
        
        return questions
    }
}
