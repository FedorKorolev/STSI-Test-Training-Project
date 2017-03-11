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
        
        if let realURL = questionList[1].imageURL,
           let checkedUrl = URL(string: realURL) {
            downloadImage(url: checkedUrl)
        }
        
    }

    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //Questions Data
    var questionList = [Question]()
    
    private func loadData(variant: Int) {
        let loader = QuestionsLoader()
        
        self.questionList = loader.loadData(variant: 0)
        
        questionLabel.text = questionList[0].question
    }
    
    //Image Download
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    
}
