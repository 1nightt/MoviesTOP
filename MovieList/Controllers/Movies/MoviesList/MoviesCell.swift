import UIKit

class MoviesCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = Resources.Layout.cornerRadius
        image.backgroundColor = UIColor(white: 0.15, alpha: 1.0) // Тёмно-серый цвет вместо синего
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let ratingView: UIView = {
        let view = UIView()
        view.backgroundColor = Resources.DescriptionViewColors.ratingColor.withAlphaComponent(0.9)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Resources.Strings.Images.star
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Resources.Colors.textColor
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Gradient Overlay
    let gradientOverlay: CAGradientLayer = {
        let gradient = CAGradientLayer()
        // Заменяем градиент на полностью прозрачный, чтобы убрать затемнение
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0.5, 1.0]
        return gradient
    }()
    
    // MARK: - Properties
    var rating: Double? {
        didSet {
            setupRatingView()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientOverlay.frame = imageView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = Resources.Strings.Images.placeholder
        ratingView.isHidden = true
        label.text = ""
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        // Стиль карточки
        contentView.backgroundColor = Resources.Colors.cardBackgroundColor
        contentView.layer.cornerRadius = Resources.Layout.cornerRadius
        contentView.layer.masksToBounds = true
        
        // Тень
        layer.shadowColor = Resources.Layout.Shadow.color
        layer.shadowOpacity = Resources.Layout.Shadow.opacity
        layer.shadowOffset = Resources.Layout.Shadow.offset
        layer.shadowRadius = Resources.Layout.Shadow.radius
        layer.masksToBounds = false
        
        // Добавляем элементы
        contentView.addSubview(imageView)
        // Комментируем добавление градиентного слоя
        // imageView.layer.addSublayer(gradientOverlay)
        
        contentView.addSubview(label)
        
        ratingView.addSubview(starImageView)
        ratingView.addSubview(ratingLabel)
        contentView.addSubview(ratingView)
        
        // Изначально скрываем рейтинг
        ratingView.isHidden = true
        
        // Устанавливаем ограничения
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Изображение
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            
            // Название фильма
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            
            // Контейнер рейтинга
            ratingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            ratingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            ratingView.widthAnchor.constraint(equalToConstant: 50),
            ratingView.heightAnchor.constraint(equalToConstant: 24),
            
            // Звезда
            starImageView.leadingAnchor.constraint(equalTo: ratingView.leadingAnchor, constant: 4),
            starImageView.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor),
            starImageView.widthAnchor.constraint(equalToConstant: 14),
            starImageView.heightAnchor.constraint(equalToConstant: 14),
            
            // Текст рейтинга
            ratingLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 2),
            ratingLabel.trailingAnchor.constraint(equalTo: ratingView.trailingAnchor, constant: -4),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor)
        ])
    }
    
    private func setupRatingView() {
        guard let rating = rating else {
            ratingView.isHidden = true
            return
        }
        
        ratingLabel.text = String(format: "%.1f", rating)
        
        // Изменяем цвет в зависимости от рейтинга
        if rating >= 7.0 {
            ratingView.backgroundColor = UIColor(hexString: "#4CD964").withAlphaComponent(0.9) // Зеленый
        } else if rating >= 5.0 {
            ratingView.backgroundColor = UIColor(hexString: "#FFCC00").withAlphaComponent(0.9) // Желтый
        } else {
            ratingView.backgroundColor = UIColor(hexString: "#FF3B30").withAlphaComponent(0.9) // Красный
        }
        
        ratingView.isHidden = false
    }
    
    // Метод для анимированного появления контента
    func fadeIn() {
        alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
}
