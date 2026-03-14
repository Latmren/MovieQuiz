//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 09.03.2026.
//

import UIKit

class ResultAlertPresenter: AlertPresenterProtocol {

//    weak var delegate: AlertPresenterDelegate?
    
    func showResults(targetView: UIViewController, quiz model: AlertModel) {
        // создаём объекты всплывающего окна
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )

        // создаём для алерта кнопку с действием
        // в замыкании пишем, что должно происходить при нажатии на кнопку
        // константа с кнопкой для системного алерта
        let action = UIAlertAction(title: model.buttonText, style: .default) {_ in
            model.completion()
        }

        // добавляем в алерт кнопку
        alert.addAction(action)
        
        //alert.message.textAlignment = .center

        // показываем всплывающее окно
        targetView.present(alert, animated: true, completion: nil)
    }
    
//    func setDelegate(_ delegate: AlertPresenterDelegate?) {
//        self.delegate = delegate
//    }
}

