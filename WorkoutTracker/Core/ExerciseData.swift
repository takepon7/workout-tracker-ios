import Foundation

struct ExerciseCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let exercises: [String]
}

struct ExerciseData {
    static let categories: [ExerciseCategory] = [
        ExerciseCategory(name: "Chest", exercises: ["Bench Press", "Incline Bench Press", "Dumbbell Fly", "Cable Crossover", "Push Up"]),
        ExerciseCategory(name: "Back", exercises: ["Deadlift", "Pull Up", "Lat Pulldown", "Bent Over Row", "Seated Cable Row"]),
        ExerciseCategory(name: "Legs", exercises: ["Squat", "Leg Press", "Lunge", "Leg Extension", "Leg Curl", "Calf Raise"]),
        ExerciseCategory(name: "Shoulders", exercises: ["Shoulder Press", "Lateral Raise", "Front Raise", "Face Pull"]),
        ExerciseCategory(name: "Arms", exercises: ["Bicep Curl", "Tricep Extension", "Hammer Curl", "Skull Crusher"]),
        ExerciseCategory(name: "Core", exercises: ["Crunch", "Plank", "Russian Twist", "Leg Raise"])
    ]
    
    static let workoutTypes = ["General", "Chest", "Back", "Legs", "Shoulders", "Arms", "Core", "Cardio", "Full Body", "Push", "Pull"]
    
    static var allExercises: [String] {
        categories.flatMap { $0.exercises }.sorted()
    }
}
