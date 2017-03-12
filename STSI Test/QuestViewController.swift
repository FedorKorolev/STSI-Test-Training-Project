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
   
    @IBAction func checkAnswerPressed(_ sender: UIBarButtonItem) {
        checkAnswer()
    }
    
    
    // Answer Check
    func checkAnswer() {
        
        let correctImageView = UIImageView(image: UIImage(named: "tick"))
        let wrongImageView = UIImageView(image: UIImage(named: "cross"))
        
        let selectedIndexPatch = tableView.indexPathForSelectedRow
        let selectedCell = tableView.cellForRow(at: selectedIndexPatch!)
        
        if questionList[currentQuestionIndex].answerIsCorrect {
            print("Correct Answer!")
            for cell in tableView.visibleCells {
                cell.accessoryView = nil
            }
            selectedCell?.accessoryView = correctImageView
        } else {
            print("Wrong Answer")
            for cell in tableView.visibleCells {
                cell.accessoryView = nil
            }
            selectedCell?.accessoryView = wrongImageView
        }
        
        questionList[currentQuestionIndex].answerWasCheked = true
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
        updateViews()
    }
    
    func goToPreviousQuestion() {
        animationIsReverse = true
        guard currentQuestionIndex > 0 else {
            print("Вернулись на начало")
            return
        }
        currentQuestionIndex -= 1
        updateViews()
        
    }
    
    
    
    // Questions Data
    var questionList = [Question]()
    
    
    // Load Data and Setup tableView
    private func loadData(variant: Int) {
        
        let loader = QuestionsLoader()
        self.questionList = loader.loadData(variant: variant)
        
        currentQuestionIndex = 0
        
        updateViews()
    }
    
    // Current State
    var currentQuestionIndex = 0
    
    var animationIsReverse = false
    
    // Update Views
    private func updateViews() {
        
        // load image
        if let realURL = questionList[currentQuestionIndex].imageURL,
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
            
            questionLabel.text = questionList[currentQuestionIndex].question
        
        
        // reload tableView
        let sectionsToReload = IndexSet(integer: 0)
        tableView.reloadSections(sectionsToReload, with: animationIsReverse ? .right : .left)
        
        // Auto-Set Row Height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        // reset checkmarks
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
            cell.accessoryView = nil
        }
        
        // recall selection
        guard questionList[currentQuestionIndex].selectedAnswer != nil else {
            return
        }
        let indexPath = IndexPath(row: (questionList[currentQuestionIndex].selectedAnswer)!, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        
        // recall checkmark
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        
        // check answer
        if questionList[currentQuestionIndex].answerWasCheked {
            checkAnswer()
        }
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
        return questionList[currentQuestionIndex].answers.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = questionList[currentQuestionIndex].answers[indexPath.row]
        return cell
    }
    
}

// Handle selection
extension QuestViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        questionList[currentQuestionIndex].selectedAnswer = indexPath.row
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 1,
                       options: [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.beginFromCurrentState],
                       animations: {
                        cell?.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
                        cell?.transform = CGAffineTransform.identity
                        cell?.accessoryType = .checkmark
                        
        },
                       completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    
}

// Transition Animation
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
