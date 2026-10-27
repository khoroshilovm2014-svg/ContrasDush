import SwiftUI

struct ContentView: View {
    @StateObject var settings = AppSettings()

    var body: some View {
        TabView {
            TimerView()
                .environmentObject(settings)
                .tabItem {
                    Label("Таймер", systemImage: "timer")
                }

            SettingsView()
                .environmentObject(settings)
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
    }
}