//
//  SoundManager.swift
//  Saboteur
//
//  Created by Baba on 7/29/25.
//

import Foundation
import AVFoundation

import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?

    func playSound(_ sound: SoundEffect, loop: Bool = false, volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileExtension) else {
            print("❌ 사운드 파일 없음: \(sound.fileName).\(sound.fileExtension)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.numberOfLoops = loop ? -1 : 0
            player.prepareToPlay()

            switch sound.category {
            case .bgm:
                bgmPlayer?.stop()
                bgmPlayer = player
                bgmPlayer?.play()

            case .sfx:
                sfxPlayer = player // 효과음은 겹쳐도 되므로 중복 재생 가능
                sfxPlayer?.play()
            }
        } catch {
            print("❌ 사운드 재생 실패: \(error.localizedDescription)")
        }
    }

    func stopBGM() {
        bgmPlayer?.stop()
    }

    func stopSFX() {
        sfxPlayer?.stop()
    }

    func isBGMPlaying() -> Bool {
        return bgmPlayer?.isPlaying ?? false
    }

    func isSFXPlaying() -> Bool {
        return sfxPlayer?.isPlaying ?? false
    }
}

//MARK: - SoundCategory

enum SoundCategory {
    case bgm
    case sfx
}

enum SoundEffect {
    case gameStart
    case click
    case win
    case lose
    case backgroundMusic

    
    // MARK: -
    /*
     game_start.mp3, button_click.mp3, win_sound.mp3로 return 값과 파일 이름이 일치해야 함.
     즉, 다음처럼 실제 파일명과 정확히 일치해야 합니다.
     프로젝트 폴더에 직접 import하여 번들 리소스로 포함되게 해야 합니다.

     */
    
    var fileName: String {
        switch self {
        case .gameStart: return "game_start"
        case .click: return "button_click"
        case .win: return "win_sound"
        case .lose: return "lose_sound"
        case .backgroundMusic: return "bgm_main"
        }
    }

    var fileExtension: String {
        return "mp3"
    }

    var category: SoundCategory {
        switch self {
        case .backgroundMusic:
            return .bgm
        default:
            return .sfx
        }
    }
}

//MARK: - USE CASE

/*
 // 메인 배경음 반복 재생
 SoundManager.shared.playSound(.backgroundMusic, loop: true, volume: 0.3)

 // 버튼 클릭 효과음
 SoundManager.shared.playSound(.click)

 // 게임 승리 시 효과음
 SoundManager.shared.playSound(.win)
 
 */
