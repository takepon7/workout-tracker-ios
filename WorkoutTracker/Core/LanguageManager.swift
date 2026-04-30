import SwiftUI
import Combine

class LanguageManager: ObservableObject {
    @Published var isJapanese: Bool {
        didSet { UserDefaults.standard.set(isJapanese, forKey: "isJapanese") }
    }
    
    init() {
        self.isJapanese = UserDefaults.standard.bool(forKey: "isJapanese")
    }
    
    func toggleLanguage() {
        isJapanese.toggle()
    }
    
    func t(_ key: String) -> String {
        if isJapanese {
            return translations[key] ?? key
        }
        return key
    }
    
    private let translations: [String: String] = [
        "Home": "ホーム",
        "History": "履歴",
        "Settings": "設定",
        "Profile": "プロフィール",
        "Home Screen": "ホーム画面",
        "Muscle Map & Start Workout": "筋肉マップ & ワークアウト開始",
        "History Screen": "履歴画面",
        "Workout Logs will appear here": "ワークアウト履歴がここに表示されます",
        "Total Workouts": "総ワークアウト数",
        "Next Goal": "次の目標",
        "Bench Press Target": "ベンチプレス目標",
        "based on": "基準: ",
        "kg bodyweight": "kg 体重",
        "Start Workout": "ワークアウト開始",
        "Body Metrics": "身体測定値",
        "Height (cm)": "身長 (cm)",
        "Body Weight (kg)": "体重 (kg)",
        "Targets are calculated based on your body weight.": "目標値は体重に基づいて計算されます。",
        "Save": "保存",
        "Current Session": "現在のセッション",
        "Workout In Progress": "ワークアウト中",
        "Add Exercise": "種目追加",
        "Exercise": "種目",
        "Weight (kg)": "重量 (kg)",
        "Reps": "回数",
        "Add Set": "セット追加",
        "Log Workout": "ワークアウト記録",
        "Finish": "終了",
        "Bench Press": "ベンチプレス",
        "Squat": "スクワット",
        "Deadlift": "デッドリフト",
        "Shoulder Press": "ショルダープレス",
        "Pull Up": "懸垂",
        "Switch to Japanese": "日本語へ切替",
        "Switch to English": "英語へ切替",
        "Unknown": "不明",
        "Workout Details": "ワークアウト詳細",
        "Workout Type": "ワークアウト種別",
        "Select Exercise": "種目を選択",
        "No workouts recorded": "記録されたワークアウトはありません",
        
        // Workout Types & Categories
        "General": "一般",
        "Chest": "胸",
        "Back": "背中",
        "Legs": "脚",
        "Shoulders": "肩",
        "Arms": "腕",
        "Core": "体幹",
        "Cardio": "有酸素",
        "Full Body": "全身",
        "Push": "プッシュ",
        "Pull": "プル",
        
        // Exercises (Chest)
        "Incline Bench Press": "インクラインベンチプレス",
        "Dumbbell Fly": "ダンベルフライ",
        "Cable Crossover": "ケーブルクロスオーバー",
        "Push Up": "腕立て伏せ",
        
        // Back
        "Lat Pulldown": "ラットプルダウン",
        "Bent Over Row": "ベントオーバーロウ",
        "Seated Cable Row": "シーテッドケーブルロウ",
        
        // Legs
        "Leg Press": "レッグプレス",
        "Lunge": "ランジ",
        "Leg Extension": "レッグエクステンション",
        "Leg Curl": "レッグカール",
        "Calf Raise": "カーフレイズ",
        
        // Shoulders
        "Lateral Raise": "サイドレイズ",
        "Front Raise": "フロントレイズ",
        "Face Pull": "フェイスプル",
        
        // Arms
        "Bicep Curl": "バイセップカール",
        "Tricep Extension": "トライセップエクステンション",
        "Hammer Curl": "ハンマーカール",
        "Skull Crusher": "スカルクラッシャー",
        
        // Core
        "Crunch": "クランチ",
        "Plank": "プランク",
        "Russian Twist": "ロシアンツイスト",
        "Leg Raise": "レッグレイズ",
        
        // Pro Features
        "Set Type": "セットタイプ",
        "Normal": "ノーマル",
        "Warmup": "ウォームアップ",
        "Drop": "ドロップ",
        "Failure": "限界まで",
        "Notes": "メモ",
        "Previous": "前回",
        "Weekly Goal": "今週の目標",
        "Goal Reached! 🔥": "目標達成! 🔥",
        "more to go": "回で達成",
        "Log your training session": "トレーニングを記録しよう",
        "Recent Activity": "最近のアクティビティ",
        "No workouts yet. Start training!": "履歴がありません。トレーニングを始めましょう！",
        "Exercises": "種目",
        "Edit Set": "セット編集",
        "Update": "更新",
        "Cancel": "キャンセル",
        "sets": "セット",
        "Today's Training": "今日のトレーニング",
        "Log Exercise": "種目記録"
    ]
}
