import SwiftUI

struct SettingsView: View {
    @State private var hotSeconds: Double = 30
    @State private var coldSeconds: Double = 30
    @State private var cycles: Double = 3

    var body: some View {
        NavigationView {
            Form {
                Section("Своя схема") {
                    VStack(alignment: .leading) {
                        Text("Горячая: \(Int(hotSeconds)) сек")
                        Slider(value: $hotSeconds, in: 10...120, step: 5)
                    }
                    VStack(alignment: .leading) {
                        Text("Холодная: \(Int(coldSeconds)) сек")
                        Slider(value: $coldSeconds, in: 10...120, step: 5)
                    }
                    VStack(alignment: .leading) {
                        Text("Повторов: \(Int(cycles))")
                        Slider(value: $cycles, in: 1...10, step: 1)
                    }
                }
                Section {
                    Button("Применить") {
                        UserDefaults.standard.set(Int(hotSeconds), forKey: "hot")
                        UserDefaults.standard.set(Int(coldSeconds), forKey: "cold")
                        UserDefaults.standard.set(Int(cycles), forKey: "cycles")
                    }
                }
                Section("Готовые схемы") {
                    ForEach(Presets.all) { preset in
                        Button(preset.name) {
                            hotSeconds = Double(preset.hotSeconds)
                            coldSeconds = Double(preset.coldSeconds)
                            cycles = Double(preset.cycles)
                        }
                    }
                }
            }
            .navigationTitle("Настройки")
        }
    }
}