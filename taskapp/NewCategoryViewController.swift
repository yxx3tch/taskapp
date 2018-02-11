//
//  NewCategoryViewController.swift
//  taskapp
//
//  Created by yxx3tch on 2018/02/11.
//  Copyright © 2018年 yxx3tch. All rights reserved.
//

import UIKit
import RealmSwift

class NewCategoryViewController: UIViewController {

    @IBOutlet weak var categoryNameTextField: UITextField!
    
    var category: Category!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(clickSaveButton))
        self.navigationItem.setRightBarButton(saveButton, animated: true)
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func clickSaveButton() {
        let temp = try! Realm().objects(Category.self).filter("name = %@", categoryNameTextField.text!)
        if categoryNameTextField.text != "" {
            if temp.count == 0 {
                let alert: UIAlertController = UIAlertController(title: "カテゴリー追加", message: "新規カテゴリーとして保存しますか？", preferredStyle: UIAlertControllerStyle.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.saveCategory(category: self.category)
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                })
                alert.addAction(cancelAction)
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            } else {
                let alert: UIAlertController = UIAlertController(title: "カテゴリー追加", message: "カテゴリーがすでに存在します。", preferredStyle: UIAlertControllerStyle.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                    (action: UIAlertAction!) -> Void in
                })
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            }
        } else {
            let alert: UIAlertController = UIAlertController(title: "カテゴリー追加", message: "カテゴリー名を入力してください。", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func saveCategory(category: Category){
        try! realm.write {
            self.category.name = self.categoryNameTextField.text!
            self.realm.add(self.category, update: true)
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
