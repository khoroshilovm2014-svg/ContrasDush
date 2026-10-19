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

    init() {
        setupAudio()
        loadSettings()  // ← читаем настройки при создании
    }

    // ← ГЛАВНОЕ: перечитываем настройки при каждом старте
    private func loadSettings() {
        let hot = UserDefaults.standard.integer(forKey: "hot")
        let cold = UserDefaults.standard.integer(forKey: "cold")
        let cycles = UserDefaults.standard.integer(forKey: "cycles")

        hotSeconds = hot > 0 ? hot : 30
        coldSeconds = cold > 0 ? cold : 30
        totalCycles = cycles > 0 ? cycles : 3
    }

    private func setupAudio() {
        if let url = Bundle.main.url(forResource: "beep", withExtension: "mp3") {
            do {
                beepPlayer = try AVAudioPlayer(contentsOf: url)
                beepPlayer?.volume = 1.0
                beepPlayer?.prepareToPlay()
            } catch {
                print("Ошибка пиканья: \(error)")
            }
        }
    }

    private func loadMusic() {
        musicPlayer?.stop()
        musicPlayer = nil

        let choice = UserDefaults.standard.string(forKey: "musicChoice") ?? "videoclub"

        if choice == "none" {
            return
        }

        if choice == "custom" {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent("custom_music.mp3")
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    musicPlayer = try AVAudioPlayer(contentsOf: url)
                    musicPlayer?.numberOfLoops = -1
                    musicPlayer?.volume = 0.3
                    musicPlayer?.prepareToPlay()
                } catch {
                    print("Ошибка custom музыки: \(error)")
                }
            }
        } else {
            if let url = Bundle.main.url(forResource: "background", withExtension: "mp3") {
                do {
                    musicPlayer = try AVAudioPlayer(contentsOf: url)
                    musicPlayer?.numberOfLoops = -1
                    musicPlayer?.volume = 0.3
                    musicPlayer?.prepareToPlay()
                } catch {
                    print("Ошибка музыки: \(error)")
                }
            }
        }
    }

    // ← ГЛАВНОЕ: перечитываем настройки и музыку ПРИ КАЖДОМ старте
    func start() {
        loadSettings()  // ← обновляем горячую/холодную/повторы
        loadMusic()     // ← обновляем музыку

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