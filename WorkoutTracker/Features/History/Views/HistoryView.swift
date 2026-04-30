import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedDate: DateComponents? = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.date, ascending: false)],
        animation: .default)
    private var workouts: FetchedResults<Workout>
    
    var body: some View {
        NavigationView {
            VStack {
                CalendarView(
                    interval: DateInterval(start: Date().addingTimeInterval(-31536000), end: Date().addingTimeInterval(31536000)),
                    dateSelected: $selectedDate,
                    displayEvents: workouts.compactMap { $0.date }
                )
                .frame(height: 380)
                .padding(.bottom)
                
                if let selectedDate = selectedDate, let date = Calendar.current.date(from: selectedDate) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(date.formatted(date: .long, time: .omitted))
                                .font(.headline)
                                .padding(.horizontal)
                            
                            let daysWorkouts = workouts.filter {
                                Calendar.current.isDate($0.date ?? Date(), inSameDayAs: date)
                            }
                            
                            if daysWorkouts.isEmpty {
                                Text(languageManager.t("No workouts recorded"))
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(daysWorkouts) { workout in
                                    WorkoutCard(workout: workout, languageManager: languageManager)
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                }
            }
            .navigationTitle(languageManager.t("History"))
        }
    }
}

struct WorkoutCard: View {
    @ObservedObject var workout: Workout
    var languageManager: LanguageManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(languageManager.t(workout.workoutType ?? "General"))
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text((workout.date ?? Date()).formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            
            if let exercises = workout.exercises?.allObjects as? [Exercise] {
                ForEach(exercises) { exercise in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(languageManager.t(exercise.name ?? "Unknown"))
                                .font(.headline)
                            Spacer()
                            if let sets = exercise.sets?.allObjects as? [ExerciseSet] {
                                Text("\(sets.count) sets")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let sets = exercise.sets?.allObjects as? [ExerciseSet] {
                             let sortedSets = sets.sorted { $0.order < $1.order }
                             
                             ForEach(sortedSets, id: \.id) { set in
                                 HStack {
                                     Text("\(set.reps) x \(String(format: "%.1f", set.weight)) kg")
                                         .font(.subheadline)
                                         .foregroundColor(.secondary)
                                     
                                     if let type = set.setType, type != "Normal" {
                                         Text(languageManager.t(type))
                                             .font(.caption2)
                                             .padding(2)
                                             .background(Color.gray.opacity(0.2))
                                             .cornerRadius(4)
                                     }
                                 }
                             }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    Divider()
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

#Preview {
    HistoryView()
        .environmentObject(LanguageManager())
}
