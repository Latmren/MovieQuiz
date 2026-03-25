import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol
{
    // MARK: - Outlets

    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - State
    
    private var presenter: MovieQuizPresenter!

    private var alert: AlertModel?
    private var resultAlertPresenter: ResultAlertPresenter =
        ResultAlertPresenter()

    private let titleTextError = "Что-то пошло не так("
    private let buttonTextError = "Попробовать ещё раз"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupFonts()
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Setup

    private func setupUI() {
        yesButton.isExclusiveTouch = true
        noButton.isExclusiveTouch = true

        imageView.layer.cornerRadius = 20
    }

    private func setupFonts() {
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonTapped(_ sender: Any) {
        presenter.handleAnswer(isYes: true)
    }

    @IBAction private func noButtonTapped(_ sender: Any) {
        presenter.handleAnswer(isYes: false)
    }
    
    // MARK: - Private functions
    
    func showNextView(quiz step: QuizStep) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showResults(quiz result: QuizResults) {

       let alertModel = AlertModel(
           title: result.title,
           message: result.text,
           buttonText: result.buttonText
       ) { [weak self] in
           guard let self else { return }
           
           self.presenter.restartQuiz()
       }
        
       resultAlertPresenter.showResults(targetView: self, quiz: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        loadingIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: titleTextError,
                               message: message,
                               buttonText: buttonTextError){ [weak self] in
            guard let self else { return }
            
            presenter.restartQuiz()
            self.imageView.layer.borderWidth = 0.0
            showLoadingIndicator()
            
        }
        resultAlertPresenter.showResults(targetView: self, quiz: model)
        
    }
    
    func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
}
