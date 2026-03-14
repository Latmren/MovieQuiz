//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 14.03.2026.
//

import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        self.correct > another.correct
    }
}
