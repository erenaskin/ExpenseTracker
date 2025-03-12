//
//  Trsnsaction.swift
//  ExpenseTracker
//
//  Created by Eren Aşkın on 29.12.2023.
//

import SwiftUI
import SwiftData

// @Model özelliğini kullanarak bir veritabanı modeli olusturuldu.

@Model
class Transaction {
    //Properties
    var title: String
    var remarks: String
    var amount: Double
    var dateAdded: Date
    var category: String
    var tintColor: String
    
    init(title: String, remarks: String, amount: Double, dateAdded: Date, category: Category, tintColor: TintColor) {
        self.title = title
        self.remarks = remarks
        self.amount = amount
        self.dateAdded = dateAdded
        self.category = category.rawValue
        self.tintColor = tintColor.color
    }
    // Extracting Color Value From tintColor String
    // Veritabanlarında "transient" genellikle bir verinin kalıcı olarak saklanmadığı, sadece bir işlem sırasında geçerli olan bir durumu ifade eder
    @Transient
    var color: Color{
        return tints.first(where: {$0.color == tintColor})?.value ?? appTint
    }
    @Transient
    var tint: TintColor?{
        return tints.first(where: {$0.color == tintColor})
    }
    @Transient
    var rawCategory: Category?{
        return Category.allCases.first(where: {category == $0.rawValue})
    }
}

