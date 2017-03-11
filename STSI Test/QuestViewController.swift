//
//  QuestViewController.swift
//  STSI Test
//
//  Created by Фёдор Королёв on 11.03.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

class QuestViewController: UIViewController {

    // Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        loadData(variant: 0)
        
    }

    var isOnScreen: Bool {
        return isViewLoaded && view.window != nil
    }
    
    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Questions Data
    var questionList = [Question]()
    
    private func loadData(variant: Int) {
        let loader = QuestionsLoader()
        self.questionList = loader.loadData(variant: variant)
        
        currentQuestionIndex = 0
        currentQuestion = questionList[0]
        
        questionLabel.text = currentQuestion?.question
        
        updateViews()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
    }
    
    // Current State
    var currentQuestionIndex = 0
    var currentQuestion: Question? {
        didSet {
            updateViews()
        }
    }
    
    // Update Views
    private func updateViews() {
        // load image
        if let realURL = currentQuestion?.imageURL,
            let checkedUrl = URL(string: realURL) {
            downloadImage(url: checkedUrl)
        }
        
        // load tableView
        
        
//        let sectionsToReload = IndexSet(integer: 0)
//        self.tableView.reloadSections(sectionsToReload, with: isOnScreen ? .automatic : .none)
    }
    
    
    
    
    
    // Image Download
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


// Setup tableView
extension QuestViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQuestion?.answers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = currentQuestion?.answers[indexPath.row]
        return cell
    }
    
}


extension QuestViewController: UITableViewDelegate {
    
}
