//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 14.03.2026.
//

// Расширяем при объявлении

import UIKit

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount          // Для счётчика сыгранных игр
        case bestGameCorrect     // Для количества правильных ответов в лучшей игре
        case bestGameTotal       // Для общего количества вопросов в лучшей игре
        case bestGameDate        // Для даты лучшей игры
        case totalCorrectAnswers // Для общего количества правильных ответов за все игры
        case totalQuestionsAsked // Для общего количества вопросов, заданных за все игры
    }
    
    var gameCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGameScore: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
            // Добавьте чтение значений полей GameResult(correct, total и date) из UserDefaults,
            // затем создайте GameResult от полученных значений
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let totalCorrectAnswers=storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let totalQuestionsAsked=storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        return Double(totalCorrectAnswers)/Double(totalQuestionsAsked)*100
        // отношение общего числа правильных ответов
        // ко всем заданным вопросам за все игры
    }
    
    func store(_ freshResult: GameResult) {
        let totalCorrectAnswers=storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)+freshResult.correct
        let totalQuestionsAsked=storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)+freshResult.total
        
        storage.set(totalCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(totalQuestionsAsked, forKey: Keys.totalQuestionsAsked.rawValue)
        
        gameCount += 1
        
        freshResult.isBetterThan(bestGameScore) ? (bestGameScore = freshResult) : (())
    }
    
     
}
