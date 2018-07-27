//
//  Todo.swift
//  Todoey
//
//  Created by andres murguido on 7/27/18.
//  Copyright © 2018 andres murguido. All rights reserved.
//

import Foundation
import RealmSwift

class Todo: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createdAt: Date?
    var parentCategory = LinkingObjects<Category>(fromType: Category.self, property: "todos")
}
