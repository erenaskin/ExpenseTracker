//
//  Recents.swift
//  ExpenseTracker
//
//  Created by Eren Aşkın on 29.12.2023.
//

import SwiftUI
import SwiftData

// Recents yapısının içinde, FilterTransactionView yapısı ile birlikte SwiftData kütüphanesinin bazı özelliklerini kullanıyorsunuz. Şu öğeler SwiftData ile ilgili işlemleri içeriyor:

/*
 1. @Query(animation: .snappy) private var transactions: [Transaction]: Bu satır, @Query özelliği ile bir sorguyu tanımlar. Bu sorgu, Transaction türündeki verileri çeker ve animasyonlu bir şekilde güncellenir. Bu, SwiftData'nın sağladığı sorgu yeteneklerinden biridir.

2. FilterTransactionView yapısı içinde, bu sorgu kullanılarak belirli kriterlere uyan işlemleri filtrelemek ve görüntülemek için bir sorgu gerçekleştirilir.

3. TransactionView'i açmak için NavigationLink kullanılırken, navigationDestination(for: Transaction.self) kullanılarak Transaction türündeki verilerin yönlendirme işlemi tanımlanmıştır.*/

struct Recents: View {
    // User Properties
    /// A property wrapper type that reflects a value from `UserDefaults` and
    /// invalidates a view on a change in value in that user default.
    @AppStorage ("userName") private var userName: String = ""
    // View Properties
    @State private var startDate: Date = .now.startOfMonth
    @State private var endDate: Date = .now.endOfMonth
    @State private var selectedCategory: Category = .expense
    @State private var showFilterView: Bool = false
    // For Animation
    @Namespace private var animation
    var body: some View {
        GeometryReader{
            // For Animation Purpose
            let size = $0.size
            
            NavigationStack{
                ScrollView(.vertical) {
                    LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]) {
                        Section {
                             // Date Filter View
                            Button(action: {
                                showFilterView = true
                            }, label: {
                                Text("\(format(date: startDate, format:  "dd MMM yy")) to \(format(date: endDate,format: "dd MMM yy"))")
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                            })
                            .hSpacing(.leading)
                            
                            FilterTransactionView(startDate: startDate, endDate: endDate) { transactions in
                                
                                // Card View
                                CardView(income: total(transactions, category: .income), expense: total(transactions, category: .expense))
                                
                                // Custom Segmented Control
                                CustomSegmentedControl()
                                    .padding(.bottom,10)
                                
                                ForEach(transactions.filter({ $0.category == selectedCategory.rawValue})){ transaction in
                                    NavigationLink(value: transaction) {
                                        TransactionCardView(transaction: transaction)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        } header: {
                            HeaderView(size)
                        }
                    }
                    .padding(15)
                }
                .background(.gray.opacity(0.15))
                .blur(radius: showFilterView ? 8 : 0)
                .disabled(showFilterView)
                .navigationDestination(for: Transaction.self) { transaction in
                    TransactionView(editTransaction: transaction)
                }
            }
            .overlay {
                    if showFilterView{
                        DateFilterView(start: startDate, end: endDate, onSubmit: { start, end in
                            startDate = start
                            endDate = end
                            showFilterView = false
                        }, onClose: {
                            showFilterView = false
                        })
                            .transition(.move(edge: .leading))
                    }
                
            }
            .animation(.snappy, value: showFilterView)
        }
    }
    // Header View
    @ViewBuilder
    func HeaderView(_ size: CGSize) -> some View{
        HStack(spacing:10){
            VStack(alignment: .leading, spacing: 5, content: {
                Text("Welcome!")
                    .font(.title.bold())
                if !userName.isEmpty{
                    Text(userName)
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            })
            .visualEffect { content, geometryProxy in
                content
                    .scaleEffect(headerScale(size, proxy: geometryProxy),anchor: .topLeading)
            }
            
            Spacer(minLength: 0)
            
            NavigationLink{
                TransactionView()
            } label: {
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 45, height: 45)
                    .background(appTint.gradient,in: .circle)
                    .contentShape(.circle)
            }
        }
            .hSpacing(.leading)
            .overlay(alignment: .trailing, content: {
                
            })
            .padding(.bottom,userName.isEmpty ? 10 : 5)
        .background{
            VStack(spacing:0){
                Rectangle()
                    .fill(.ultraThinMaterial)
                Divider()
            }
            .visualEffect { content, geometryProxy in
                content
                    .opacity(headerBGOpacity(geometryProxy))
            }
                .padding(.horizontal, -15)
                .padding(.top, -(safeArea.top + 15))
        }
    }
    func headerBGOpacity(_ proxy: GeometryProxy) -> CGFloat{
        let minY = proxy.frame(in: .scrollView).minY + safeArea.top
        return minY > 0 ? 0 : (-minY / 15)
    }
    func headerScale(_ size: CGSize,proxy: GeometryProxy) -> CGFloat{
        let minY = proxy.frame(in: .scrollView).minY
        let screenHeight = size.height
        
        let progress = minY / screenHeight
        let scale = (min(max(progress,0),1)) * 0.4
        
        return 1 + scale
    }
    @ViewBuilder
    func CustomSegmentedControl() -> some View{
        HStack(spacing:0){
            ForEach(Category.allCases,id: \.rawValue){category in
                Text(category.rawValue)
                    .hSpacing()
                    .padding(.vertical,10)
                    .background{
                        if category == selectedCategory{
                            Capsule()
                                .fill(.background)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        }
                    }
                    .contentShape(.capsule)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            selectedCategory = category
                    }
                }
            }
        }
        .background(.gray.opacity(0.15),in: .capsule)
        .padding(.top,5)
        
    }
}

#Preview {
    ContentView()
}
