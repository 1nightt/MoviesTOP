import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupAppearance()
        delegate = self
    }
    
    // MARK: - Configuration
    private func configure() {
        let moviesViewController = MoviesViewController()
        let favoriteViewController = FavoriteViewController()
        
        // Создаем навигационные контроллеры для каждого таба
        let moviesNavViewController = UINavigationController(rootViewController: moviesViewController)
        let favoriteNavViewController = UINavigationController(rootViewController: favoriteViewController)
        
        // Настраиваем элементы таб-бара
        moviesNavViewController.tabBarItem = createTabBarItem(
            title: Resources.Strings.TabBar.movies,
            image: Resources.Strings.Images.movies,
            selectedImage: Resources.Strings.Images.movies
        )
        
        favoriteNavViewController.tabBarItem = createTabBarItem(
            title: Resources.Strings.TabBar.favorite,
            image: Resources.Strings.Images.favorite,
            selectedImage: Resources.Strings.Images.favorite
        )
        
        // Устанавливаем контроллеры представления
        setViewControllers([moviesNavViewController, favoriteNavViewController], animated: true)
    }
    
    private func setupAppearance() {
        // Настройка внешнего вида таб-бара
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Resources.Colors.tabBarColor
        
        // Настройка заголовков вкладок
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Resources.Colors.inactive
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Resources.Colors.active
        ]
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = Resources.Colors.inactive
        appearance.stackedLayoutAppearance.selected.iconColor = Resources.Colors.active
        
        // Добавляем нижнюю тень для таб-бара
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.3)
        appearance.shadowImage = createShadowImage()
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    // MARK: - Helper Methods
    private func createTabBarItem(title: String, image: UIImage?, selectedImage: UIImage?) -> UITabBarItem {
        let tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        
        // Смещение значка и текста для лучшего внешнего вида
        tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
        tabBarItem.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)
        
        return tabBarItem
    }
    
    private func createShadowImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        let context = UIGraphicsGetCurrentContext()
        UIColor.black.withAlphaComponent(0.1).setFill()
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let navigationController = viewController as? UINavigationController,
           let moviesViewController = navigationController.viewControllers.first as? MoviesViewController,
           viewController == selectedViewController {
            // Прокрутка к верху при повторном нажатии на вкладку "Фильмы"
            moviesViewController.scrollToTop()
            
            // Тактильная обратная связь при нажатии
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        // Анимируем переключение вкладок
        animateTabTransition(to: viewController)
        
        return true
    }
    
    private func animateTabTransition(to viewController: UIViewController) {
        guard let fromView = selectedViewController?.view,
              let toView = viewController.view,
              fromView != toView else {
            return
        }
        
        // Анимация перехода между вкладками
        UIView.transition(from: fromView, 
                         to: toView, 
                         duration: 0.2, 
                         options: [.transitionCrossDissolve], 
                         completion: nil)
    }
}
