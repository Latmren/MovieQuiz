//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 22.03.2026.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(
        handler: @escaping (Result<MostPopularMovies, Error>) -> Void
    )
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    private var useMocks: Bool = true // использовать моковые данные

    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard
            let url = URL(
                string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf"
            )
        else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    func loadMovies(
        handler: @escaping (Result<MostPopularMovies, Error>) -> Void
    ) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(
                        MostPopularMovies.self,
                        from: data
                    )
                    //проверка на errorMessage в ответе от IMDB API
                    if mostPopularMovies.errorMessage != "" && useMocks {
                        let top250Mock = Top250Mock()
                        let mostPopularMovies2 = try JSONDecoder().decode(
                            MostPopularMovies.self,
                            from: top250Mock.getMockData()
                        )
                        handler(.success(mostPopularMovies2))
                    } else if mostPopularMovies.errorMessage != "" && !useMocks
                    {
                        handler(
                            .failure(
                                NSError(
                                    domain: "MostPopularMoviesError",
                                    code: 0,
                                    userInfo: [
                                        NSLocalizedDescriptionKey:
                                            mostPopularMovies.errorMessage
                                    ]
                                )
                            )
                        )

                    } else {
                        handler(.success(mostPopularMovies))
                    }
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }

    }
}
