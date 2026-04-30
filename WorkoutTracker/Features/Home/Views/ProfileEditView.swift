import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var profileManager: ProfileManager
    @Environment(\.dismiss) var dismiss
    
    @State private var heightString: String = ""
    @State private var weightString: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(languageManager.t("Body Metrics"))) {
                    HStack {
                        Text(languageManager.t("Height (cm)"))
                        Spacer()
                        TextField("170", text: $heightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text(languageManager.t("Body Weight (kg)"))
                        Spacer()
                        TextField("65", text: $weightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(footer: Text(languageManager.t("Targets are calculated based on your body weight."))) {
                    Button(languageManager.t("Save")) {
                        save()
                    }
                }
            }
            .navigationTitle(languageManager.t("Profile"))
            .onAppear {
                heightString = String(profileManager.height)
                weightString = String(profileManager.weight)
            }
        }
    }
    
    private func save() {
        if let h = Double(heightString), let w = Double(weightString) {
            profileManager.height = h
            profileManager.weight = w
        }
        dismiss()
    }
}
