import Foundation
import AVFoundation
import UIKit

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

    var hotSeconds: Int = 30
    var coldSeconds: Int = 30
    let transitionSeconds: Int = 3

    private var timer: Timer?
    private var musicPlayer: AVAudioPlayer?
    private var beepPlayer: AVAudioPlayer?
    private var transitionPlayer: AVAudioPlayer?

    init() {
        setupAudio()
    }

    private func setupAudio() {
        // Фоновая музыка
        if let url = Bundle.main.url(forResource: "background", withExtension: "mp3") {
            do {
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer?.numberOfLoops = -1 // Бесконечный цикл
                musicPlayer?.volume = 0.3 // Негромко
                musicPlayer?.prepareToPlay()
            } catch {
                print("Ошибка музыки: \(error)")
            }
        }

        // Звук пиканья
        if let url = Bundle.main.url(forResource: "beep", withExtension: "mp3") {
            do {
                beepPlayer = try AVAudioPlayer(contentsOf: url)
                beepPlayer?.volume = 1.0 // Громко
                beepPlayer?.prepareToPlay()
            } catch {
                print("Ошибка пиканья: \(error)")
            }
        }
    }

    func start() {
        currentPhase = .hot
        secondsLeft = hotSeconds
        currentCycle = 1
        isRunning = true
        isFinished = false
        musicPlayer?.currentTime = 0
        musicPlayer?.play()
        tick()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        musicPlayer?.stop()
    }

    private func tick() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.secondsLeft > 0 {
                self.secondsLeft -= 1
                
                // Пикаем на 3, 2, 1
                if self.secondsLeft <= 3 && self.secondsLeft > 0 && self.currentPhase != .transition {
                    self.playBeep()
                }
                
                if self.secondsLeft == 0 {
                    if self.currentPhase == .hot {
                        self.startTransition(toPhase: .cold)
                    } else if self.currentPhase == .cold {
                        if self.currentCycle >= self.totalCycles {
                            self.finish()
                        } else {
                            self.startTransition(toPhase: .hot)
                        }
                    }
                }
            }
        }
    }

    private func startTransition(toPhase: Phase) {
        vibrate()
        currentPhase = .transition
        secondsLeft = transitionSeconds
        
        // Через 3 секунды переключим на нужную фазу
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(transitionSeconds)) {
            guard self.isRunning else { return }
            
            if toPhase == .cold {
                self.currentPhase = .cold
                self.secondsLeft = self.coldSeconds
            } else if toPhase == .hot {
                self.currentCycle += 1
                self.currentPhase = .hot
                self.secondsLeft = self.hotSeconds
            }
            
            self.tick()
        }
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isFinished = true
        currentPhase = .done
        musicPlayer?.stop()
        vibrate()
    }

    private func playBeep() {
        beepPlayer?.currentTime = 0
        beepPlayer?.play()
    }

    private func vibrate() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}