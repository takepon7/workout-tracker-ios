import SwiftUI
import CoreData

struct EditSetSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @ObservedObject var set: ExerciseSet
    private var viewContext: NSManagedObjectContext
    
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var rpe: Int = 8
    
    init(set: ExerciseSet, context: NSManagedObjectContext) {
        self.set = set
        self.viewContext = context
        _weight = State(initialValue: String(set.weight))
        _reps = State(initialValue: String(set.reps))
        _rpe = State(initialValue: Int(set.rpe))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(languageManager.t("Edit Set"))) {
                    HStack {
                        Text(languageManager.t("Weight (kg)"))
                        Spacer()
                        TextField("0", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text(languageManager.t("Reps"))
                        Spacer()
                        TextField("0", text: $reps)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text(languageManager.t("RPE") + ": \(rpe)")
                        Slider(value: Binding(get: { Double(rpe) }, set: { rpe = Int($0) }), in: 1...10, step: 1)
                    }
                }
                
                Section {
                    Button(action: save) {
                        Text(languageManager.t("Update"))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: deleteSet) {
                        Text(languageManager.t("Delete Set"))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(languageManager.t("Edit Set"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(languageManager.t("Cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func save() {
        if let w = Double(weight), let r = Int16(reps) {
            set.weight = w
            set.reps = r
            set.rpe = Int16(rpe)
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving set: \(error)")
            }
        }
        dismiss()
    }
    
    private func deleteSet() {
        viewContext.delete(set)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting set: \(error)")
        }
        dismiss()
    }
}
