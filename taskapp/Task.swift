//
//  Task.swift
//  taskapp
//
//  Created by yxx3tch on 2018/02/10.
//  Copyright © 2018年 yxx3tch. All rights reserved.
//

import RealmSwift

class Task: Object {
    @objc dynamic var id = 0
    
    @objc dynamic var title = ""
    
    @objc dynamic var contents = ""
    
    @objc dynamic var date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
