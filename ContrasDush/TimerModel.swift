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

    var cycles: [CustomCycle] = []
    private var currentCycleIndex: Int = 0
    private var phaseInCycle: Int = 0
    private var audioPlayer: AVAudioPlayer?

    private var timer: Timer?

    func start(cycles: [CustomCycle], musicURL: URL?) {
        guard !cycles.isEmpty else { return }
        self.cycles = cycles
        currentCycleIndex = 0
        phaseInCycle = 0
        
        currentPhase = .hot
        secondsLeft = cycles[0].hotSeconds
        currentCycle = 1
        totalCycles = cycles.count
        isRunning = true
        isFinished = false
        
        if let url = musicURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
            } catch { print("Ошибка музыки: \(error)") }
        }
        
        playBeep() // Тот самый звук при старте
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
        playBeep() // Тот самый звук при смене воды
        
        let current = cycles[currentCycleIndex]

        if phaseInCycle == 0 {
            currentPhase = .cold
            secondsLeft = current.coldSeconds
            phaseInCycle = 1
        } else {
            currentCycleIndex += 1
            if currentCycleIndex >= cycles.count {
                finish()
            } else {
                phaseInCycle = 0
                currentPhase = .hot
                secondsLeft = cycles[currentCycleIndex].hotSeconds
                currentCycle = currentCycleIndex + 1
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
        playBeep() // Тот самый звук в конце
        vibrate()
    }

    // ТОТ САМЫЙ ЗВУК 1057
    private func playBeep() {
        AudioServicesPlaySystemSound(1057)
    }

    private func vibrate() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}