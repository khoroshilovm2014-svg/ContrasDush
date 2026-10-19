import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct SettingsView: View {
    @State private var hotSeconds: Double = 30
    @State private var coldSeconds: Double = 30
    @State private var cycles: Double = 3
    @State private var musicChoice: String = "videoclub"
    @State private var showFilePicker: Bool = false

    init() {
        let hot = UserDefaults.standard.integer(forKey: "hot")
        let cold = UserDefaults.standard.integer(forKey: "cold")
        let cyc = UserDefaults.standard.integer(forKey: "cycles")
        let music = UserDefaults.standard.string(forKey: "musicChoice") ?? "videoclub"

        _hotSeconds = State(initialValue: hot > 0 ? Double(hot) : 30)
        _coldSeconds = State(initialValue: cold > 0 ? Double(cold) : 30)
        _cycles = State(initialValue: cyc > 0 ? Double(cyc) : 3)
        _musicChoice = State(initialValue: music)
    }

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
                        UserDefaults.standard.set(musicChoice, forKey: "musicChoice")
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

                Section("Музыка") {
                    Picker("Фоновая музыка", selection: $musicChoice) {
                        Text("Videoclub — Amour plastique").tag("videoclub")
                        Text("Без музыки").tag("none")
                        Text("Своя (загруженная)").tag("custom")
                    }
                    .pickerStyle(.inline)

                    if musicChoice == "custom" {
                        Button("Загрузить MP3") {
                            showFilePicker = true
                        }

                        if let name = UserDefaults.standard.string(forKey: "customMusicName") {
                            Text("Загружено: \(name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Link(destination: URL(string: "https://t.me/mixan2907")!) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.blue)
                            Text("Написать разработчику")
                                .foregroundColor(.blue)
                        }
                    }
                }

                Section {
                    Text("ContrasDush v1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Настройки")
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        saveCustomMusic(from: url)
                    }
                case .failure(let error):
                    print("Ошибка: \(error)")
                }
            }
        }
    }

    private func saveCustomMusic(from url: URL) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destination = documents.appendingPathComponent("custom_music.mp3")

        do {
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: url, to: destination)
            UserDefaults.standard.set("custom_music.mp3", forKey: "customMusicName")
            UserDefaults.standard.set("custom", forKey: "musicChoice")
            musicChoice = "custom"
            print("OK: музыка сохранена")
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
}