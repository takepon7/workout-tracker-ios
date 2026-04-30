import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(languageManager.t("Home"), systemImage: "house.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label(languageManager.t("History"), systemImage: "clock.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
