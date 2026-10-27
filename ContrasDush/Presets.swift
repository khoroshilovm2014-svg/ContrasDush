import Foundation

// Оставляем твой Preset для готовых схем
struct Preset: Identifiable, Codable {
    let id = UUID()
    let name: String
    let hotSeconds: Int
    let coldSeconds: Int
    let cycles: Int
}

struct Presets {
    static let all: [Preset] = [
        Preset(name: "Классика", hotSeconds: 30, coldSeconds: 30, cycles: 3),
        Preset(name: "Продвинутая", hotSeconds: 60, coldSeconds: 30, cycles: 4),
        Preset(name: "Эксперт", hotSeconds: 90, coldSeconds: 60, cycles: 5),
    ]
}

// НОВОЕ: Структура для кастомных циклов
struct CustomCycle: Identifiable, Codable {
    var id = UUID()
    var hotSeconds: Int
    var coldSeconds: Int
}

// НОВОЕ: Хранилище настроек (циклы и музыка)
class AppSettings: ObservableObject {
    @Published var cycles: [CustomCycle] {
        didSet { save() }
    }
    @Published var musicFileName: String? {
        didSet { save() }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "savedCycles"),
           let decoded = try? JSONDecoder().decode([CustomCycle].self, from: data) {
            self.cycles = decoded
        } else {
            self.cycles = [CustomCycle(hotSeconds: 30, coldSeconds: 30)]
        }
        self.musicFileName = UserDefaults.standard.string(forKey: "savedMusic")
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(cycles) {
            UserDefaults.standard.set(encoded, forKey: "savedCycles")
        }
        UserDefaults.standard.set(musicFileName, forKey: "savedMusic")
    }
    
    func saveMusic(from url: URL) {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let destinationUrl = documentsDirectory.appendingPathComponent(url.lastPathComponent)
        try? fileManager.removeItem(at: destinationUrl)
        do {
            try fileManager.copyItem(at: url, to: destinationUrl)
            DispatchQueue.main.async { self.musicFileName = destinationUrl.lastPathComponent }
        } catch { print("Ошибка: \(error)") }
    }
    
    var musicURL: URL? {
        guard let fileName = musicFileName else { return nil }
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsDirectory.appendingPathComponent(fileName)
    }
}