import UIKit

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Получаем директорию для кэширования
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache")
        
        // Создаем директорию, если она не существует
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Ошибка при создании директории кэша: \(error)")
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Сохраняет изображение в кэш
    /// - Parameters:
    ///   - image: Изображение для сохранения
    ///   - url: URL изображения, используется как ключ
    func saveImageToCache(image: UIImage, forURL url: URL) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let filePath = cacheFilePath(forURL: url)
        
        do {
            try data.write(to: filePath)
        } catch {
            print("Ошибка при сохранении изображения в кэш: \(error)")
        }
    }
    
    /// Загружает изображение из кэша
    /// - Parameter url: URL изображения
    /// - Returns: Изображение или nil, если его нет в кэше
    func loadImageFromCache(forURL url: URL) -> UIImage? {
        let filePath = cacheFilePath(forURL: url)
        
        if fileManager.fileExists(atPath: filePath.path) {
            if let data = try? Data(contentsOf: filePath),
               let image = UIImage(data: data) {
                return image
            }
        }
        
        return nil
    }
    
    /// Проверяет, есть ли изображение в кэше
    /// - Parameter url: URL изображения
    /// - Returns: true, если изображение есть в кэше
    func imageExistsInCache(forURL url: URL) -> Bool {
        let filePath = cacheFilePath(forURL: url)
        return fileManager.fileExists(atPath: filePath.path)
    }
    
    /// Очищает весь кэш изображений
    func clearCache() {
        do {
            try fileManager.removeItem(at: cacheDirectory)
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Ошибка при очистке кэша: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func cacheFilePath(forURL url: URL) -> URL {
        // Создаем уникальное имя файла на основе URL
        let filename = url.absoluteString.hash.description
        return cacheDirectory.appendingPathComponent(filename)
    }
}