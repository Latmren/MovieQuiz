//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 16.02.2026.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol{
    
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
            self.moviesLoader = moviesLoader
            self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            } 
            
            let rating = Float(movie.rating) ?? 0
            
            //print(rating) //для проверки работы сравнений
            
            let targetRating = (7...9).randomElement() ?? 7
            let randomCompare = ["больше","меньше"].randomElement() ?? "больше"
            
            let text = "Рейтинг этого фильма \(randomCompare) чем \(targetRating)"
            
            let correctAnswer: Bool
            
            switch randomCompare {
            case "меньше":
                correctAnswer = rating < Float(targetRating)
            
            default:
                correctAnswer = rating > Float(targetRating)
            }

            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    } 
    
    func setDelegate(_ delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
}
