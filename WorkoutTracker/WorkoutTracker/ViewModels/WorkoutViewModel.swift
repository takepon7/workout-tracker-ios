//
//  WorkoutViewModel.swift
//  WorkoutTracker
//
//  筋トレビューモデル
//

import Foundation
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var machines: [WorkoutMachine] = []
    @Published var records: [WorkoutRecord] = []
    @Published var recentRecords: [WorkoutRecord] = []
    
    var totalWorkouts: Int {
        records.count
    }
    
    var maxWeight: Double {
        records.map { $0.maxWeight }.max() ?? 0
    }
    
    var thisWeekWorkouts: Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        return records.filter { record in
            calendar.isDate(record.date, equalTo: weekStart, toGranularity: .weekOfYear)
        }.count
    }
    
    init() {
        loadDefaultMachines()
    }
    
    func loadData() {
        // サンプルデータを読み込み（実際はCore Dataから）
        loadSampleRecords()
        updateRecentRecords()
    }
    
    private func loadDefaultMachines() {
        machines = WorkoutMachine.defaultMachines
    }
    
    private func loadSampleRecords() {
        // サンプルデータ（実際はCore Dataから読み込む）
        if records.isEmpty {
            let sampleMachine = machines.first!
            let sampleRecord = WorkoutRecord(
                machineId: sampleMachine.id,
                date: Date(),
                sets: [
                    WorkoutSet(setNumber: 1, reps: 10, weight: 60),
                    WorkoutSet(setNumber: 2, reps: 8, weight: 65),
                    WorkoutSet(setNumber: 3, reps: 6, weight: 70)
                ]
            )
            records = [sampleRecord]
        }
    }
    
    func updateRecentRecords() {
        recentRecords = records.sorted { $0.date > $1.date }
    }
    
    func addRecord(_ record: WorkoutRecord) {
        records.append(record)
        updateRecentRecords()
    }
    
    func addMachine(_ machine: WorkoutMachine) {
        machines.append(machine)
    }
}
