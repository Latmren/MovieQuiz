//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 09.03.2026.
//

import UIKit

class ResultAlertPresenter {
    
    func showResults(targetView: UIViewController, quiz model: AlertModel) {

        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "ResultAlert"

        let action = UIAlertAction(title: model.buttonText, style: .default) {_ in
            model.completion()
        }

        alert.addAction(action)
        
        targetView.present(alert, animated: true, completion: nil)
    }
    
}

