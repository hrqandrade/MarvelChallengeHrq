import MarvelDesignSystem
import UIKit

final class DetailsCollectionViewCell: UICollectionViewCell {
    // MARK: - UI

    static let reuseIdentifier = String(describing: DetailsCollectionViewCell.self)
    private let descriptionLabel = UILabel()
    private let borderedView = UIView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBorderedView()
        configureDescriptionLabel()
        configureHierarchy()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.text = nil
    }

    func setupCell(description: String) {
        descriptionLabel.text = description
    }

    // MARK: - Configuration

    private func configureBorderedView() {
        borderedView.translatesAutoresizingMaskIntoConstraints = false
        borderedView.backgroundColor = DesignSystem.Color.surface
        borderedView.layer.borderWidth = 1
        borderedView.layer.borderColor = DesignSystem.Color.border.cgColor
        borderedView.layer.cornerRadius = DesignSystem.Radius.medium
    }

    private func configureDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = DesignSystem.Typography.caption
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.textColor = DesignSystem.Color.textPrimary
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
    }

    private func configureHierarchy() {
        contentView.addSubview(borderedView)
        borderedView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            borderedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            borderedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            descriptionLabel.topAnchor.constraint(
                equalTo: borderedView.topAnchor,
                constant: DesignSystem.Spacing.small
            ),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: borderedView.leadingAnchor,
                constant: DesignSystem.Spacing.small
            ),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: borderedView.trailingAnchor,
                constant: -DesignSystem.Spacing.small
            ),
            descriptionLabel.bottomAnchor.constraint(
                equalTo: borderedView.bottomAnchor,
                constant: -DesignSystem.Spacing.small
            ),
        ])
    }
}
