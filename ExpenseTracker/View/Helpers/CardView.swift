//
//  CardView.swift
//  ExpenseTracker
//
//  Created by Eren Aşkın on 2.01.2024.
//

import SwiftUI

struct CardView: View {
    var income: Double
    var expense: Double
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
            
            VStack(spacing:0){
                HStack(spacing:12){
                    Text("\(currencyString(income - expense))")
                        .font(.title.bold())
                        .foregroundStyle(Color.primary)
                    Image(systemName: expense > income ? "chart.line.downtrend.xyaxis" : "chart.line.uptrend.xyaxis")
                        .font(.title3)
                        .foregroundStyle(expense > income ? .red : .green)
                }
                .padding(.bottom,25)
                
                HStack(spacing:0){
                    ForEach(Category.allCases, id: \.rawValue){category in
                        let symbolImage = category == .income ? "arrow.down" : "arrow.up"
                        
                        let tint = category == .income ? Color.green : Color.red
                        HStack(spacing:10){
                            Image(systemName: symbolImage)
                                .font(.callout.bold())
                                .foregroundStyle(tint)
                                .frame(width: 35, height: 35)
                                .background {
                                    Circle()
                                        .fill(tint.opacity(0.25).gradient)
                                }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                                Text(currencyString(category == .income ? income : expense, allowedDigits: 0))
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.primary)
                            }
                            if category == .income{
                                Spacer(minLength: 10)
                            }
                        }
                    }
                }
            }
            .padding([.horizontal,.bottom],25)
            .padding(.top,15)
        }
    }
}
func currencyString(_ value: Double,allowedDigits: Int = 2) -> String{
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = allowedDigits
    
    return formatter.string(from: .init(value: value)) ?? ""
}
func total(_ transactions: [Transaction], category: Category) -> Double{
    return transactions.filter({ $0.category == category.rawValue}).reduce(Double.zero) { partialResult, transaction in
        return partialResult + transaction.amount
    }
}

#Preview {
    ScrollView{
        CardView(income: 4590, expense: 2389)
    }
}
