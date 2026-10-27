import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var showFileImporter = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Своя схема циклов")) {
                    ForEach(Array(settings.cycles.enumerated()), id: \.element.id) { index, cycle in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Цикл \(index + 1)").font(.headline)
                            HStack {
                                Text("🔥 Горячая: \(cycle.hotSeconds) с").frame(width: 120, alignment: .leading)
                                Slider(value: Binding(
                                    get: { Double(cycle.hotSeconds) },
                                    set: { settings.cycles[index].hotSeconds = Int($0) }
                                ), in: 5...180, step: 5)
                            }
                            HStack {
                                Text("❄️ Холодная: \(cycle.coldSeconds) с").frame(width: 120, alignment: .leading)
                                Slider(value: Binding(
                                    get: { Double(cycle.coldSeconds) },
                                    set: { settings.cycles[index].coldSeconds = Int($0) }
                                ), in: 5...180, step: 5)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete { settings.cycles.remove(atOffsets: $0) }
                    
                    Button(action: {
                        let last = settings.cycles.last ?? CustomCycle(hotSeconds: 30, coldSeconds: 30)
                        settings.cycles.append(CustomCycle(hotSeconds: last.hotSeconds, coldSeconds: last.coldSeconds))
                    }) {
                        Label("Добавить цикл", systemImage: "plus.circle.fill")
                    }
                }
                
                Section(header: Text("Фоновая музыка")) {
                    Button(action: { showFileImporter = true }) {
                        HStack {
                            Image(systemName: "music.note")
                            Text(settings.musicFileName != nil ? "Музыка загружена" : "Выбрать музыку из файлов")
                        }
                    }
                    if settings.musicFileName != nil {
                        Button(action: { settings.musicFileName = nil }) {
                            Text("Удалить музыку").foregroundColor(.red)
                        }
                    }
                }

                Section(header: Text("Готовые схемы")) {
                    ForEach(Presets.all) { preset in
                        Button(preset.name) {
                            settings.cycles = Array(repeating: CustomCycle(hotSeconds: preset.hotSeconds, coldSeconds: preset.coldSeconds), count: preset.cycles)
                        }
                    }
                }
            }
            .navigationTitle("Настройки")
            // Разрешаем вообще все файлы (чтобы 100% можно было выбрать mp3)
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.item]) { result in
                switch result {
                case .success(let url):
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    settings.saveMusic(from: url)
                case .failure(let error):
                    print("Ошибка файла: \(error.localizedDescription)")
                }
            }
        }
    }
}