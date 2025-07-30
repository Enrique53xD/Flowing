//
//  MonthlySummaryView.swift
//  Flowing
//
//  Created by GitHub Copilot
//

import SwiftUI
import SwiftData

struct MonthlySummaryView: View {
    // Environment Variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context
    
    // State Variables
    @Binding var personalization: personalizationVariables
    @Binding var isPresented: Bool
    
    // Fetch Requests
    @Query(sort: \toDoItem.name) private var toDoItems: [toDoItem]
    @Query(sort: \progressiveItem.name) private var progressiveItems: [progressiveItem]
    
    // Computed properties for monthly statistics
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private var monthlyCompletedTodos: Int {
        return toDoItems.filter { item in
            item.done && isFromCurrentMonth(item.date)
        }.count
    }
    
    private var monthlyTotalTodos: Int {
        return toDoItems.filter { item in
            isFromCurrentMonth(item.date)
        }.count
    }
    
    // If there are no todos in current month, show all-time stats instead
    private var displayCompletedTodos: Int {
        if monthlyTotalTodos == 0 {
            return toDoItems.filter { $0.done }.count
        }
        return monthlyCompletedTodos
    }
    
    private var displayTotalTodos: Int {
        if monthlyTotalTodos == 0 {
            return toDoItems.count
        }
        return monthlyTotalTodos
    }
    
    private var displayTitle: String {
        return monthlyTotalTodos == 0 ? "Completed Todos (All Time)" : "Completed Todos"
    }
    
    private var monthlyProgressiveStats: [(String, Double)] {
        let monthlyItems = progressiveItems.filter { item in
            isFromCurrentMonth(item.date)
        }
        
        // If no monthly items, show all progressive items
        let itemsToShow = monthlyItems.isEmpty ? progressiveItems : monthlyItems
        
        return itemsToShow.compactMap { item in
            let percentage = item.goal > 0 ? min((item.progress / item.goal) * 100, 100) : 0
            return (item.name, percentage)
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    withAnimation(.bouncy) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                }
                
                Spacer()
                
                Text(monthlyTotalTodos > 0 ? "Monthly Summary" : "Summary")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                
                Spacer()
                
                Text(getCurrentMonthName())
                    .font(.caption)
                    .foregroundStyle(personalization.customTextColor ? personalization.textColor.opacity(0.7) : Color.primary.opacity(0.7))
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 16) {
                    if displayTotalTodos > 0 {
                        // Todo Summary Card
                        SummaryCard(
                            title: displayTitle,
                            value: "\(displayCompletedTodos)/\(displayTotalTodos)",
                            icon: "checkmark.circle.fill",
                            percentage: displayTotalTodos > 0 ? Double(displayCompletedTodos) / Double(displayTotalTodos) : 0,
                            personalization: personalization
                        )
                        
                        // Progressive Items Summary
                        if !monthlyProgressiveStats.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Progressive Items")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                                    .padding(.horizontal)
                                
                                ForEach(Array(monthlyProgressiveStats.enumerated()), id: \.offset) { index, stat in
                                    ProgressiveStatRow(
                                        name: stat.0,
                                        percentage: stat.1,
                                        personalization: personalization
                                    )
                                }
                            }
                        }
                        
                        // Monthly Overview Card
                        MonthlyOverviewCard(
                            completedTodos: displayCompletedTodos,
                            totalTodos: displayTotalTodos,
                            progressiveItems: monthlyProgressiveStats.count,
                            personalization: personalization,
                            isMonthlyData: monthlyTotalTodos > 0
                        )
                    } else {
                        // No data message
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundStyle(personalization.customTextColor ? personalization.textColor.opacity(0.5) : Color.primary.opacity(0.5))
                            
                            Text("No todos found")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                            
                            Text("Create your first todo to see your productivity stats here")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(personalization.customTextColor ? personalization.textColor.opacity(0.7) : Color.primary.opacity(0.7))
                                .padding(.horizontal)
                        }
                        .padding(.top, 60)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Helper functions
    private func getCurrentMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        return formatter.string(from: Date())
    }
    
    private func getCurrentMonthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private func isFromCurrentMonth(_ dateString: String) -> Bool {
        // First, try with the short date format
        let shortFormatter = DateFormatter()
        shortFormatter.dateStyle = .short
        
        if let itemDate = shortFormatter.date(from: dateString) {
            let calendar = Calendar.current
            let now = Date()
            return calendar.isDate(itemDate, equalTo: now, toGranularity: .month)
        }
        
        // If that fails, try with other common formats
        let formatters = [
            "MM/dd/yyyy",
            "dd/MM/yyyy", 
            "yyyy-MM-dd",
            "MM/dd/yy",
            "dd/MM/yy"
        ]
        
        for formatString in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = formatString
            
            if let itemDate = formatter.date(from: dateString) {
                let calendar = Calendar.current
                let now = Date()
                return calendar.isDate(itemDate, equalTo: now, toGranularity: .month)
            }
        }
        
        // If all else fails, return false
        return false
    }
}

// MARK: - Summary Card Component
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let percentage: Double
    let personalization: personalizationVariables
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(personalization.customColor ? personalization.mainColor : Color.primary)
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                }
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                
                // Progress bar
                ProgressView(value: percentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: personalization.customColor ? personalization.mainColor : Color.primary))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            Spacer()
            
            Text("\(Int(percentage * 100))%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(personalization.customColor ? personalization.mainColor : Color.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
        )
    }
}

// MARK: - Progressive Stat Row Component
struct ProgressiveStatRow: View {
    let name: String
    let percentage: Double
    let personalization: personalizationVariables
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Text(name)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                .lineLimit(1)
            
            Spacer()
            
            HStack(spacing: 8) {
                ProgressView(value: min(percentage / 100, 1.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: personalization.customColor ? personalization.mainColor : Color.primary))
                    .frame(width: 60)
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                
                Text("\(Int(percentage))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(personalization.customTextColor ? personalization.textColor.opacity(0.8) : Color.primary.opacity(0.8))
                    .frame(width: 35, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.08) : Color.gray.opacity(0.03))
        )
    }
}

// MARK: - Monthly Overview Card Component
struct MonthlyOverviewCard: View {
    let completedTodos: Int
    let totalTodos: Int
    let progressiveItems: Int
    let personalization: personalizationVariables
    let isMonthlyData: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isMonthlyData ? "Monthly Overview" : "All-Time Overview")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Total Todos:")
                        .foregroundStyle(personalization.customTextColor ? personalization.textColor.opacity(0.8) : Color.primary.opacity(0.8))
                    Spacer()
                    Text("\(totalTodos)")
                        .fontWeight(.semibold)
                        .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                }
                
                HStack {
                    Text("Completed:")
                        .foregroundStyle(personalization.customTextColor ? personalization.textColor.opacity(0.8) : Color.primary.opacity(0.8))
                    Spacer()
                    Text("\(completedTodos)")
                        .fontWeight(.semibold)
                        .foregroundStyle(personalization.customColor ? personalization.mainColor : Color.primary)
                }
                
                if isMonthlyData {
                    HStack {
                        Text("Progressive Items:")
                            .foregroundStyle(personalization.customTextColor ? personalization.textColor.opacity(0.8) : Color.primary.opacity(0.8))
                        Spacer()
                        Text("\(progressiveItems)")
                            .fontWeight(.semibold)
                            .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
        )
    }
}