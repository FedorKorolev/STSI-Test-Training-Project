//
//  RootTableViewController.swift
//  STSI Test
//
//  Created by Фёдор Королёв on 13.03.17.
//  Copyright © 2017 Фёдор Королёв. All rights reserved.
//

import UIKit

class RootTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let loader = QuestionsLoader()
        variantsList = loader.loadVariantsList()

    }
    var variantsList: [Int] = []

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Выберите вариант"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variantsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(variantsList[indexPath.row])
        
        return cell
    }

    
    // MARK: - Navigation

     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVariant = indexPath.row
        performSegue(withIdentifier: "Start Test", sender: selectedVariant)
     }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? QuestViewController,
            let selectedVariant = sender as? Int {
            destVC.variant = selectedVariant
        }
    }

}
