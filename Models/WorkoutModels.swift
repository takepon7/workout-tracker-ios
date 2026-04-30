//
//  WorkoutModels.swift
//  WorkoutTracker
//
//  筋トレデータモデル
//

import Foundation

// MARK: - マシン
struct WorkoutMachine: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: MachineCategory
    var icon: String // SF Symbol名
    var isCustom: Bool
    
    init(id: UUID = UUID(), name: String, category: MachineCategory, icon: String, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.icon = icon
        self.isCustom = isCustom
    }
}

enum MachineCategory: String, CaseIterable, Codable {
    case chest = "胸"
    case back = "背中"
    case legs = "脚"
    case shoulders = "肩"
    case arms = "腕"
    case core = "体幹"
    case cardio = "有酸素"
    case other = "その他"
}

// MARK: - トレーニング記録
struct WorkoutRecord: Identifiable, Codable {
    let id: UUID
    let machineId: UUID
    let date: Date
    var sets: [WorkoutSet]
    
    init(id: UUID = UUID(), machineId: UUID, date: Date = Date(), sets: [WorkoutSet] = []) {
        self.id = id
        self.machineId = machineId
        self.date = date
        self.sets = sets
    }
    
    // 最大重量
    var maxWeight: Double {
        sets.map { $0.weight }.max() ?? 0
    }
    
    // 総重量
    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    // 推定1RM
    var estimated1RM: Double {
        guard let maxSet = sets.max(by: { $0.weight < $1.weight }) else { return 0 }
        return estimate1RM(weight: maxSet.weight, reps: maxSet.reps)
    }
    
    // Brzycki式で1RMを推定
    private func estimate1RM(weight: Double, reps: Int) -> Double {
        guard reps > 0 else { return 0 }
        return weight * (36.0 / (37.0 - Double(reps)))
    }
}

// MARK: - セット
struct WorkoutSet: Identifiable, Codable {
    let id: UUID
    var setNumber: Int
    var reps: Int
    var weight: Double // kg
    var restTime: Int? // 秒（オプション）
    
    init(id: UUID = UUID(), setNumber: Int, reps: Int, weight: Double, restTime: Int? = nil) {
        self.id = id
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.restTime = restTime
    }
}

// MARK: - デフォルトマシン
extension WorkoutMachine {
    static let defaultMachines: [WorkoutMachine] = [
        // 胸
        WorkoutMachine(name: "ベンチプレス", category: .chest, icon: "figure.strengthtraining.traditional"),
        WorkoutMachine(name: "インクラインベンチプレス", category: .chest, icon: "figure.strengthtraining.traditional"),
        WorkoutMachine(name: "ダンベルフライ", category: .chest, icon: "dumbbell.fill"),
        
        // 背中
        WorkoutMachine(name: "デッドリフト", category: .back, icon: "figure.strengthtraining.traditional"),
        WorkoutMachine(name: "ラットプルダウン", category: .back, icon: "figure.strengthtraining.traditional"),
        WorkoutMachine(name: "ロウイング", category: .back, icon: "figure.strengthtraining.traditional"),
        
        // 脚
        WorkoutMachine(name: "スクワット", category: .legs, icon: "figure.strengthtraining.traditional"),
        WorkoutMachine(name: "レッグプレス", category: .legs, icon: "figure.strengthtraining.traditional"),
        WorkoutMachine(name: "レッグカール", category: .legs, icon: "figure.strengthtraining.traditional"),
        
        // 肩
        WorkoutMachine(name: "ショルダープレス", category: .shoulders, icon: "figure.strengthtraining.traditional"),
        WorkoutMachine(name: "サイドレイズ", category: .shoulders, icon: "figure.strengthtraining.traditional"),
        
        // 腕
        WorkoutMachine(name: "アームカール", category: .arms, icon: "figure.strengthtraining.traditional"),
        WorkoutMachine(name: "トライセップス", category: .arms, icon: "figure.strengthtraining.traditional"),
        
        // 体幹
        WorkoutMachine(name: "クランチ", category: .core, icon: "figure.strengthtraining.traditional"),
        WorkoutMachine(name: "プランク", category: .core, icon: "figure.strengthtraining.traditional"),
        
        // 有酸素
        WorkoutMachine(name: "ランニング", category: .cardio, icon: "figure.run"),
        WorkoutMachine(name: "サイクリング", category: .cardio, icon: "bicycle"),
    ]
}
