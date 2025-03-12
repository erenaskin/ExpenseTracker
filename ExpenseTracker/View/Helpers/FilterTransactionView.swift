//
//  FilterTransactionView.swift
//  ExpenseTracker
//
//  Created by Eren Aşkın on 17.01.2024.
//

import SwiftUI
import SwiftData

// `SwiftData` kullanarak veritabanındaki Transaction öğelerini filtreleme yeteneği sunan bir görünüm elde etmemizi sagliyor. FilterTransactionView içinde kullanılan @Query özelliği, SwiftData tarafından sağlanan bir özelliktir ve veritabanı sorgularını yönetmek için kullanılır.

// Bu yapı, belirli kriterlere göre Transaction öğelerini filtrelemek için kullanırız. İki tarih arasındaki işlemleri veya belirli bir metin içeren işlemleri filtreleme yeteneği sağlar.

/*
1. Belirli bir kategorideki işlemleri veya belirli bir metni içeren işlemleri filtreleme (`init(category:searchText:content:)`).
2. Belirli bir tarih aralığındaki işlemleri filtreleme (`init(startDate:endDate:content:)`).
3. Belirli bir tarih aralığındaki belirli bir kategorideki işlemleri veya belirli bir metni içeren işlemleri filtreleme (`init(startDate:endDate:category:searchText:content:)`).

 Bu yapı, SwiftData'nın sunduğu güçlü filtreleme yeteneklerini kullanarak veritabanındaki verileri işlemenize ve görüntülemenize olanak tanır.
 Predicate: Kosula bağlı filtreleme yapmamıza olanak sağlar.
 */

// rawValue özelliği daha çok enumlarda kullanılıp enum durumlarının altında yatan değeri temsil eder.Mesela Weekday adında bir enum oluşturduk ve altında caselerini belirttik.Pazartesinin değeri bir olarak atadığımızda rawValue değeri 1 dir.Ancak sonradan bir Weekday türünde bir değişkene bir case türünü atadığımızda ve sonradan rawValue değerini kontrol ettiğimizde bunun değerinin değiştiğini göreceğiz.

// Custom View
struct FilterTransactionView<Content: View> : View {
    var content: ([Transaction]) -> Content
    @Query(animation: .snappy) private var
transactions: [Transaction]
    /// A spring animation with a predefined duration and small amount of
    /// bounce that feels more snappy and can be tuned.
    init(category: Category?, searchText: String,@ViewBuilder content: @escaping  ([Transaction]) -> Content) {
        // custom predicate
        let rawValue = category?.rawValue ?? ""
        let predicate = #Predicate<Transaction>{transaction in
            return transaction.title.localizedStandardContains(searchText) || transaction.remarks.localizedStandardContains(searchText) && (rawValue.isEmpty ? true : transaction.category == rawValue)
        }
        _transactions = Query(filter: predicate, sort: [SortDescriptor(\Transaction.dateAdded,order: .reverse)], animation: .snappy)
        self.content = content
    }
    init(startDate: Date,endDate: Date,@ViewBuilder content: @escaping  ([Transaction]) -> Content) {
        // custom predicate
        let predicate = #Predicate<Transaction>{transaction in
            return transaction.dateAdded >= startDate && transaction.dateAdded <= endDate
        }
        _transactions = Query(filter: predicate, sort: [SortDescriptor(\Transaction.dateAdded,order: .reverse)], animation: .snappy)
        self.content = content
    }
    init(startDate: Date,endDate: Date,category: Category?, searchText: String,@ViewBuilder content: @escaping  ([Transaction]) -> Content) {
        // custom predicate
        let rawValue = category?.rawValue ?? ""
        let predicate = #Predicate<Transaction>{transaction in
            return transaction.dateAdded >= startDate && transaction.dateAdded <= endDate && (rawValue.isEmpty ? true : transaction.category == rawValue)
        }
        _transactions = Query(filter: predicate, sort: [SortDescriptor(\Transaction.dateAdded,order: .reverse)], animation: .snappy)
        self.content = content
    }

    var body: some View {
        content(transactions)
    }
}

