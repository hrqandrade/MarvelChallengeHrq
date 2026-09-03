import MarvelDesignSystem
import UIKit

enum MarvelComponentSize {
    static let minimumTouchTarget: CGFloat = 44
    static let navigationBarHeight: CGFloat = 64
    static let tabBarHeight: CGFloat = 72
    static let segmentedControlHeight: CGFloat = 40
    static let emptyStateImageSize: CGFloat = 144
    static let heroImageHeight: CGFloat = 200
    static let detailsCarouselHeight: CGFloat = 120
}

final class MarvelScreenHeaderView: UIView {
    let leadingButton = UIButton(type: .system)
    let trailingButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = DesignSystem.Color.accent
        titleLabel.font = DesignSystem.Typography.title
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = DesignSystem.Color.onAccent
        titleLabel.textAlignment = .center
        titleLabel.text = title
        for item in [leadingButton, trailingButton] {
            item.tintColor = DesignSystem.Color.onAccent
            item.imageView?.contentMode = .scaleAspectFit
            item.imageView?.clipsToBounds = true
        }
        configureHierarchy()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        nil
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    private func configureHierarchy() {
        for item in [leadingButton, titleLabel, trailingButton] {
            item.translatesAutoresizingMaskIntoConstraints = false
            addSubview(item)
        }
        NSLayoutConstraint.activate([
            leadingButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.medium),
            leadingButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            leadingButton.widthAnchor.constraint(equalToConstant: MarvelComponentSize.minimumTouchTarget),
            leadingButton.heightAnchor.constraint(greaterThanOrEqualToConstant: MarvelComponentSize.minimumTouchTarget),
            titleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingButton.trailingAnchor,
                constant: DesignSystem.Spacing.small
            ),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingButton.leadingAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.trailingAnchor,
                constant: DesignSystem.Spacing.small
            ),
            trailingButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.medium),
            trailingButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingButton.widthAnchor.constraint(equalToConstant: MarvelComponentSize.minimumTouchTarget),
            trailingButton.heightAnchor
                .constraint(greaterThanOrEqualToConstant: MarvelComponentSize.minimumTouchTarget),
        ])
    }
}

final class MarvelCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DesignSystem.Color.surface
        layer.cornerRadius = DesignSystem.Radius.medium
        layer.apply(.card)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        nil
    }
}

final class MarvelEmptyStateView: UIView {
    init(image: UIImage?, title: String, description: String) {
        super.init(frame: .zero)
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = DesignSystem.Color.accent
        imageView.isAccessibilityElement = false

        let titleLabel = makeLabel(text: title, font: DesignSystem.Typography.headline)
        let descriptionLabel = makeLabel(text: description, font: DesignSystem.Typography.body)
        descriptionLabel.textColor = DesignSystem.Color.textSecondary
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, descriptionLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = DesignSystem.Spacing.small
        addSubview(stack)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: MarvelComponentSize.emptyStateImageSize),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: DesignSystem.Spacing.large),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -DesignSystem.Spacing.large),
        ])
        isAccessibilityElement = true
        accessibilityLabel = "\(title). \(description)"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        nil
    }

    private func makeLabel(text: String, font: UIFont) -> UILabel {
        let label = UILabel()
        label.font = font
        label.adjustsFontForContentSizeCategory = true
        label.textColor = DesignSystem.Color.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = text
        return label
    }
}

final class MarvelLoadingView: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        let titleLabel = makeLabel(text: Localizable.Loading.title, font: DesignSystem.Typography.headline)
        let stack = UIStackView(arrangedSubviews: [activityIndicator, titleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = DesignSystem.Spacing.small
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: DesignSystem.Spacing.medium),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -DesignSystem.Spacing.medium),
        ])
        activityIndicator.startAnimating()
        accessibilityLabel = Localizable.Loading.title
        accessibilityTraits = .updatesFrequently
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        nil
    }

    private func makeLabel(text: String, font: UIFont) -> UILabel {
        let label = UILabel()
        label.font = font
        label.adjustsFontForContentSizeCategory = true
        label.textColor = DesignSystem.Color.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = text
        return label
    }
}
