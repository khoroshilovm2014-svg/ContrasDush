import Foundation

struct Preset: Identifiable {
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