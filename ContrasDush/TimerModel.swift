import Foundation
import AVFoundation
import UIKit
import AudioToolbox

enum Phase: String {
    case hot = "Горячая"
    case cold = "Холодная"
    case done = "Готово"
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
        playTransitionSound()
        tick()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        synth.stopSpeaking(at: .immediate)
    }

    private func tick() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.secondsLeft > 0 {
                self.secondsLeft -= 1
                if self.secondsLeft == 3 { self.vibrate() }
                if self.secondsLeft == 0 { self.nextPhase() }
            }
        }
    }

    private func nextPhase() {
        vibrate()
        playTransitionSound()

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
        playFinishSound()
        vibrate()
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        utterance.rate = 0.5
        synth.speak(utterance)
    }

    private func playTransitionSound() {
        // Приятный "динь" — системный звук iOS
        AudioServicesPlaySystemSound(1057)
    }

    private func playFinishSound() {
        // Звук завершения — тройной "динь"
        AudioServicesPlaySystemSound(1025)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            AudioServicesPlaySystemSound(1025)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            AudioServicesPlaySystemSound(1025)
        }
    }

    private func vibrate() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}