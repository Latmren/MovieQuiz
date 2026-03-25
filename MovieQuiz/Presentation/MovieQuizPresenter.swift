//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 25.03.2026.
//

import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var currentQuestion: QuizQuestion?

    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    private var correctAnswersCount: Int = 0
    
    
    init(viewController: MovieQuizViewControllerProtocol){
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showNextView(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswersCount += 1
        }
    }
    
    func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStep {
        QuizStep(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
        
    func handleAnswer(isYes: Bool) {
        
        viewController?.setButtonsEnabled(false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == isYes)
    }
    
    func proceedWithAnswer(isCorrect: Bool) {

        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let currentGameResult = GameResult(
                correct: correctAnswersCount,
                total: self.questionsAmount,
                date: Date()
            )
            statisticService.store(currentGameResult)
            
            let quizResults = QuizResults(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть ещё раз"
            )
            viewController?.showResults(quiz: quizResults)
            
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
        
        sleep(1)
        self.viewController?.setButtonsEnabled(true)
    }
    
    func makeResultsMessage() -> String {
        let bestGameScore = statisticService.bestGameScore
        
        let currentGameResultLine = "Ваш результат: \(correctAnswersCount)/\(self.questionsAmount)"
        let totalGamesCountLine = "Количество сыгранных раундов: \(statisticService.gameCount)"
        let bestGameScoreLine = "Рекорд: \(bestGameScore.correct)/\(bestGameScore.total) (\(bestGameScore.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultsText = [
            currentGameResultLine,
            totalGamesCountLine,
            bestGameScoreLine,
            averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultsText
    }

    




}
