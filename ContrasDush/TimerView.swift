import SwiftUI

struct TimerView: View {
    @StateObject private var model = TimerModel()

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Фаза
                Text(model.currentPhase.rawValue)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)

                // Секунды
                Text("\(model.secondsLeft)")
                    .font(.system(size: 120, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()

                // Цикл
                if model.isRunning || model.secondsLeft > 0 {
                    Text("Цикл \(model.currentCycle) из \(model.totalCycles)")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                // Кнопки
                if !model.isRunning && !model.isFinished {
                    Button("Начать") {
                        model.start()
                    }
                    .buttonStyle(PrimaryButtonStyle())

                } else if model.isRunning {
                    Button("Стоп") {
                        model.stop()
                    }
                    .buttonStyle(SecondaryButtonStyle())

                } else if model.isFinished {
                    Button("Ещё раз") {
                        model.start()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }

                Spacer()
            }
            .padding()
        }
    }

    var backgroundGradient: LinearGradient {
        if model.currentPhase == .hot {
            return LinearGradient(
                colors: [.red.opacity(0.8), .orange.opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
        } else if model.currentPhase == .cold {
            return LinearGradient(
                colors: [.blue.opacity(0.8), .cyan.opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [.green.opacity(0.8), .teal.opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white.opacity(0.2))
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.black.opacity(0.3))
            .cornerRadius(20)
    }
}