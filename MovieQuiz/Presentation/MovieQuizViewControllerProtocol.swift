//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 25.03.2026.
//


protocol MovieQuizViewControllerProtocol: AnyObject {
    func showNextView(quiz step: QuizStep)
    func showResults(quiz result: QuizResults)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func setButtonsEnabled(_ isEnabled: Bool)
}
