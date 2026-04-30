import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var profileManager: ProfileManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.date, ascending: false)],
        animation: .default)
    private var workouts: FetchedResults<Workout>
    
    @State private var showLogging = false
    @State private var showProfile = false
    
    @AppStorage("weeklyGoal") private var weeklyGoal = 3
    @State private var showGoalEdit = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Weekly Progress Section
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(languageManager.t("Weekly Goal"))
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: { showGoalEdit = true }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            HStack(alignment: .lastTextBaseline) {
                                Text("\(workoutsThisWeek)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                Text("/ \(weeklyGoal)")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(workoutsThisWeek >= weeklyGoal ? languageManager.t("Goal Reached! 🔥") : "\(weeklyGoal - workoutsThisWeek) " + languageManager.t("more to go"))
                                .font(.caption)
                                .foregroundColor(workoutsThisWeek >= weeklyGoal ? .orange : .secondary)
                        }
                        
                        Spacer()
                        
                        // Ring Chart
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                            
                            Circle()
                                .trim(from: 0, to: min(CGFloat(workoutsThisWeek) / CGFloat(weeklyGoal), 1.0))
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        center: .center,
                                        startAngle: .degrees(0),
                                        endAngle: .degrees(360)
                                    ),
                                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut, value: workoutsThisWeek)
                        }
                        .frame(width: 100, height: 100)
                    }
                    .padding()
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    // Today's Progress Section
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Add Exercise Button (Primary Action - Moved to Top)
                        Button(action: {
                            showLogging = true
                        }) {
                            HStack {
                                Text(languageManager.t("Log Exercise"))
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        }
                        
                        Text(languageManager.t("Today's Training"))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        let todayWorkouts = workouts.filter { Calendar.current.isDateInToday($0.date ?? Date()) }
                        
                        if todayWorkouts.isEmpty {
                            Text(languageManager.t("No exercises yet today."))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                        } else {
                            ForEach(todayWorkouts, id: \.id) { workout in
                                if let exercises = workout.exercises?.allObjects as? [Exercise] {
                                    ForEach(exercises, id: \.id) { exercise in
                                        VStack(spacing: 0) {
                                            // Header with Exercise Name
                                            HStack {
                                                Text(languageManager.t(exercise.name ?? "Unknown"))
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                if let sets = exercise.sets, sets.count > 0 {
                                                    Text("Total: \(sets.count) sets")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .padding()
                                            .background(Color.gray.opacity(0.1))
                                            
                                            // Sets List
                                            if let sets = exercise.sets?.allObjects as? [ExerciseSet] {
                                                 let sortedSets = sets.sorted { $0.order < $1.order }
                                                 
                                                 if !sortedSets.isEmpty {
                                                     VStack(spacing: 0) {
                                                         ForEach(Array(sortedSets.enumerated()), id: \.element.id) { index, set in
                                                             HStack {
                                                                 Text("\(index + 1)")
                                                                     .font(.subheadline)
                                                                     .foregroundColor(.secondary)
                                                                     .frame(width: 30, alignment: .leading)
                                                                 
                                                                 Spacer()
                                                                 
                                                                 Text(String(format: "%.1f kg", set.weight))
                                                                     .font(.body)
                                                                     .fontWeight(.semibold)
                                                                     .frame(width: 80, alignment: .trailing)
                                                                 
                                                                 Text("x")
                                                                     .font(.caption)
                                                                     .foregroundColor(.secondary)
                                                                     .padding(.horizontal, 4)
                                                                 
                                                                 Text("\(set.reps)")
                                                                     .font(.body)
                                                                     .fontWeight(.semibold)
                                                                     .frame(width: 40, alignment: .leading)
                                                                     
                                                                 Text(languageManager.t("reps"))
                                                                    .font(.caption)
                                                                    .foregroundColor(.secondary)
                                                             }
                                                             .padding(.horizontal)
                                                             .padding(.vertical, 8)
                                                             
                                                             if index < sortedSets.count - 1 {
                                                                 Divider().padding(.horizontal)
                                                             }
                                                         }
                                                     }
                                                 }
                                            }
                                        }
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                        .padding(.bottom, 8)
                                    }
                                    .onDelete { indexSet in
                                        deleteExercise(at: indexSet, from: exercises)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(languageManager.t("Home"))
            .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                     Button(action: { languageManager.toggleLanguage() }) {
                         Text(languageManager.isJapanese ? "EN" : "JP")
                             .fontWeight(.bold)
                             .foregroundColor(.primary)
                     }
                 }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showProfile = true }) {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showLogging) {
                WorkoutLoggingView(context: viewContext)
            }
            .sheet(isPresented: $showProfile) {
                ProfileEditView()
            }
            .alert(languageManager.t("Set Weekly Goal"), isPresented: $showGoalEdit) {
                Button("1") { weeklyGoal = 1 }
                Button("2") { weeklyGoal = 2 }
                Button("3") { weeklyGoal = 3 }
                Button("4") { weeklyGoal = 4 }
                Button("5") { weeklyGoal = 5 }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(languageManager.t("How many times do you want to workout per week?"))
            }
        }
    }
    
    private func deleteExercise(at offsets: IndexSet, from exercises: [Exercise]) {
        offsets.map { exercises[$0] }.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private var workoutsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return workouts.filter { ($0.date ?? Date()) >= startOfWeek }.count
    }
}



#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ProfileManager())
        .environmentObject(LanguageManager())
}
