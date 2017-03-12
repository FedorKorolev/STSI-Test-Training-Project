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
        
        setupSwipes()
        
    }
    
    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // Actions Buttons
    @IBAction func next(_ sender: UIBarButtonItem) {
        goToNextQuestion()
    }
    
    @IBAction func previous(_ sender: UIBarButtonItem) {
        goToPreviousQuestion()
    }
    
    // Gestures
    func setupSwipes() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                goToPreviousQuestion()
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                goToNextQuestion()
            default:
                break
            }
        }
    }
    
    
    // Questions Navigation
    func goToNextQuestion() {
        animationIsReverse = false
        guard currentQuestionIndex < questionList.count else {
            print("Больше нет вопросов")
            return
        }
        currentQuestionIndex += 1
        currentQuestion = questionList[currentQuestionIndex]
    }
    
    func goToPreviousQuestion() {
        animationIsReverse = true
        guard currentQuestionIndex > 0 else {
            print("Вернулись на начало")
            return
        }
        currentQuestionIndex -= 1
        currentQuestion = questionList[currentQuestionIndex]
        
    }
    
    
    // Questions Data
    var questionList = [Question]()
    
    
    // Load Data and Setup tableView
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
    var animationIsReverse = false
    
    // Update Views
    private func updateViews() {
        
        // load image
        if let realURL = currentQuestion?.imageURL,
            let checkedUrl = URL(string: realURL) {
            downloadImage(url: checkedUrl)
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.alpha = 1
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.alpha = 0
            }, completion: nil)        }
        
        // update label
            questionLabel.pushTransition(duration: 0.3, reverse: animationIsReverse)
            
            questionLabel.text = currentQuestion?.question
        
        
        // reload tableView
        let sectionsToReload = IndexSet(integer: 0)
        self.tableView.reloadSections(sectionsToReload, with: animationIsReverse ? .right : .left)
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
                self.imageView.pushTransition(duration: 0.3, reverse: self.animationIsReverse)
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

// Handle selection
extension QuestViewController: UITableViewDelegate {
    
}

// Add text change animation
extension UIView {
    func pushTransition(duration: CFTimeInterval, reverse: Bool) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionPush
        if reverse {
            animation.subtype = kCATransitionFromLeft
        } else {
            animation.subtype = kCATransitionFromRight
        }
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionPush)
    }
}
