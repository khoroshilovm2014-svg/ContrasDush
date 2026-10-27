import Foundation

// Структура одного цикла
struct CycleConfig: Identifiable, Codable {
    var id = UUID()
    var hotSeconds: Int
    var coldSeconds: Int
}

// Хранилище для наших циклов (сохраняется в памяти телефона)
class AppSettings: ObservableObject {
    @Published var cycles: [CycleConfig] {
        didSet {
            save()
        }
    }
    
    init() {
        // Пытаемся загрузить сохраненные циклы, если нет — ставим дефолтный (30/30)
        if let data = UserDefaults.standard.data(forKey: "savedCycles"),
           let decoded = try? JSONDecoder().decode([CycleConfig].self, from: data) {
            self.cycles = decoded
        } else {
            self.cycles = [CycleConfig(hotSeconds: 30, coldSeconds: 30)]
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(cycles) {
            UserDefaults.standard.set(encoded, forKey: "savedCycles")
        }
    }
}