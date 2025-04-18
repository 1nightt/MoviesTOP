import UIKit

class FavoriteViewController: UIViewController {
    
    // MARK: - UI Components
    private let emptyStateView = UIView()
    private var tableView: UITableView!
    
    // MARK: - Properties
    private var favorites: [MoviesDescription] = [] // Здесь будут храниться избранные фильмы
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = Resources.Colors.backgroundColor
        setupNavigationBar()
        setupTableView()
        setupEmptyStateView()
    }
    
    private func setupNavigationBar() {
        title = Resources.Strings.TabBar.favorite
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Resources.Colors.navBarColor
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(FavoriteMovieCell.self, forCellReuseIdentifier: "FavoriteCell")
        tableView.backgroundColor = Resources.Colors.backgroundColor
        tableView.separatorStyle = .none
        tableView.rowHeight = 140
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEmptyStateView() {
        let imageView = UIImageView(image: UIImage(systemName: "heart.slash.fill"))
        imageView.tintColor = Resources.Colors.inactive
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Нет избранных фильмов"
        titleLabel.textColor = Resources.Colors.textColor
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Добавьте фильмы в избранное, чтобы они отображались здесь"
        subtitleLabel.textColor = Resources.Colors.inactive
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.backgroundColor = Resources.Colors.backgroundColor
        emptyStateView.addSubview(imageView)
        emptyStateView.addSubview(titleLabel)
        emptyStateView.addSubview(subtitleLabel)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            imageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    // MARK: - UI Updates
    private func updateUI() {
        if favorites.isEmpty {
            tableView.isHidden = true
            emptyStateView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyStateView.isHidden = true
            tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    @objc private func addDummyFavorite() {
        // Временная функция для демонстрации UI избранного
        // В реальном приложении здесь будет логика добавления из основного экрана
        
        let dummyMovie = MoviesDescription(
            kinopoiskID: 123,
            nameRU: "Пример фильма",
            posterURL: URL(string: "https://example.com/poster.jpg")!,
            ratingKinopoisk: 8.5,
            year: 2023,
            description: "Описание фильма будет здесь",
            genres: [Genre(genre: "Драма"), Genre(genre: "Триллер")]
        )
        
        favorites.append(dummyMovie)
        updateUI()
    }
}

// MARK: - UITableViewDataSource
extension FavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoriteMovieCell else {
            return UITableViewCell()
        }
        
        let movie = favorites[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Открыть детальную информацию о фильме
        let movie = favorites[indexPath.row]
        let detailVC = MoviesDescriptionViewController()
        detailVC.movieDescription = movie
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Действие удаления из избранного
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            self.favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if self.favorites.isEmpty {
                self.updateUI()
            }
            
            completion(true)
        }
        
        deleteAction.backgroundColor = UIColor.systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - FavoriteMovieCell
class FavoriteMovieCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let yearLabel = UILabel()
    private let ratingLabel = UILabel()
    private let genreLabel = UILabel()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupViews() {
        backgroundColor = Resources.Colors.backgroundColor
        selectionStyle = .none
        
        // Контейнер
        containerView.backgroundColor = Resources.Colors.cardBackgroundColor
        containerView.layer.cornerRadius = Resources.Layout.cornerRadius
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Тень
        containerView.layer.shadowColor = Resources.Layout.Shadow.color
        containerView.layer.shadowOpacity = Resources.Layout.Shadow.opacity
        containerView.layer.shadowRadius = Resources.Layout.Shadow.radius
        containerView.layer.shadowOffset = Resources.Layout.Shadow.offset
        
        // Постер
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        posterImageView.layer.cornerRadius = 8
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Название
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = Resources.Colors.textColor
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Год
        yearLabel.font = UIFont.systemFont(ofSize: 14)
        yearLabel.textColor = UIColor.lightGray
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Рейтинг
        ratingLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Жанр
        genreLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        genreLabel.textColor = UIColor.lightGray
        genreLabel.numberOfLines = 1
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        containerView.addSubview(posterImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(yearLabel)
        containerView.addSubview(ratingLabel)
        containerView.addSubview(genreLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            posterImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            posterImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            posterImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            posterImageView.widthAnchor.constraint(equalToConstant: 70),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            yearLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            ratingLabel.leadingAnchor.constraint(equalTo: yearLabel.trailingAnchor, constant: 8),
            
            genreLabel.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 4),
            genreLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            genreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            genreLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with movie: MoviesDescription) {
        titleLabel.text = movie.nameRU
        yearLabel.text = String(movie.year)
        
        // Настройка рейтинга с цветовой индикацией
        let rating = movie.ratingKinopoisk
        ratingLabel.text = "★ \(String(format: "%.1f", rating))"
        
        if rating >= 7.0 {
            ratingLabel.textColor = UIColor(hexString: "#4CD964") // Зеленый
        } else if rating >= 5.0 {
            ratingLabel.textColor = UIColor(hexString: "#FFCC00") // Желтый
        } else {
            ratingLabel.textColor = UIColor(hexString: "#FF3B30") // Красный
        }
        
        // Жанры
        let genres = movie.genres.prefix(2).map { $0.genre }.joined(separator: ", ")
        genreLabel.text = genres
        
        // Загрузка изображения (в реальном приложении использовать NetworkManager)
        posterImageView.image = Resources.Strings.Images.placeholder
        
        NetworkManager.shared.fetchPoster(from: movie.posterURL) { [weak self] data in
            DispatchQueue.main.async {
                self?.posterImageView.image = UIImage(data: data)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = Resources.Strings.Images.placeholder
        titleLabel.text = nil
        yearLabel.text = nil
        ratingLabel.text = nil
        genreLabel.text = nil
    }
}
