//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 09.03.2026.
//
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
