import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Label("Таймер", systemImage: "timer")
                }

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
    }
}