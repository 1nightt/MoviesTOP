import UIKit

class MoviesViewController: UIViewController {
    
    // MARK: - Private Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()
    private let emptyStateView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let networkManager = NetworkManager.shared
    
    // MARK: - Data Properties
    var dataSource = [Film]()
    var filteredMovies = [Film]()
    var isLoading = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Resources.Colors.backgroundColor
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: - Configuration
    private func configure() {
        checkAndRequestApiKey()
        setupNavBarController()
        setupSearchController()
        setupCollectionView()
        setupRefreshControl()
        setupLoadingIndicator()
        setupEmptyStateView()
        setupDismissKeyboardGesture()
        fetchAllMovies()
    }
    
    // MARK: - API Key Setup
    private func checkAndRequestApiKey() {
        guard KeychainManager.shared.retrieve(key: "apiKey") == nil else { return }
        showApiKeyAlert()
    }
    
    private func showApiKeyAlert() {
        let alert = UIAlertController(
            title: Resources.Strings.Alert.apiKeyTitle,
            message: Resources.Strings.Alert.apiKeyMessage,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "API Key"
            textField.returnKeyType = .done
            textField.keyboardType = .asciiCapable
            textField.autocorrectionType = .no
            textField.clearButtonMode = .whileEditing
        }
        
        alert.addAction(UIAlertAction(
            title: Resources.Strings.Alert.saveButton,
            style: .default,
            handler: { [weak self] _ in
                if let apiKey = alert.textFields?.first?.text, !apiKey.isEmpty {
                    self?.networkManager.setApiKey(apiKey)
                    self?.showLoadingIndicator()
                    self?.fetchAllMovies()
                } else {
                    self?.showApiKeyAlert()
                }
            }
        ))
        
        present(alert, animated: true)
    }
    
    // MARK: - UI Setup
    private func setupCollectionView() {
        // Используем обычный FlowLayout вместо композиционного макета
        let layout = UICollectionViewFlowLayout()
        
        // Настраиваем размер ячеек - два элемента в ряд с отступами
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 16
        let itemWidth = (screenWidth - padding * 3) / 2 // 3 отступа: слева, справа и между элементами
        let itemHeight = itemWidth * 1.5 // Соотношение сторон примерно 2:3
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = Resources.Colors.backgroundColor
        collectionView.register(MoviesCell.self, forCellWithReuseIdentifier: "MovieCell")
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = Resources.Colors.active
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.color = Resources.Colors.active
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupEmptyStateView() {
        let imageView = UIImageView(image: UIImage(systemName: "film"))
        imageView.tintColor = Resources.Colors.inactive
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Фильмы не найдены"
        label.textColor = Resources.Colors.inactive
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.addSubview(imageView)
        emptyStateView.addSubview(label)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalToConstant: 200),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200),
            
            imageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            label.bottomAnchor.constraint(lessThanOrEqualTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.attributedPlaceholder = NSAttributedString(
                string: "Поиск фильмов",
                attributes: [.foregroundColor: UIColor.lightGray]
            )
            textField.textColor = UIColor.white
            textField.tintColor = Resources.Colors.active
            
            if let leftView = textField.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor.white
            }
            
            textField.backgroundColor = Resources.Colors.navBarColor.withAlphaComponent(0.5)
        }
        
        searchController.searchBar.tintColor = Resources.Colors.active
    }
    
    private func setupNavBarController() {
        title = Resources.Strings.TabBar.movies
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Resources.Colors.navBarColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
    }
    
    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Data Management
    private func fetchAllMovies() {
        guard !isLoading else { return }
        
        isLoading = true
        showLoadingIndicator()
        
        networkManager.fetchAllMovies { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            self.hideLoadingIndicator()
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let movies):
                self.dataSource = movies
                self.filteredMovies = movies
                self.updateUI()
            case .failure(let error):
                print("Error in fetchAllMovies: \(error)")
                self.showEmptyState()
                // Можно добавить показ ошибки пользователю
            }
        }
    }
    
    private func updateUI() {
        if filteredMovies.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
            collectionView.reloadData()
        }
    }
    
    // MARK: - UI Helpers
    private func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
            self.collectionView.isHidden = true
            self.emptyStateView.isHidden = true
        }
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            self.collectionView.isHidden = false
        }
    }
    
    private func showEmptyState() {
        DispatchQueue.main.async {
            self.emptyStateView.isHidden = false
            self.collectionView.isHidden = true
        }
    }
    
    private func hideEmptyState() {
        DispatchQueue.main.async {
            self.emptyStateView.isHidden = true
            self.collectionView.isHidden = false
        }
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        fetchAllMovies()
    }
    
    @objc private func dismissKeyboard() {
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: - Navigation
    func navigateToMovieDescriptionViewController(with movieDescription: MoviesDescription) {
        let descriptionVC = MoviesDescriptionViewController()
        descriptionVC.movieDescription = movieDescription
        navigationController?.pushViewController(descriptionVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as? MoviesCell else {
            return UICollectionViewCell()
        }
        
        let film = filteredMovies[indexPath.row]
        
        // Настраиваем UI ячейки
        cell.label.text = film.nameRU
        cell.imageView.image = Resources.Strings.Images.placeholder
        
        // Анимированное появление ячейки
        cell.fadeIn()
        
        // Загружаем постер
        networkManager.fetchPoster(from: film.posterURLPreview) { image in
            DispatchQueue.main.async {
                // Проверяем, что ячейка все еще отображает тот же фильм
                if let visibleCell = collectionView.cellForItem(at: indexPath) as? MoviesCell,
                   visibleCell.label.text == film.nameRU {
                    UIView.transition(with: visibleCell.imageView,
                                      duration: 0.3,
                                      options: .transitionCrossDissolve,
                                      animations: { visibleCell.imageView.image = image },
                                      completion: nil)
                }
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let film = filteredMovies[indexPath.row]
        let filmId = film.filmID
        
        // Добавляем тактильную обратную связь
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Показываем индикатор загрузки
        showLoadingIndicator()
        
        NetworkManager.shared.fetchDescriptionMovies(for: String(filmId)) { [weak self] result in
            guard let self = self else { return }
            
            // Скрываем индикатор загрузки
            self.hideLoadingIndicator()
            
            switch result {
            case .success(let movieDescription):
                DispatchQueue.main.async {
                    self.navigateToMovieDescriptionViewController(with: movieDescription)
                }
            case .failure(let error):
                print("Error fetching movie description: \(error)")
                // Можно добавить показ ошибки пользователю
            }
        }
    }
}

// MARK: - Scrolling
extension MoviesViewController {
    func scrollToTop() {
        guard !dataSource.isEmpty else { return }
        
        let topOffset = CGPoint(x: 0, y: -collectionView.adjustedContentInset.top)
        collectionView.setContentOffset(topOffset, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension MoviesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        if searchText.isEmpty {
            filteredMovies = dataSource
        } else {
            filteredMovies = dataSource.filter { 
                $0.nameRU.lowercased().contains(searchText.lowercased()) 
            }
        }
        
        updateUI()
    }
}

// MARK: - UIScrollViewDelegate
extension MoviesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Плавное скрытие строки поиска при скролле вниз
        let offset = scrollView.contentOffset.y
        
        if offset > 100 && !searchController.isActive {
            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        
        // Анимация для навбара
        guard let navigationBar = navigationController?.navigationBar else { return }
        let alpha = min(1, max(0, 1 - (offset / 200)))
        navigationBar.alpha = alpha + 0.7 // Минимальная прозрачность 0.7
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}
