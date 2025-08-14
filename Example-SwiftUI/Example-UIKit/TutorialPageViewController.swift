import UIKit

class TutorialPageViewController: UIViewController {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let iconImageView = UIImageView()
    private var model: TutorialPageModel?

    convenience init(model: TutorialPageModel) {
        self.init()
        self.model = model
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = .secondaryLabel

        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 120),
            iconImageView.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    static func getPageSlides() -> [TutorialPageViewController] {
        let page1 = TutorialPageViewController(model: TutorialPageModel(
            title: "Welcome to Ecom Demo App",
            desc: """
 This app is built for testing out the features of the Blue Triangle SDK for Android/iOS.
 
 It has built-in support for generating scenarios to test features such as:
 
     . Screen Tracking  
     . Crash Tracking  
     . ANR Detection
 
 and more...
 """,
            iconName: "Ecomdemo_image"
        ))
        
        let page2 = TutorialPageViewController(model: TutorialPageModel(
            title: "Screen Tracking",
            desc: "The Blue Triangle SDK automatically tracks all screens for UIKit, for SwiftUI the app screens have manually been tagged to be tracked by the SDK. Just browse through different screens, perform checkouts, etc that will generate some page views.",
            iconName: "ScreenTracking_image"
        ))
        
        let page3 = TutorialPageViewController(model: TutorialPageModel(
            title: "Crash Tracking",
            desc: """
 There are two scenarios for generating a crash in this app.
 
 Scenario 1: Empty Cart Checkout  
     . A checkout without any products in the cart would simulate a crash.
 
 Scenario 2: Cart Overflow  
     . Adding 5 or more distinct products to the cart and performing a checkout operation would result in a crash.
 
 Note: The crash will be captured and stored locally until the next launch of the app, when it will be submitted to the backend servers.
 """,
            iconName: "Crash_image"
        ))
        
        let page4 = TutorialPageViewController(model: TutorialPageModel(
            title: "ANR Detection",
            desc: """
 Application Not Responding (ANR) is a state when the app is unresponsive for a significant amount of time. The Blue Triangle SDK tracks such states and reports it. This app has some manufactured ANR scenarios built in.
 
 Scenario 1: Remove a Product from Cart  
     . Add a product to the cart and then try removing it using the trash icon. That will result in the app getting hanged for several seconds resulting in an ANR state which will be reported.
 
 Scenario 2: Continue Shopping  
     . Add some products to the cart and perform a checkout. A checkout confirmation screen appears with a "Continue Shopping" button. Clicking on it will result in the app getting into an ANR state.
 """,
            iconName: "ANR_image"
        ))
        
        return [page1, page2, page3, page4]
    }

    private func updateUI() {
        // Bold heading
        let titleFont = UIFont.systemFont(ofSize: 26, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.label
        ]
        titleLabel.attributedText = NSAttributedString(string: model?.title ?? "", attributes: titleAttributes)

        // Description with specific bold keywords
        let descString = model?.desc ?? ""
        let attributedDesc = NSMutableAttributedString(string: descString, attributes: [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.secondaryLabel
        ])

        let keywords = ["Note:", "Scenario 1:", "Scenario 2:", ". "]
        for keyword in keywords {
            let range = (descString as NSString).range(of: keyword)
            if range.location != NSNotFound {
                attributedDesc.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.label
                ], range: range)
            }
        }

        descriptionLabel.attributedText = attributedDesc

        // Icon
        iconImageView.image = UIImage(named: model?.iconName ?? "")
        iconImageView.tintColor = .systemBlue
    }
}

struct TutorialPageModel {
    let title: String
    let desc: String
    let iconName: String
}
