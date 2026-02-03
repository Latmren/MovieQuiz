import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!

    // MARK: - State

    private let questions = QuizQuestion.mockQuestions
    private var currentQuestionIndex = 0
    private var correctAnswersCount = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFonts()
        showQuestion()
    }

    // MARK: - Setup

    private func setupUI() {
        yesButton.isExclusiveTouch = true
        noButton.isExclusiveTouch = true

        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
    }

    private func setupFonts() {
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
    }

    private func showQuestion() {
        let question = questions[currentQuestionIndex]
        showNextView(quiz: convert(model: question))
    }

    // MARK: - Quiz Logic

    private func convert(model: QuizQuestion) -> QuizStep {
        let questionStep = QuizStep(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
        return questionStep
    }

    private func showNextView(quiz step: QuizStep) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func nextStepOrResult() {
        if currentQuestionIndex != questions.count - 1 {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = 0.0
            showQuestion()
        } else {
            let QuizResults = QuizResults(
                title: "Раунд окончен",
                text:
                    "Ваш результат: \(correctAnswersCount)/\(questions.count)",
                buttonText: "Сыграть ещё раз"
            )
            showResults(quiz: QuizResults)
        }
    }

    // MARK: - Answer Handling

    private func showAnswerResult(isCorrect: Bool) {

        imageView.layer.borderWidth = 8.0  // толщина рамки

        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswersCount += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }

        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // код, который мы хотим вызвать через 1 секунду
            self.nextStepOrResult()
            self.setButtonsEnabled(true)
        }
    }

    // MARK: - Results

    private func showResults(quiz result: QuizResults) {
        // создаём объекты всплывающего окна
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )

        // создаём для алерта кнопку с действием
        // в замыкании пишем, что должно происходить при нажатии на кнопку
        // константа с кнопкой для системного алерта
        let action = UIAlertAction(title: result.buttonText, style: .default) {
            _ in
            self.currentQuestionIndex = 0
            self.correctAnswersCount = 0
            self.imageView.layer.borderWidth = 0.0
            self.showQuestion()
        }

        // добавляем в алерт кнопку
        alert.addAction(action)

        // показываем всплывающее окно
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction private func yesButtonTapped(_ sender: Any) {
        handleAnswer(isYes: true)
    }

    @IBAction private func noButtonTapped(_ sender: Any) {
        handleAnswer(isYes: false)
    }

    private func handleAnswer(isYes: Bool) {
        let question = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: question.correctAnswer == isYes)
        setButtonsEnabled(false)
    }

    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }

}
