//
//  NewExpenseView.swift
//  ExpenseTracker
//
//  Created by Eren Aşkın on 16.01.2024.
//

import SwiftUI
import WidgetKit

struct TransactionView: View {
    // Environment Properties
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    var editTransaction: Transaction?
    // View Properties
    @State private var title: String = ""
    @State private var remarks: String = ""
    @State private var amounts: Double = .zero
    @State private var dateAdded: Date = .now
    @State private var category: Category = .expense
    // Random Tint
    @State var tint: TintColor = tints.randomElement()!
    var body: some View {
        ScrollView(.vertical){
            VStack(spacing: 15) {
                Text("Preview")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .hSpacing(.leading)
                // Preview Transaction Card View
                TransactionCardView(transaction: .init(title: title.isEmpty ? "Title" : title, remarks: remarks.isEmpty ? "Remarks" : remarks, amount: amounts, dateAdded: dateAdded, category: category, tintColor: tint))
                
                CustomSection("Title", hint: "Magic Keyboard", value: $title)
                
                CustomSection("Remarks", hint: "Apple Product", value: $remarks)
                // Amount & Category Check Box
                VStack(alignment: .leading, spacing: 10, content: {
                    Text("Amount & Category")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .hSpacing(.leading)
                    HStack(spacing: 15){
                        HStack(spacing: 4){
                            Text(currencySymbol)
                                .font(.callout.bold())
                            TextField("0.0", value: $amounts, formatter: numberFormatter)
                                .keyboardType(.decimalPad)
                        }
                            .padding(.horizontal,15)
                            .padding(.vertical,12)
                            .background(.background,in: .rect(cornerRadius: 10))
                            .frame(maxWidth: 130)
                        
                        // Custom Check Box
                        CategoryCheckBox()
                    }
                })
                // Date Picker
                VStack(alignment: .leading, spacing: 10, content: {
                    Text("Date")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .hSpacing(.leading)
                    DatePicker("", selection: $dateAdded, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .padding(.horizontal,15)
                        .padding(.vertical,12)
                        .background(.background,in: .rect(cornerRadius: 10))
                })
            }
            .padding(15)
        }
        .navigationTitle("\(editTransaction == nil ? "Add" : "Edit") Transaction")
        .background(.opacity(0.15))
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save",action: save)
            }
        })
        .onAppear(perform: {
            if let editTransaction{
                // Load All Existing Data from the Transaction
                title = editTransaction.title
                remarks = editTransaction.remarks
                dateAdded = editTransaction.dateAdded
                if let category = editTransaction.rawCategory{
                    self.category = category
                }
                amounts = editTransaction.amount
                if let tint = editTransaction.tint{
                    self.tint = tint
                }
            }
        })
    }
    func save(){
        // Saving Item to SwiftData
        if editTransaction != nil{
            editTransaction?.title = title
            editTransaction?.remarks = remarks
            editTransaction?.amount = amounts
            editTransaction?.category = category.rawValue
            editTransaction?.dateAdded = dateAdded
        }else{
            let transaction = Transaction(title: title, remarks: remarks, amount: amounts, dateAdded: dateAdded, category: category, tintColor: tint)
            context.insert(transaction)
        }
        dismiss()
        // Update Widget
        WidgetCenter.shared.reloadAllTimelines()
    }
    @ViewBuilder
    func CustomSection(_ title: String,hint: String, value: Binding<String>) -> some View{
        VStack(alignment: .leading, spacing: 10, content: {
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
                .hSpacing(.leading)
            TextField(hint, text: value)
                .padding(.horizontal,15)
                .padding(.vertical,12)
                .background(.background,in: .rect(cornerRadius: 10))
        })
    }
    // Custom Check Box
    @ViewBuilder
    func CategoryCheckBox() -> some View{
        HStack(spacing: 10){
            ForEach(Category.allCases, id: \.rawValue){ category in
                HStack(spacing: 5){
                    ZStack{
                        Image(systemName: "circle")
                            .font(.title3)
                            .foregroundStyle(appTint)
                        
                        if self.category == category{
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundStyle(appTint)
                        }
                    }
                    Text(category.rawValue)
                        .font(.caption)
                }
                .contentShape(.rect)
                .onTapGesture {
                    self.category = category
                }
            }
        }
        .padding(.horizontal,15)
        .padding(.vertical,12)
        .hSpacing(.leading)
        .background(.background,in: .rect(cornerRadius: 10))
    }
    // Number Formatter
    var numberFormatter: NumberFormatter{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        return formatter
    }
    var currencySymbol: String{
        let locale = Locale.current
        
        return locale.currencySymbol ?? ""
    }
}

#Preview {
    NavigationStack{
        TransactionView()
    }
}
