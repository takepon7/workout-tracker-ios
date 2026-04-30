//
//  RecordWorkoutView.swift
//  WorkoutTracker
//
//  トレーニング記録画面
//

import SwiftUI

struct RecordWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMachine: WorkoutMachine?
    @State private var sets: [WorkoutSet] = []
    @State private var currentSetNumber = 1
    
    var body: some View {
        NavigationView {
            Form {
                // マシン選択
                Section("マシン") {
                    Picker("マシン", selection: $selectedMachine) {
                        Text("選択してください").tag(nil as WorkoutMachine?)
                        ForEach(viewModel.machines) { machine in
                            HStack {
                                Image(systemName: machine.icon)
                                Text(machine.name)
                            }
                            .tag(machine as WorkoutMachine?)
                        }
                    }
                }
                
                // セット入力
                if selectedMachine != nil {
                    Section("セット") {
                        ForEach(sets) { set in
                            HStack {
                                Text("セット \(set.setNumber)")
                                Spacer()
                                Text("\(set.reps)回")
                                Text("\(String(format: "%.0f", set.weight))kg")
                            }
                        }
                        
                        Button("セットを追加") {
                            addSet()
                        }
                    }
                    
                    // セット詳細入力
                    if !sets.isEmpty {
                        Section("セット詳細") {
                            if let lastSet = sets.last {
                                Stepper("回数: \(lastSet.reps)", value: Binding(
                                    get: { lastSet.reps },
                                    set: { updateLastSet(reps: $0) }
                                ), in: 1...100)
                                
                                Stepper("重量: \(String(format: "%.0f", lastSet.weight))kg", value: Binding(
                                    get: { lastSet.weight },
                                    set: { updateLastSet(weight: $0) }
                                ), in: 0...500, step: 0.5)
                            }
                        }
                    }
                }
            }
            .navigationTitle("記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(selectedMachine == nil || sets.isEmpty)
                }
            }
        }
    }
    
    private func addSet() {
        let newSet = WorkoutSet(
            setNumber: currentSetNumber,
            reps: 10,
            weight: 50
        )
        sets.append(newSet)
        currentSetNumber += 1
    }
    
    private func updateLastSet(reps: Int) {
        if let index = sets.indices.last {
            sets[index].reps = reps
        }
    }
    
    private func updateLastSet(weight: Double) {
        if let index = sets.indices.last {
            sets[index].weight = weight
        }
    }
    
    private func saveRecord() {
        guard let machine = selectedMachine else { return }
        
        let record = WorkoutRecord(
            machineId: machine.id,
            date: Date(),
            sets: sets
        )
        
        viewModel.addRecord(record)
        dismiss()
    }
}
