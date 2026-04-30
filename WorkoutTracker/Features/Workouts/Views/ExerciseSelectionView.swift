import SwiftUI

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var selectedExercise: String
    
    var body: some View {
        List {
            ForEach(ExerciseData.categories) { category in
                Section(header: Text(languageManager.t(category.name))) {
                    ForEach(category.exercises, id: \.self) { exercise in
                        Button {
                            selectedExercise = exercise
                            dismiss()
                        } label: {
                            HStack {
                                Text(languageManager.t(exercise))
                                    .foregroundColor(.primary)
                                Spacer()
                                if exercise == selectedExercise {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(languageManager.t("Select Exercise"))
    }
}
