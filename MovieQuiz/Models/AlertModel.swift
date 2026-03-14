//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Dmitry Zherebyatnikov on 09.03.2026.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
