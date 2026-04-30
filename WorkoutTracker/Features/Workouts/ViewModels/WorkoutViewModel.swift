import Foundation
import CoreData
import Combine
import SwiftUI

class WorkoutViewModel: ObservableObject {
    private var viewContext: NSManagedObjectContext
    @Published var currentWorkout: Workout?
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func getOrCreateTodayWorkout() {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            if let existingWorkout = results.first {
                currentWorkout = existingWorkout
            } else {
                let newWorkout = Workout(context: viewContext)
                newWorkout.id = UUID()
                newWorkout.date = Date()
                newWorkout.workoutType = "Daily Log"
                currentWorkout = newWorkout
                saveContext()
            }
        } catch {
            print("Error fetching today's workout: \(error)")
        }
    }
    
    // Deprecated: explicit startNewWorkout
    // Use getOrCreateTodayWorkout() instead
    func addExercise(name: String) -> Exercise {
        if let workout = currentWorkout,
           let exercises = workout.exercises?.allObjects as? [Exercise],
           let existingExercise = exercises.first(where: { $0.name == name }) {
            return existingExercise
        }
        
        guard let workout = currentWorkout else { return Exercise(context: viewContext) }
        
        let exercise = Exercise(context: viewContext)
        exercise.id = UUID()
        exercise.name = name
        exercise.workout = workout
        
        saveContext()
        return exercise
    }
    
    func addSet(to exercise: Exercise, weight: Double, reps: Int16, rpe: Int16, setType: String) {
        let set = ExerciseSet(context: viewContext)
        set.id = UUID()
        set.weight = weight
        set.reps = reps
        set.rpe = rpe
        set.setType = setType
        set.order = Int16(exercise.sets?.count ?? 0) + 1
        set.exercise = exercise
        
        saveContext()
        objectWillChange.send() // Force UI update
    }
    
    func finishWorkout() {
        currentWorkout = nil
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func getLastPerformance(for exerciseName: String) -> String? {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", exerciseName)
        request.sortDescriptors = [NSSortDescriptor(key: "workout.date", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            if let lastExercise = results.first, let sets = lastExercise.sets?.allObjects as? [ExerciseSet], let bestSet = sets.max(by: { $0.weight < $1.weight }) {
                return "\(Int(bestSet.weight))kg x \(bestSet.reps)"
            }
        } catch {
            print("Error fetching last performance: \(error)")
        }
        return nil
    }
}
