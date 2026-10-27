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
    @Published var currentCycleIndex: Int = 0
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false
    
    var cycles: [CycleConfig] = []
    
    private var timer: Timer?
    private var synth = AVSpeechSynthesizer()
    
    // Индекс текущего шага: 0 - горячая, 1 - холодная
    private var phaseInCycle: Int = 0 
    
    func start(with cycles: [CycleConfig]) {
        guard !cycles.isEmpty else { return }
        self.cycles = cycles
        currentCycleIndex = 0
        phaseInCycle = 0
        currentPhase = .hot
        secondsLeft = cycles[0].hotSeconds
        isRunning = true
        isFinished = false
        speak("Цикл 1. Горячая вода")
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
                
                if self.secondsLeft == 3 { self.vibrate() }
                if self.secondsLeft == 0 { self.nextPhase() }
            }
        }
    }
    
    private func nextPhase() {
        vibrate()
        let currentCycle = cycles[currentCycleIndex]
        
        if phaseInCycle == 0 {
            // Переключаемся на холодную
            currentPhase = .cold
            secondsLeft = currentCycle.coldSeconds
            phaseInCycle = 1
            speak("Холодная вода")
        } else {
            // Конец цикла. Проверяем, есть ли еще циклы
            currentCycleIndex += 1
            if currentCycleIndex >= cycles.count {
                finish()
            } else {
                phaseInCycle = 0
                currentPhase = .hot
                secondsLeft = cycles[currentCycleIndex].hotSeconds
                speak("Цикл \(currentCycleIndex + 1). Горячая вода")
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