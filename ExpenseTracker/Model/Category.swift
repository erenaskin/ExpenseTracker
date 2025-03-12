//
//  Category.swift
//  ExpenseTracker
//
//  Created by Eren Aşkın on 29.12.2023.
//

import SwiftUI

// CaseIterable protokolü uygulanan bir enum tipi, içindeki durumları bir dizi veya başka bir koleksiyon türü içinde alabilir.

enum Category: String,CaseIterable{
    case income = "Income"
    case expense = "Expense"
}
