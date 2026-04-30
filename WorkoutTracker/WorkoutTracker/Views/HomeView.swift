//
//  HomeView.swift
//  WorkoutTracker
//
//  ホーム画面
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var showRecordView = false
    @State private var showProgressView = false
    @State private var showHistoryView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // ヘッダー
                        headerView
                            .padding(.top, 20)
                        
                        // 統計カード
                        statsView
                            .padding(.horizontal)
                        
                        // クイックアクション
                        quickActionView
                            .padding(.horizontal)
                        
                        // 最近の記録
                        recentRecordsView
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("筋トレ記録")
            .sheet(isPresented: $showRecordView) {
                RecordWorkoutView(viewModel: viewModel)
            }
            .sheet(isPresented: $showProgressView) {
                ProgressView(viewModel: viewModel)
            }
            .sheet(isPresented: $showHistoryView) {
                HistoryView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("今日も頑張りましょう！")
                .font(.title2)
                .fontWeight(.bold)
        }
    }
    
    // MARK: - Stats
    private var statsView: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "flame.fill",
                title: "総トレーニング",
                value: "\(viewModel.totalWorkouts)",
                color: .orange
            )
            
            StatCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "最大重量",
                value: String(format: "%.0fkg", viewModel.maxWeight),
                color: .blue
            )
            
            StatCard(
                icon: "calendar",
                title: "今週",
                value: "\(viewModel.thisWeekWorkouts)",
                color: .green
            )
        }
    }
    
    // MARK: - Quick Action
    private var quickActionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("クイックアクション")
                .font(.headline)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "plus.circle.fill",
                    title: "記録",
                    color: .blue
                ) {
                    showRecordView = true
                }
                
                QuickActionButton(
                    icon: "chart.bar.fill",
                    title: "進捗",
                    color: .green
                ) {
                    showProgressView = true
                }
                
                QuickActionButton(
                    icon: "clock.fill",
                    title: "履歴",
                    color: .purple
                ) {
                    showHistoryView = true
                }
            }
        }
    }
    
    // MARK: - Recent Records
    private var recentRecordsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近の記録")
                .font(.headline)
            
            if viewModel.recentRecords.isEmpty {
                Text("まだ記録がありません")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
            } else {
                ForEach(viewModel.recentRecords.prefix(5)) { record in
                    RecordCard(record: record, machines: viewModel.machines)
                }
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

// MARK: - Record Card
struct RecordCard: View {
    let record: WorkoutRecord
    let machines: [WorkoutMachine]
    
    var machine: WorkoutMachine? {
        machines.first { $0.id == record.machineId }
    }
    
    var body: some View {
        HStack {
            if let machine = machine {
                Image(systemName: machine.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(machine.name)
                        .font(.headline)
                    
                    Text("\(record.sets.count)セット")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.0fkg", record.maxWeight))
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text(DateFormatter.shortDate.string(from: record.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }()
}
