//
//  Category.swift
//  taskapp
//
//  Created by yxx3tch on 2018/02/11.
//  Copyright © 2018年 yxx3tch. All rights reserved.
//

import RealmSwift

class Category: Object {
    @objc dynamic var id = 0
    
    @objc dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
