import Foundation
import AVFoundation
import UIKit
import AudioToolbox

enum Phase: String {
    case hot = "Горячая"
    case cold = "Холодная"
    case transition = "Переход"
    case done = "Готово"
}

class TimerModel: ObservableObject {
    @Published var currentPhase: Phase = .hot
    @Published var secondsLeft: Int = 0
    @Published var currentCycle: Int = 1
    @Published var totalCycles: Int = 3
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false

    // Настройки
    var hotSeconds: Int = 30
    var coldSeconds: Int = 30
    let transitionSeconds: Int = 3 // 3 секунды на смену

    private var timer: Timer?

    func start() {
        currentPhase = .hot
        secondsLeft = hotSeconds
        currentCycle = 1
        isRunning = true
        isFinished = false
        playTransitionSound()
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
                
                // Пикаем, если осталось 3, 2 или 1 секунда (и это не переход)
                if self.secondsLeft <= 3 && self.secondsLeft > 0 && self.currentPhase != .transition {
                    self.playBeep()
                }
                
                // Время фазы истекло
                if self.secondsLeft == 0 {
                    if self.currentPhase == .hot {
                        self.startTransition(toPhase: .cold)
                    } else if self.currentPhase == .cold {
                        if self.currentCycle >= self.totalCycles {
                            self.finish()
                        } else {
                            self.startTransition(toPhase: .hot)
                        }
                    } else if self.currentPhase == .transition {
                        // Переход закончился, включаем следующую фазу
                        if self.currentCycle >= self.totalCycles {
                            self.finish()
                        } else {
                            if self.currentPhase == .transition {
                                // Определяем, куда идем
                            }
                        }
                    }
                }
            }
        }
    }

    private func startTransition(toPhase: Phase) {
        vibrate()
        playTransitionSound()
        
        currentPhase = .transition
        secondsLeft = transitionSeconds
        
        // Запоминаем, куда перейдем после перехода
        let nextPhase = toPhase
        
        // Через 3 секунды переключим на нужную фазу
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(transitionSeconds)) {
            guard self.isRunning else { return }
            
            if nextPhase == .cold {
                self.currentPhase = .cold
                self.secondsLeft = self.coldSeconds
            } else if nextPhase == .hot {
                self.currentCycle += 1
                self.currentPhase = .hot
                self.secondsLeft = self.hotSeconds
            }
            
            // Запускаем следующий тик
            self.tick()
        }
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isFinished = true
        currentPhase = .done
        playFinishSound()
        vibrate()
    }

    private func playBeep() {
        // Короткий писк
        AudioServicesPlaySystemSound(1104) 
    }

    private func playTransitionSound() {
        // Приятный динь при смене
        AudioServicesPlaySystemSound(1057)
    }

    private func playFinishSound() {
        // Звук завершения
        AudioServicesPlaySystemSound(1025)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            AudioServicesPlaySystemSound(1025)
        }
    }

    private func vibrate() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}