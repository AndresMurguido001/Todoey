//
//  Category.swift
//  Todoey
//
//  Created by andres murguido on 7/27/18.
//  Copyright © 2018 andres murguido. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name:String = ""
    let todos = List<Todo>()
}
