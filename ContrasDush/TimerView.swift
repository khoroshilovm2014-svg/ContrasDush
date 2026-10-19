import SwiftUI

struct TimerView: View {
    @StateObject private var model = TimerModel()

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: model.currentPhase)

            VStack(spacing: 20) {
                Spacer()
                
                // Фаза
                Text(model.currentPhase.rawValue)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)

                // Секунды
                Text("\(model.secondsLeft)")
                    .font(.system(size: 140, weight: .ultraLight, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .scaleEffect(model.secondsLeft <= 3 && model.secondsLeft > 0 && model.isRunning ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: model.secondsLeft)

                // Цикл (показываем только если это не переход)
                if model.currentPhase != .done {
                    Text("Цикл \(model.currentCycle) из \(model.totalCycles)")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // Кнопка управления
                if !model.isRunning && !model.isFinished {
                    Button(action: { model.start() }) {
                        Text("Начать")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                    }
                } else if model.isRunning {
                    Button(action: { model.stop() }) {
                        Text("Стоп")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(20)
                    }
                } else if model.isFinished {
                    Button(action: { model.start() }) {
                        Text("Ещё раз")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.green.opacity(0.5))
                            .cornerRadius(20)
                    }
                }
                
                Spacer().frame(height: 30)
            }
            .padding()
        }
    }

    var backgroundGradient: LinearGradient {
        switch model.currentPhase {
        case .hot:
            return LinearGradient(colors: [.red.opacity(0.9), .orange.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        case .cold:
            return LinearGradient(colors: [.blue.opacity(0.9), .cyan.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        case .transition:
            return LinearGradient(colors: [.purple.opacity(0.8), .indigo.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        case .done:
            return LinearGradient(colors: [.green.opacity(0.9), .teal.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        }
    }
}