import Foundation
import AVFoundation
import UIKit

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
    
    // НОВОЕ: Массив циклов и плеер
    var customCycles: [CustomCycle] = []
    private var currentCycleIndex: Int = 0
    private var phaseInCycle: Int = 0
    private var audioPlayer: AVAudioPlayer?

    private var timer: Timer?
    private var synth = AVSpeechSynthesizer()

    // Обновленный старт (принимает циклы и музыку)
    func start(cycles: [CustomCycle], musicURL: URL?) {
        self.customCycles = cycles
        self.currentCycleIndex = 0
        self.phaseInCycle = 0
        
        currentPhase = .hot
        secondsLeft = cycles[0].hotSeconds
        currentCycle = 1
        totalCycles = cycles.count
        isRunning = true
        isFinished = false
        
        // Музыка
        if let url = musicURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
            } catch { print("Ошибка музыки: \(error)") }
        }
        
        speak("Цикл 1. Горячая вода")
        tick()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        audioPlayer?.stop()
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
        let current = customCycles[currentCycleIndex]

        if phaseInCycle == 0 {
            currentPhase = .cold
            secondsLeft = current.coldSeconds
            phaseInCycle = 1
            speak("Холодная вода")
        } else {
            currentCycleIndex += 1
            if currentCycleIndex >= customCycles.count {
                finish()
            } else {
                phaseInCycle = 0
                currentPhase = .hot
                secondsLeft = customCycles[currentCycleIndex].hotSeconds
                currentCycle = currentCycleIndex + 1
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
        audioPlayer?.stop()
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