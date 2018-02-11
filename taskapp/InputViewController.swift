//
//  InputViewController.swift
//  taskapp
//
//  Created by yxx3tch on 2018/02/10.
//  Copyright © 2018年 yxx3tch. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var notificationButton: UISwitch!
    @IBOutlet weak var titleText: UINavigationItem!
    
    var pickerView: UIPickerView = UIPickerView()

    var editState: String!
    var task: Task!
    let realm = try! Realm()
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleText.title = editState
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.selectRow(0, inComponent: 0, animated: true)
        
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem, flexibleItem, addItem, doneItem], animated: true)
        self.categoryTextField.inputView = pickerView
        self.categoryTextField.inputAccessoryView = toolbar
        
        let saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(clickSaveButton))
        self.navigationItem.setRightBarButton(saveButton, animated: true)
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        titleTextField.text = task.title
        if task.category == nil {
            categoryTextField.text = ""
        } else {
            categoryTextField.text = task.category!.name
        }
        contentsTextView.text = task.contents
        datePicker.date = task.date
        notificationButton.isOn = task.isNotificationEnabled
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    }
    
    @objc func add() {
        self.performSegue(withIdentifier: "NewCategorySegue", sender: nil)
    }
    
    @objc func done() {
        self.categoryTextField.endEditing(true)
    }
    
    @objc func cancel() {
        self.categoryTextField.text = ""
        self.categoryTextField.endEditing(true)
    }
    
    @objc func clickSaveButton() {
        let alert: UIAlertController = UIAlertController(title: "タスク保存", message: "変更内容を保存しますか？", preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.saveTask(task: self.task)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
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
        self.categoryTextField.text = row != 0 ? self.categoryArray[row - 1].name : ""
    }
    
    func saveTask(task :Task) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            if categoryTextField.text! != "" {
                let category = try! Realm().objects(Category.self).filter("name = %@", categoryTextField.text!)
                self.task.category = category[0]
            } else {
                self.task.category = nil
            }
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.isNotificationEnabled = self.notificationButton.isOn
            self.realm.add(self.task, update: true)
        }
        if self.notificationButton.isOn {
            setNotification(task: task)
        }
    }
    
    func setNotification(task :Task) {
        let content = UNMutableNotificationContent()
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default()
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")
        }
        
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------/")
                    print(request)
                    print("/---------------/")
                }
            }
        }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewCategorySegue" {
            let newCategoryViewController: NewCategoryViewController = segue.destination as! NewCategoryViewController
            
            let category = Category()
            if self.categoryArray.count != 0 {
                category.id = self.categoryArray.max(ofProperty: "id")! + 1
            }
            newCategoryViewController.category = category
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
