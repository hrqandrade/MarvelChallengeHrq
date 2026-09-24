import MarvelDesignSystem
import UIKit

enum MarvelComponentSize {
    static let minimumTouchTarget: CGFloat = 44
    static let navigationBarHeight: CGFloat = 64
    static let tabBarHeight: CGFloat = 72
    static var segmentedControlHeight: CGFloat {
        max(40, ceil(MarvelTypography.segmentedControlTitle.lineHeight + 16))
    }

    static let emptyStateImageSize: CGFloat = 144
    static let heroImageHeight: CGFloat = 200
    static var detailsCarouselHeight: CGFloat {
        max(120, ceil(DesignSystem.Typography.caption.lineHeight * 3 + DesignSystem.Spacing.large * 2))
    }
}

enum MarvelTypography {
    static var screenTitle: UIFont {
        let baseFont = UIFont.systemFont(ofSize: 28, weight: .bold)
        return UIFontMetrics(forTextStyle: .title1).scaledFont(for: baseFont, maximumPointSize: 36)
    }

    static var segmentedControlTitle: UIFont {
        let baseFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont, maximumPointSize: 24)
    }
}

final class MarvelScreenHeaderView: UIView {
    let leadingButton = UIButton(type: .system)
    let trailingButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = DesignSystem.Color.accent
        titleLabel.font = MarvelTypography.screenTitle
        titleLabel.adjustsFontForContentSizeCategory = false
        titleLabel.textColor = DesignSystem.Color.onAccent
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
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

    override var intrinsicContentSize: CGSize {
        let contentHeight = ceil(titleLabel.font.lineHeight * 2 + DesignSystem.Spacing.medium * 2)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(MarvelComponentSize.navigationBarHeight, contentHeight)
        )
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory
        else { return }
        titleLabel.font = MarvelTypography.screenTitle
        invalidateIntrinsicContentSize()
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
        isAccessibilityElement = true
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

final class MarvelErrorStateView: UIView {
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    var onRetry: (() -> Void)?

    init(message: String) {
        super.init(frame: .zero)

        let iconView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = DesignSystem.Color.accent
        iconView.isAccessibilityElement = false

        messageLabel.font = DesignSystem.Typography.body
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = DesignSystem.Color.textSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.accessibilityLabel = message

        retryButton.setTitle(Localizable.Catalog.retry, for: .normal)
        retryButton.titleLabel?.font = DesignSystem.Typography.headline
        retryButton.tintColor = DesignSystem.Color.accent
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [iconView, messageLabel, retryButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = DesignSystem.Spacing.medium
        addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: MarvelComponentSize.minimumTouchTarget),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            retryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: MarvelComponentSize.minimumTouchTarget),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: DesignSystem.Spacing.large),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -DesignSystem.Spacing.large),
        ])

        isAccessibilityElement = false
        accessibilityElements = [messageLabel, retryButton]
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        nil
    }

    @objc private func didTapRetry() {
        onRetry?()
    }
}

final class MarvelFeedbackBanner: UIView {
    private enum Metrics {
        static let displayDuration: TimeInterval = 3
        static let animationDuration: TimeInterval = 0.2
    }

    private let iconView = UIImageView()
    private let messageLabel = UILabel()
    private var dismissal: DispatchWorkItem?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DesignSystem.Color.surface
        layer.cornerRadius = DesignSystem.Radius.medium
        layer.apply(.card)
        isHidden = true

        iconView.contentMode = .scaleAspectFit
        messageLabel.font = DesignSystem.Typography.body
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = DesignSystem.Color.textPrimary
        messageLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [iconView, messageLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.spacing = DesignSystem.Spacing.small
        addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: MarvelComponentSize.minimumTouchTarget / 2),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: DesignSystem.Spacing.small),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.medium),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.medium),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DesignSystem.Spacing.small),
        ])
        isAccessibilityElement = true
        accessibilityTraits = .staticText
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        nil
    }

    func show(message: String, isError: Bool) {
        dismissal?.cancel()
        messageLabel.text = message
        iconView.image = UIImage(systemName: isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
        iconView.tintColor = isError ? DesignSystem.Color.accent : DesignSystem.Color.textPrimary
        accessibilityLabel = message
        isHidden = false
        alpha = 0
        if UIAccessibility.isReduceMotionEnabled {
            alpha = 1
        } else {
            UIView.animate(withDuration: Metrics.animationDuration) {
                self.alpha = 1
            }
        }
        UIAccessibility.post(notification: .announcement, argument: message)

        let dismissal = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard !UIAccessibility.isReduceMotionEnabled else {
                self.isHidden = true
                return
            }
            UIView.animate(
                withDuration: Metrics.animationDuration,
                animations: {
                    self.alpha = 0
                },
                completion: { _ in
                    self.isHidden = true
                }
            )
        }
        self.dismissal = dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + Metrics.displayDuration, execute: dismissal)
    }
}
