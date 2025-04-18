//
//  Resources.swift
//  MovieList
//
//  Created by Артем Ворыпаев on 01.10.2024.
//

import Foundation
import UIKit

enum Resources {
    enum Colors {
        static let active = UIColor(hexString: "#7B68EE")        // Более яркий фиолетовый для активных элементов
        static let inactive = UIColor(hexString: "#9E9E9E")      // Серый для неактивных элементов
        static let tabBarColor = UIColor(hexString: "#121212")   // Темный для табБара
        static let backgroundColor = UIColor(hexString: "#1E1E1E") // Темный фон
        static let navBarColor = UIColor(hexString: "#1E1E2D")   // Темно-синий для навбара
        static let textColor = UIColor(hexString: "#FFFFFF")     // Белый для текста
        static let cardBackgroundColor = UIColor(hexString: "#252836") // Фон для карточек
        static let accentColor = UIColor(hexString: "#6C5CE7")   // Акцентный цвет
    }
    
    enum DescriptionViewColors {
        static let titleNameColor = UIColor(hexString: "#A897F8") // Светло-фиолетовый для заголовков
        static let descriptionColor = UIColor(hexString: "#BEBEBE") // Светло-серый для описаний
        static let backButtonColor = UIColor(hexString: "#7B68EE") // Фиолетовый для кнопки назад
        static let ratingColor = UIColor(hexString: "#FFD700")    // Золотой для рейтинга
    }
    
    enum Strings {
        enum TabBar {
            static let movies = "Фильмы"
            static let favorite = "Избранное"
        }
        
        enum Images {
            static let movies = UIImage(systemName: "film")
            static let favorite = UIImage(systemName: "heart.fill")
            static let placeholder = UIImage(systemName: "photo")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
            static let search = UIImage(systemName: "magnifyingglass")
            static let star = UIImage(systemName: "star.fill")
        }
        
        enum Alert {
            static let apiKeyTitle = "API Ключ"
            static let apiKeyMessage = "Пожалуйста, введите ваш API ключ от Кинопоиска"
            static let saveButton = "Сохранить"
        }
    }
    
    enum Layout {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let itemHeight: CGFloat = 280
        
        enum Shadow {
            static let opacity: Float = 0.3
            static let radius: CGFloat = 8
            static let offset = CGSize(width: 0, height: 4)
            static let color = UIColor.black.cgColor
        }
    }
}
