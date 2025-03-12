//
//  ChartModel.swift
//  ExpenseTracker
//
//  Created by Eren Aşkın on 17.01.2024.
//

import SwiftUI

struct ChartGroup: Identifiable {
        var id: UUID = .init()
        var date: Date
        var categories: [ChartCategory]
        var totalIncome: Double
        var totalExpense: Double
}
struct ChartCategory: Identifiable{
    let id: UUID = .init()
    var totalValue: Double
    var category: Category
}

