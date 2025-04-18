import UIKit
import CoreData

class MoviesDescriptionViewController: UIViewController {
    
    // MARK: - Public Properties
    var movieDescription: MoviesDescription?
    var onFilmIdReceived: ((String) -> Void)?
    
    // MARK: - Private Properties
    private let networkManager = NetworkManager.shared
    private let coreDataManager = CoreDataManager.shared
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var isFavorite = false
    
    // UI Elements
    private let posterContainerView = UIView()
    private let posterImageView = UIImageView()
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let titleNameLabel = UILabel()
    private let releaseYearLabel = UILabel()
    private let ratingView = UIView()
    private let ratingLabel = UILabel()
    private let genreLabel = UILabel()
    private let infoStackView = UIStackView()
    private let descriptionTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Resources.Colors.backgroundColor
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        checkFavoriteStatus()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navBarGradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 100)
        
        // Обновляем contentInset, чтобы кнопки не перекрывались табБаром
        updateBottomInset()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Components
    private let navBarGradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0, 1]
        return gradient
    }()
    
    // MARK: - UI Configuration
    private func configure() {
        setupScrollView()
        setupContentView()
        setupPosterView()
        setupNavBarGradient()
        setupNavigationButtons()
        setupTitle()
        setupInfoStackView()
        setupDescriptionSection()
        setupActionButtons()
        loadData()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Добавляем отступ снизу, чтобы контент не перекрывался таб-баром
        updateBottomInset()
    }
    
    // Новый метод для обновления нижнего отступа с учетом высоты таб-бара
    private func updateBottomInset() {
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        let bottomInset: CGFloat = tabBarHeight + 16 // Добавляем дополнительный отступ для удобства
        scrollView.contentInset.bottom = bottomInset
        scrollView.scrollIndicatorInsets.bottom = bottomInset
    }
    
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupPosterView() {
        // Контейнер для постера
        posterContainerView.translatesAutoresizingMaskIntoConstraints = false
        posterContainerView.clipsToBounds = true
        contentView.addSubview(posterContainerView)
        
        NSLayoutConstraint.activate([
            posterContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterContainerView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.3)
        ])
        
        // Размытый фон для постера - уменьшаем прозрачность до минимума, чтобы устранить затемнение
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.alpha = 0.4 // Уменьшаем с 0.9 до 0.4
        posterContainerView.addSubview(blurEffectView)
        
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: posterContainerView.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: posterContainerView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: posterContainerView.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: posterContainerView.bottomAnchor)
        ])
        
        // Постер
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 16
        posterContainerView.addSubview(posterImageView)
        
        NSLayoutConstraint.activate([
            posterImageView.centerXAnchor.constraint(equalTo: posterContainerView.centerXAnchor),
            posterImageView.centerYAnchor.constraint(equalTo: posterContainerView.centerYAnchor),
            posterImageView.widthAnchor.constraint(equalTo: posterContainerView.widthAnchor, multiplier: 0.65),
            posterImageView.heightAnchor.constraint(equalTo: posterContainerView.heightAnchor, multiplier: 0.85)
        ])
        
        // Тень для постера
        posterImageView.layer.shadowColor = UIColor.black.cgColor
        posterImageView.layer.shadowOpacity = 0.7
        posterImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        posterImageView.layer.shadowRadius = 10
        posterImageView.layer.masksToBounds = false
    }
    
    private func setupNavBarGradient() {
        let navBarGradientView = UIView()
        navBarGradientView.translatesAutoresizingMaskIntoConstraints = false
        navBarGradientView.layer.addSublayer(navBarGradientLayer)
        view.addSubview(navBarGradientView)
        
        NSLayoutConstraint.activate([
            navBarGradientView.topAnchor.constraint(equalTo: view.topAnchor),
            navBarGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBarGradientView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupNavigationButtons() {
        // Кнопка назад
        let boldConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let chevronImage = UIImage(systemName: "chevron.left", withConfiguration: boldConfig)
        backButton.setImage(chevronImage, for: .normal)
        backButton.tintColor = Resources.Colors.textColor
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        backButton.layer.cornerRadius = 20
        backButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupTitle() {
        titleNameLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleNameLabel.textColor = Resources.DescriptionViewColors.titleNameColor
        titleNameLabel.numberOfLines = 0
        titleNameLabel.textAlignment = .center
        titleNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleNameLabel)
        
        NSLayoutConstraint.activate([
            titleNameLabel.topAnchor.constraint(equalTo: posterContainerView.bottomAnchor, constant: 20),
            titleNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupInfoStackView() {
        // Год выпуска с иконкой
        let yearStack = createInfoStackView(
            iconName: "calendar",
            label: releaseYearLabel,
            text: "",
            color: UIColor.white.withAlphaComponent(0.8)
        )
        
        // Рейтинг с иконкой
        let ratingIconView = UIImageView(image: UIImage(systemName: "star.fill"))
        ratingIconView.tintColor = Resources.DescriptionViewColors.ratingColor
        ratingIconView.contentMode = .scaleAspectFit
        ratingIconView.translatesAutoresizingMaskIntoConstraints = false
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        ratingLabel.textColor = Resources.DescriptionViewColors.ratingColor
        
        let ratingStack = UIStackView(arrangedSubviews: [ratingIconView, ratingLabel])
        ratingStack.axis = .horizontal
        ratingStack.spacing = 4
        ratingStack.alignment = .center
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Жанры с иконкой
        let genreIcon = UIImageView(image: UIImage(systemName: "film"))
        genreIcon.tintColor = UIColor.white.withAlphaComponent(0.8)
        genreIcon.contentMode = .scaleAspectFit
        genreIcon.translatesAutoresizingMaskIntoConstraints = false
        
        genreLabel.numberOfLines = 0
        genreLabel.font = UIFont.systemFont(ofSize: 16)
        genreLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let genreStack = UIStackView(arrangedSubviews: [genreIcon, genreLabel])
        genreStack.axis = .horizontal
        genreStack.spacing = 4
        genreStack.alignment = .top // Выравнивание по верху для текста с переносом
        genreStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Создаем вертикальные стеки для каждой группы информации
        let yearContainer = UIView()
        yearContainer.translatesAutoresizingMaskIntoConstraints = false
        yearContainer.addSubview(yearStack)
        
        let ratingContainer = UIView()
        ratingContainer.translatesAutoresizingMaskIntoConstraints = false
        ratingContainer.addSubview(ratingStack)
        
        let genreContainer = UIView()
        genreContainer.translatesAutoresizingMaskIntoConstraints = false
        genreContainer.addSubview(genreStack)
        
        // Настраиваем ограничения для стеков внутри контейнеров
        NSLayoutConstraint.activate([
            yearStack.centerXAnchor.constraint(equalTo: yearContainer.centerXAnchor),
            yearStack.centerYAnchor.constraint(equalTo: yearContainer.centerYAnchor),
            
            ratingStack.centerXAnchor.constraint(equalTo: ratingContainer.centerXAnchor),
            ratingStack.centerYAnchor.constraint(equalTo: ratingContainer.centerYAnchor),
            
            genreStack.topAnchor.constraint(equalTo: genreContainer.topAnchor),
            genreStack.leadingAnchor.constraint(equalTo: genreContainer.leadingAnchor),
            genreStack.trailingAnchor.constraint(equalTo: genreContainer.trailingAnchor),
            genreStack.bottomAnchor.constraint(equalTo: genreContainer.bottomAnchor),
            
            genreIcon.widthAnchor.constraint(equalToConstant: 20),
            genreIcon.heightAnchor.constraint(equalToConstant: 20),
            ratingIconView.widthAnchor.constraint(equalToConstant: 20),
            ratingIconView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Создаем основной горизонтальный стек
        infoStackView.axis = .vertical
        infoStackView.spacing = 24  // Увеличиваем отступ между строками с 12 до 24
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Горизонтальный стек для года и рейтинга
        let topRowStack = UIStackView(arrangedSubviews: [yearContainer, ratingContainer])
        topRowStack.axis = .horizontal
        topRowStack.distribution = .fillEqually
        topRowStack.spacing = 16
        topRowStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем в основной стек два ряда
        infoStackView.addArrangedSubview(topRowStack)
        infoStackView.addArrangedSubview(genreContainer)
        
        contentView.addSubview(infoStackView)
        
        NSLayoutConstraint.activate([
            infoStackView.topAnchor.constraint(equalTo: titleNameLabel.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupDescriptionSection() {
        // Заголовок "Описание"
        descriptionTitleLabel.text = "Описание"
        descriptionTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        descriptionTitleLabel.textColor = Resources.Colors.textColor
        descriptionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Текст описания
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 17)
        descriptionLabel.textColor = Resources.DescriptionViewColors.descriptionColor
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionTitleLabel.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 30),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupActionButtons() {
        // Кнопка "Добавить в избранное"
        let heartImage = UIImage(systemName: "heart")
        favoriteButton.setImage(heartImage, for: .normal)
        favoriteButton.setTitle("  В избранное", for: .normal)
        favoriteButton.tintColor = Resources.Colors.textColor
        favoriteButton.backgroundColor = Resources.Colors.active
        favoriteButton.layer.cornerRadius = 20
        favoriteButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        // Кнопка "Поделиться"
        let shareImage = UIImage(systemName: "square.and.arrow.up")
        shareButton.setImage(shareImage, for: .normal)
        shareButton.setTitle("  Поделиться", for: .normal)
        shareButton.tintColor = Resources.Colors.textColor
        shareButton.backgroundColor = Resources.Colors.inactive
        shareButton.layer.cornerRadius = 20
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        // Горизонтальный стек для кнопок
        let buttonsStack = UIStackView(arrangedSubviews: [favoriteButton, shareButton])
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 16
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(buttonsStack)
        
        NSLayoutConstraint.activate([
            buttonsStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            buttonsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            buttonsStack.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Helper Methods
    private func createInfoStackView(iconName: String, label: UILabel, text: String, color: UIColor) -> UIStackView {
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = color
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return stack
    }
    
    private func loadData() {
        guard let movieDescription = movieDescription else { return }
        
        // Загрузка постера с анимацией
        networkManager.fetchPoster(from: movieDescription.posterURL) { [weak self] data in
            guard let self = self, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                UIView.transition(with: self.posterImageView,
                                 duration: 0.4,
                                 options: .transitionCrossDissolve,
                                 animations: { self.posterImageView.image = image },
                                 completion: nil)
            }
        }
        
        // Настройка текстовых полей
        titleNameLabel.text = movieDescription.nameRU
        releaseYearLabel.text = "\(movieDescription.year)"
        
        // Настройка рейтинга с цветовой индикацией
        let rating = movieDescription.ratingKinopoisk
        ratingLabel.text = String(format: "%.1f", rating)
        
        if rating >= 7.0 {
            ratingLabel.textColor = UIColor(hexString: "#4CD964") // Зеленый
        } else if rating >= 5.0 {
            ratingLabel.textColor = UIColor(hexString: "#FFCC00") // Желтый
        } else {
            ratingLabel.textColor = UIColor(hexString: "#FF3B30") // Красный
        }
        
        // Жанры с хештегами
        let genres = movieDescription.genres.map { "#\($0.genre)" }.joined(separator: " ")
        genreLabel.text = genres
        
        // Описание
        descriptionLabel.text = movieDescription.description
        
        // Проверяем статус избранного
        checkFavoriteStatus()
        
        // Анимация появления информации
        [titleNameLabel, infoStackView, descriptionTitleLabel, descriptionLabel].forEach { view in
            view.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: {
                view.alpha = 1
            })
        }
    }
    
    private func checkFavoriteStatus() {
        guard let movieDescription = movieDescription else { return }
        
        // Проверяем, находится ли фильм в избранном
        isFavorite = coreDataManager.isMovieInFavorites(id: movieDescription.kinopoiskID)
        
        // Обновляем внешний вид кнопки
        updateFavoriteButtonAppearance()
    }
    
    private func updateFavoriteButtonAppearance() {
        if isFavorite {
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            favoriteButton.setTitle("  В избранном", for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            favoriteButton.setTitle("  В избранное", for: .normal)
        }
    }
    
    // MARK: - Actions
    @objc private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func favoriteButtonTapped() {
        guard let movieDescription = movieDescription else { return }
        
        // Анимация кнопки
        UIView.animate(withDuration: 0.1, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.favoriteButton.transform = CGAffineTransform.identity
            }
        }
        
        // Тактильный отклик
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Логика добавления/удаления из избранного
        if isFavorite {
            // Удаляем из избранного
            coreDataManager.removeFromFavorites(id: movieDescription.kinopoiskID)
            isFavorite = false
        } else {
            // Добавляем в избранное
            coreDataManager.addToFavorites(movie: movieDescription)
            isFavorite = true
        }
        
        // Обновляем вид кнопки
        updateFavoriteButtonAppearance()
    }
    
    @objc private func shareButtonTapped() {
        guard let movieDescription = movieDescription else { return }
        
        // Анимация кнопки
        UIView.animate(withDuration: 0.1, animations: {
            self.shareButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.shareButton.transform = CGAffineTransform.identity
            }
        }
        
        // Тактильный отклик
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Создание текста для шаринга
        let textToShare = "Рекомендую посмотреть фильм \"\(movieDescription.nameRU)\" (\(movieDescription.year)). Рейтинг Кинопоиска: \(movieDescription.ratingKinopoisk)"
        
        // Инициализация Activity View Controller
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension MoviesDescriptionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        // Параллакс-эффект для постера
        if offset < 0 {
            let scale = 1 + abs(offset) / 500
            posterImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else {
            posterImageView.transform = .identity
        }
        
        // Анимация прозрачности для кнопки "Назад"
        if offset > 50 {
            UIView.animate(withDuration: 0.3) {
                self.backButton.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.backButton.alpha = 1 - offset / 50
            }
        }
    }
}
