//
//  AVPlayer+Ding.swift
//  Scrums
//
//  Created by Javier Galera Robles on 10/12/21.
//

import Foundation
import AVFoundation

extension AVPlayer {
    static let sharedDingPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "Audio/ding", withExtension: "wav") else { fatalError("Failed to find sound file.") }
        return AVPlayer(url: url)
    }()
}
