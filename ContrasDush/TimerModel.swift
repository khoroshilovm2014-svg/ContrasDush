import Foundation
import AVFoundation
import UIKit

enum Phase: String {
    case hot = "Горячая"
    case cold = "Холодная"
    case done = "Готово"
}

struct Preset: Identifiable, Codable {
    let id = UUID()
    let name: String
    let hotSeconds: Int
    let coldSeconds: Int
    let cycles: Int
}

class TimerModel: ObservableObject {
    @Published var currentPhase: Phase = .hot
    @Published var secondsLeft: Int = 0
    @Published var currentCycle: Int = 1
    @Published var totalCycles: Int = 3
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false

    var hotSeconds: Int = 30
    var coldSeconds: Int = 30

    private var timer: Timer?
    private var synth = AVSpeechSynthesizer()

    func start() {
        currentPhase = .hot
        secondsLeft = hotSeconds
        currentCycle = 1
        isRunning = true
        isFinished = false
        speak("Горячая вода")
        tick()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func tick() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.secondsLeft > 0 {
                self.secondsLeft -= 1

                if self.secondsLeft == 3 {
                    self.vibrate()
                }

                if self.secondsLeft == 0 {
                    self.nextPhase()
                }
            }
        }
    }

    private func nextPhase() {
        vibrate()

        if currentPhase == .hot {
            currentPhase = .cold
            secondsLeft = coldSeconds
            speak("Холодная вода")
        } else {
            if currentCycle >= totalCycles {
                finish()
            } else {
                currentCycle += 1
                currentPhase = .hot
                secondsLeft = hotSeconds
                speak("Цикл \(currentCycle). Горячая вода")
            }
        }
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isFinished = true
        currentPhase = .done
        speak("Готово. Молодец!")
        vibrate()
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        utterance.rate = 0.5
        synth.speak(utterance)
    }

    private func vibrate() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}