import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    // MARK: - Outlets

    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!

    // MARK: - State
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alert: AlertModel?
    private var resultAlertPresenter: ResultAlertPresenter = ResultAlertPresenter()
    
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // private let questions = QuizQuestion.mockQuestions
    private var currentQuestionIndex: Int = 0
    private var correctAnswersCount: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFonts()
        
//        let alertPresenter = AlertPresenter()
//        alertPresenter.setDelegate(self)
//        self.alertPresenter = alertPresenter
        
//        print(NSHomeDirectory())
//        UserDefaults.standard.set(true, forKey: "viewDidLoad")
        
        //statisticService = StatisticService()
        
//        let allValues = UserDefaults.standard.dictionaryRepresentation()
//
//        // Получаем все ключи словаря, затем в цикле удаляем их
//        allValues.keys.forEach { key in
//            UserDefaults.standard.removeObject(forKey: key)
//        } 
        
        let questionFactory = QuestionFactory()
        questionFactory.setDelegate(self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
    }

    // MARK: - QuestionFactoryDelegate
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        
        guard let question = question else {
            return
        }
        
        currentQuestion=question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showNextView(quiz: viewModel)
        }
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

    // MARK: - Quiz Logic

    private func convert(model: QuizQuestion) -> QuizStep {
        let questionStep = QuizStep(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }

    private func showNextView(quiz step: QuizStep) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func nextStepOrResult() {
        if currentQuestionIndex != questionsAmount - 1 {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = 0.0
            questionFactory?.requestNextQuestion()
        } else {
            let currentGameResult = GameResult(correct: correctAnswersCount, total: questionsAmount, date: Date())
            statisticService.store(currentGameResult)
            let quizResults = QuizResults(
                title: "Раунд окончен",
                text:
                    "Ваш результат: \(correctAnswersCount)/\(questionsAmount)\nКоличество сыгранных раундов: \(statisticService.gameCount)\nРекорд: \(statisticService.bestGameScore.correct)/\(statisticService.bestGameScore.total) (\( statisticService.bestGameScore.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
                buttonText: "Сыграть ещё раз"
            )
            showResults(quiz: quizResults)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self else { return }
            // код, который мы хотим вызвать через 1 секунду
            self.nextStepOrResult()
            self.setButtonsEnabled(true)
        }
    }

    // MARK: - Results

    private func showResults(quiz result: QuizResults) {
        // создаём объекты всплывающего окна

        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText)
            { [weak self] in
                guard let self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswersCount = 0
                self.imageView.layer.borderWidth = 0.0
                self.questionFactory?.requestNextQuestion()
            }
        
        resultAlertPresenter.showResults(targetView: self, quiz: alertModel)
        
    }

    // MARK: - Actions

    @IBAction private func yesButtonTapped(_ sender: Any) {
        handleAnswer(isYes: true)
    }

    @IBAction private func noButtonTapped(_ sender: Any) {
        handleAnswer(isYes: false)
    }

    private func handleAnswer(isYes: Bool) {
        //let currentQuestion = questions[currentQuestionIndex]
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == isYes)
        setButtonsEnabled(false)
    }

    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }

}
