//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 14.03.2026.
//

protocol StatisticServiceProtocol {
    var gameCount: Int { get }
    var bestGameScore: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store (_ freshResult: GameResult)
}
