//
//  ViewController.swift
//  taskapp
//
//  Created by yxx3tch on 2018/02/10.
//  Copyright © 2018年 yxx3tch. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pickerView: UIPickerView = UIPickerView()
    var searchBarTextField: UITextField!
    
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.selectRow(0, inComponent: 0, animated: true)
        
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem, flexibleItem, doneItem], animated: true)

        searchBarTextField = searchBar.subviews.first?.subviews.flatMap { $0 as? UITextField }.first
        self.searchBarTextField.inputView = pickerView
        self.searchBarTextField.inputAccessoryView = toolbar
    }
    
    @objc func done() {
        self.searchBar.endEditing(true)
        self.searchByCategory()
    }
    
    @objc func cancel() {
        self.searchBar.endEditing(true)
        self.searchBar.text = ""
        self.searchByCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categoryArray.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row != 0 ? self.categoryArray[row - 1].name : ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.searchBar.text = row != 0 ? self.categoryArray[row - 1].name : ""
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = self.taskArray[indexPath.row]
            let center = UNUserNotificationCenter.current()
            
            if task.isNotificationEnabled {
                center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            }
            
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------/")
                    print(request)
                    print("/---------------/")
                }
            }
        }
    }
    
    func searchByCategory() {
        if searchBar.text != "" {
            taskArray = try! Realm().objects(Task.self).filter("category.name = %@", searchBar.text!).sorted(byKeyPath: "date", ascending: false)
        } else {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        }
        tableView.reloadData()
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
            inputViewController.editState = "Edit Task"
        } else {
            let task = Task()
            task.date = Date()
            
            let taskArray = realm.objects(Task.self)
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
            inputViewController.editState = "New Task"
        }
    }

}

