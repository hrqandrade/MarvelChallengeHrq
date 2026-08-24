import UIKit
import MarvelDesignSystem

final class DetailsCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: DetailsCollectionViewCell.self)
    private let descriptionLabel = UILabel()
    private let borderedView = UIView()

    override init(frame: CGRect) { super.init(frame: frame); configureView() }
    @available(*, unavailable) required init?(coder: NSCoder) { nil }
    override func prepareForReuse() { super.prepareForReuse(); descriptionLabel.text = nil }

    func setupCell(description: String) { descriptionLabel.text = description }

    private func configureView() {
        borderedView.translatesAutoresizingMaskIntoConstraints = false
        borderedView.backgroundColor = DesignSystem.Color.surface
        borderedView.layer.borderWidth = 1; borderedView.layer.borderColor = DesignSystem.Color.border.cgColor
        borderedView.layer.cornerRadius = DesignSystem.Radius.medium
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = DesignSystem.Typography.caption; descriptionLabel.textColor = DesignSystem.Color.textPrimary
        descriptionLabel.textAlignment = .center; descriptionLabel.numberOfLines = 0
        contentView.addSubview(borderedView); borderedView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            borderedView.topAnchor.constraint(equalTo: contentView.topAnchor), borderedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor), borderedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: borderedView.topAnchor, constant: DesignSystem.Spacing.small),
            descriptionLabel.leadingAnchor.constraint(equalTo: borderedView.leadingAnchor, constant: DesignSystem.Spacing.small),
            descriptionLabel.trailingAnchor.constraint(equalTo: borderedView.trailingAnchor, constant: -DesignSystem.Spacing.small),
            descriptionLabel.bottomAnchor.constraint(equalTo: borderedView.bottomAnchor, constant: -DesignSystem.Spacing.small)
        ])
    }
}
