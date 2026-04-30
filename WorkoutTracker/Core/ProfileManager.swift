import SwiftUI
import Combine
import Foundation

class ProfileManager: ObservableObject {
    @Published var height: Double {
        didSet { UserDefaults.standard.set(height, forKey: "userHeight") }
    }
    @Published var weight: Double {
        didSet { UserDefaults.standard.set(weight, forKey: "userWeight") }
    }
    
    init() {
        self.height = UserDefaults.standard.double(forKey: "userHeight")
        self.weight = UserDefaults.standard.double(forKey: "userWeight")
        
        // Default values if not set
        if self.height == 0 { self.height = 170.0 }
        if self.weight == 0 { self.weight = 65.0 }
    }
    
    // Simple target calculation based on bodyweight multipliers
    func calculateTarget(for exerciseName: String) -> Double {
        let multiplier: Double
        
        switch exerciseName.lowercased() {
        case let name where name.contains("bench press"):
            multiplier = 1.0 // 1.0x Bodyweight
        case let name where name.contains("squat"):
            multiplier = 1.25 // 1.25x Bodyweight
        case let name where name.contains("deadlift"):
            multiplier = 1.5 // 1.5x Bodyweight
        default:
            multiplier = 0.8 // Default conservative target
        }
        
        return (weight * multiplier).rounded()
    }
}
