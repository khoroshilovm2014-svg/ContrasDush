import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Настройка циклов")) {
                    ForEach(Array(settings.cycles.enumerated()), id: \.element.id) { index, cycle in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Цикл \(index + 1)").font(.headline)
                            
                            HStack {
                                Text("🔥 Горячая: \(cycle.hotSeconds) сек")
                                Slider(value: Binding(
                                    get: { Double(cycle.hotSeconds) },
                                    set: { newValue in
                                        settings.cycles[index].hotSeconds = Int(newValue)
                                    }
                                ), in: 5...180, step: 5)
                            }
                            
                            HStack {
                                Text("❄️ Холодная: \(cycle.coldSeconds) сек")
                                Slider(value: Binding(
                                    get: { Double(cycle.coldSeconds) },
                                    set: { newValue in
                                        settings.cycles[index].coldSeconds = Int(newValue)
                                    }
                                ), in: 5...180, step: 5)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete { indexSet in
                        settings.cycles.remove(atOffsets: indexSet)
                    }
                    
                    Button(action: {
                        let lastCycle = settings.cycles.last ?? CycleConfig(hotSeconds: 30, coldSeconds: 30)
                        settings.cycles.append(CycleConfig(hotSeconds: lastCycle.hotSeconds, coldSeconds: lastCycle.coldSeconds))
                    }) {
                        Label("Добавить цикл", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Настройки")
        }
    }
}