import Foundation

struct Presets {
    static let all: [Preset] = [
        Preset(name: "Классика", hotSeconds: 30, coldSeconds: 30, cycles: 3),
        Preset(name: "Продвинутая", hotSeconds: 60, coldSeconds: 30, cycles: 4),
        Preset(name: "Эксперт", hotSeconds: 90, coldSeconds: 60, cycles: 5),
    ]
}