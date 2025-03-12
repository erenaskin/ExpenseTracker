//
//  StateCardView.swift
//  StateCardView
//
//  Created by Eren Aşkın on 18.01.2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = WidgetEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [WidgetEntry] = []
        
        entries.append(.init(date: .now))

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
}

struct StateCardViewEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        FilterTransactionView(startDate: .now.startOfMonth, endDate: .now.endOfMonth) { transactions in
            CardView(income: total(transactions, category: .income), expense: total(transactions, category: .expense))
        }
    }
}

struct StateCardView: Widget {
    let kind: String = "StateCardView"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StateCardViewEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .modelContainer(for: Transaction.self)
        }
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
        .configurationDisplayName("Wallet")
        .description("Expense Tracker")
    }
}

#Preview(as: .systemSmall) {
    StateCardView()
} timeline: {
    WidgetEntry(date: .now)
}
