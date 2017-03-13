//
//  ResultViewController.swift
//  STSI Test
//
//  Created by Фёдор Королёв on 13.03.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        scoreLabel.text = "\(score) из 20"
        
    }
    
    var score = 0
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    
}
