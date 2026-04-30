import SwiftUI
import CoreData

struct WorkoutLoggingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: WorkoutViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedExerciseName: String = "Bench Press"
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var currentExercise: Exercise?
    @State private var previousPerformance: String?
    @State private var rpe: Int = 8
    @State private var setType: String = "Normal"
    
    let exerciseOptions = ["Bench Press", "Squat", "Deadlift", "Shoulder Press", "Pull Up"]
    let setTypes = ["Normal", "Warmup", "Drop", "Failure"]
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(context: context))
    }
    
    @State private var showCelebration = false
    @State private var selectedSetToEdit: ExerciseSet?
    
    // Timer state
    @State private var isTimerRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    // Inputs (Changed to Selection)
    @State private var selectedWeightIndex: Int = 40 // Default around 40kg
    @State private var selectedRepIndex: Int = 9 // Default 10 reps
    
    let weightOptions: [Double] = Array(stride(from: 1.0, through: 200.0, by: 1.0))
    let repOptions: [Int] = Array(1...100)
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 0) {
                    Form {
                        Section(header: Text(languageManager.t("Select Exercise"))) {
                             Picker(languageManager.t("Exercise"), selection: $selectedExerciseName) {
                                 ForEach(exerciseOptions, id: \.self) { option in
                                     Text(languageManager.t(option)).tag(option)
                                 }
                             }
                             .pickerStyle(.wheel)
                             .frame(height: 100)
                        }
                        
                        Section(header: Text(languageManager.t(selectedExerciseName))) {
                            HStack {
                                Picker(languageManager.t("Weight"), selection: $selectedWeightIndex) {
                                    ForEach(0..<weightOptions.count, id: \.self) { index in
                                        Text(String(format: "%.1f kg", weightOptions[index])).tag(index)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 120)
                                .clipped()
                                
                                Picker(languageManager.t("Reps"), selection: $selectedRepIndex) {
                                    ForEach(0..<repOptions.count, id: \.self) { index in
                                        Text("\(repOptions[index]) reps").tag(index)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 120)
                                .clipped()
                            }
                            
                            HStack {
                                Text(languageManager.t("RPE") + ": \(rpe)")
                                Slider(value: Binding(get: { Double(rpe) }, set: { rpe = Int($0) }), in: 1...10, step: 1)
                            }
                            
                            Picker(languageManager.t("Set Type"), selection: $setType) {
                                ForEach(setTypes, id: \.self) { type in
                                    Text(languageManager.t(type)).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Recorded Sets List
                        if let workout = viewModel.currentWorkout,
                           let exercises = workout.exercises?.allObjects as? [Exercise],
                           let currentExercise = exercises.first(where: { $0.name == selectedExerciseName }),
                           let sets = currentExercise.sets, sets.count > 0 {
                            
                            ExerciseSectionView(exercise: currentExercise, selectedSetBinding: $selectedSetToEdit, languageManager: languageManager)
                        }
                    } // End Form
                    
                    // Bottom Button Area
                    VStack(spacing: 16) {
                        if isTimerRunning {
                             Text(timeString(from: elapsedTime))
                                 .font(.system(size: 60, weight: .bold, design: .monospaced))
                                 .foregroundColor(.blue)
                                 .padding(.bottom, 8)
                        }
                        
                        Button(action: {
                            toggleTimer()
                        }) {
                            Text(isTimerRunning ? languageManager.t("Finish Set") : languageManager.t("Start Set"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isTimerRunning ? Color.red : Color.blue)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))
                }
                .navigationTitle(languageManager.t("Log Exercise"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(languageManager.t("Cancel")) {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(languageManager.t("Finish")) {
                            // Just ensure context is saved and close
                            try? viewContext.save()
                            showCelebration = true
                        }
                    }
                }
            } // End NavigationView
            .onAppear {
                viewModel.getOrCreateTodayWorkout()
                previousPerformance = viewModel.getLastPerformance(for: selectedExerciseName)
                
                // Set default weight/reps closest to previous or initial defaults
                // (Logic can be refined, keeping simple for now)
            }
            .fullScreenCover(isPresented: $showCelebration) {
                WorkoutCompletionView()
            }
        } // End ZStack
    } // End body
    
    private func toggleTimer() {
        if isTimerRunning {
            // Stop
            stopTimer()
            addSet()
            isTimerRunning = false
        } else {
            // Start
            startTimer()
            isTimerRunning = true
        }
    }
    
    private func startTimer() {
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func addSet() {
        if currentExercise == nil || currentExercise?.name != selectedExerciseName {
            currentExercise = viewModel.addExercise(name: selectedExerciseName)
        }
        
        let weight = weightOptions[selectedWeightIndex]
        let reps = Int16(repOptions[selectedRepIndex])
        
        guard let exercise = currentExercise else { return }
        
        viewModel.addSet(to: exercise, weight: weight, reps: reps, rpe: Int16(rpe), setType: setType)
        
        // Don't clear inputs with pickers, usually they stay on last used value which is convenient
    }
}

struct ExerciseSectionView: View {
    @ObservedObject var exercise: Exercise
    @Binding var selectedSetBinding: ExerciseSet?
    var languageManager: LanguageManager
    
    var body: some View {
        Section(header: Text(languageManager.t(exercise.name ?? "Unknown"))) {
            // Header Row
            HStack {
                Text(languageManager.t("Weight (kg)")).font(.caption).frame(width: 80, alignment: .leading)
                Text(languageManager.t("Reps")).font(.caption).frame(width: 50, alignment: .center)
                Text(languageManager.t("RPE")).font(.caption).frame(width: 40, alignment: .center)
                Spacer()
            }
            .foregroundColor(.secondary)
            .listRowBackground(Color.gray.opacity(0.1))
            
            if let sets = exercise.sets?.allObjects as? [ExerciseSet] {
                ForEach(sets.sorted(by: { $0.order < $1.order }), id: \.id) { set in
                    Button(action: {
                        selectedSetBinding = set
                    }) {
                        HStack {
                            Text(String(format: "%.1f kg", set.weight))
                                .frame(width: 80, alignment: .leading)
                                .foregroundColor(.primary)
                            Text("\(set.reps) reps")
                                .frame(width: 60, alignment: .center)
                                .foregroundColor(.primary)
                            Text("\(set.rpe)")
                                .frame(width: 40, alignment: .center)
                                .foregroundColor(set.rpe >= 9 ? .red : .orange)
                            
                            Spacer()
                            
                            if let type = set.setType, type != "Normal" {
                                Text(languageManager.t(type))
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(4)
                                    .foregroundColor(.primary)
                            }
                            
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}
