//
//  QuestViewController.swift
//  STSI Test
//
//  Created by Фёдор Королёв on 11.03.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

class QuestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData(variant: 0)
    }

    @IBOutlet weak var questionLabel: UILabel!
    
    var questionList = [Question]()
    
    private func loadData(variant: Int) {
        let loader = QuestionsLoader()
        
        self.questionList = loader.loadData(variant: 0)
        
        questionLabel.text = questionList[0].question
    }
    
    
}
