//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 09.03.2026.
//
protocol QuestionFactoryDelegate: AnyObject {
    func didRecieveNextQuestion(question: QuizQuestion?)
}
