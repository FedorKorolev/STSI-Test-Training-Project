//
//  QuestViewController.swift
//  STSI Test
//
//  Created by Фёдор Королёв on 11.03.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

class QuestViewController: UIViewController {

    var variant = 0
    
    // Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadData(variant: variant)
        
        setupSwipes()
    }
    
    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var previousButton: UIBarButtonItem!
    
    

    // Actions Buttons
    @IBAction func next(_ sender: UIBarButtonItem) {
        goToNextQuestion()
    }
    
    @IBAction func previous(_ sender: UIBarButtonItem) {
        goToPreviousQuestion()
    }
    
    
    // Answer Check
    func checkAnswer() {
        
        let correctImageView = UIImageView(image: UIImage(named: "tick"))
        let wrongImageView = UIImageView(image: UIImage(named: "cross"))
        
        let selectedIndexPatch = tableView.indexPathForSelectedRow
        let selectedCell = tableView.cellForRow(at: selectedIndexPatch!)
        
        selectedCell?.accessoryView?.alpha = 0
        
        if questionList[currentQuestionIndex].lastSelectedAnswerIsCorrect {
            print("Correct Answer")
            selectedCell?.accessoryView = correctImageView
            animateSelectionFor(cell: selectedCell, correct: true)
            
            
        } else {
            print("Wrong Answer")
            selectedCell?.accessoryView = wrongImageView
        }

    }
    
    func animateSelectionFor(cell: UITableViewCell?, correct: Bool) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 1,
                       options: [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.beginFromCurrentState],
                       animations: {
                        cell?.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
                        cell?.transform = CGAffineTransform.identity
                        cell?.accessoryView?.alpha = 1
                        
        },
                       completion: { finished in
                        if correct {
                            self.goToNextQuestion()
                        }
        })
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
        guard currentQuestionIndex < questionList.count - 1 else {
            print("Больше нет вопросов")
            finishTest()
            return
        }
        currentQuestionIndex += 1
        updateViews()
    }
    
    func goToPreviousQuestion() {
        animationIsReverse = true
        guard currentQuestionIndex > 0 else {
            print("Это был первый вопрос")
            return
        }
        currentQuestionIndex -= 1
        updateViews()
        
    }
    
    // Finish Test
    func finishTest() {
        
        // calculate Final Score
        var score = 0
        for question in questionList {
            if question.noMistakes {
                score += 1
            }
        }
        print(score)
        
        // fnish conformation
        let alert = UIAlertController(title: "Завершить тест?", message: nil, preferredStyle: .alert)
        let finishButton = UIAlertAction(title: "Завершить", style: .default) { action in
            self.performSegue(withIdentifier: "Show Result", sender: score)
            print("Завершение теста")
        }
        let canсelButton = UIAlertAction(title: "Отмена", style: .cancel) { action in
            print("Завершение теста отменено")
        }
        alert.addAction(finishButton)
        alert.addAction(canсelButton)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? ResultViewController,
            let score = sender as? Int {
            destVC.score = score
        }

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
        
        // update controller title
        self.title = "Вопрос \(currentQuestionIndex + 1) из \(questionList.count)"
        
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
            cell.accessoryView = nil
        }
        
        // disable or enable previous button
        if currentQuestionIndex == 0 {
            previousButton.isEnabled = false
        } else {
            previousButton.isEnabled = true
        }
        
        // if answers were selected, recall selections marks
        guard questionList[currentQuestionIndex].selectedAnswers.count > 0 else {
            return
        }
        
        let correctImageView = UIImageView(image: UIImage(named: "tick"))
        let wrongImageView = UIImageView(image: UIImage(named: "cross"))
        
        for selection in questionList[currentQuestionIndex].selectedAnswers {
            let indexPath = IndexPath(row: selection, section: 0)
            if selection == (questionList[currentQuestionIndex].correctAnswer - 1) {
               tableView.cellForRow(at: indexPath)?.accessoryView = correctImageView
                print("Recall correct mark for \(selection)")
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryView = wrongImageView
                print("Recall wrong mark for \(selection)")
            }
            
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
        questionList[currentQuestionIndex].selectedAnswers.append(indexPath.row)
        checkAnswer()
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
