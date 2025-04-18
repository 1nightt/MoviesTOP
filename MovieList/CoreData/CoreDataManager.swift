import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoriteMovies")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Не удалось загрузить хранилище: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Не удалось сохранить контекст: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Favorites Management
    
    func addToFavorites(movie: MoviesDescription) {
        // Проверяем, не добавлен ли уже этот фильм
        if !isMovieInFavorites(id: movie.kinopoiskID) {
            let favoriteMovie = FavoriteMovie(context: context)
            favoriteMovie.id = Int64(movie.kinopoiskID)
            favoriteMovie.title = movie.nameRU
            favoriteMovie.posterUrl = movie.posterURL.absoluteString
            favoriteMovie.rating = movie.ratingKinopoisk
            favoriteMovie.year = Int16(movie.year)
            favoriteMovie.movieDescription = movie.description
            
            // Сохраняем жанры
            let genresString = movie.genres.map { $0.genre }.joined(separator: ",")
            favoriteMovie.genres = genresString
            
            saveContext()
        }
    }
    
    func removeFromFavorites(id: Int) {
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let movies = try context.fetch(fetchRequest)
            for movie in movies {
                context.delete(movie)
            }
            saveContext()
        } catch {
            print("Ошибка при удалении из избранного: \(error)")
        }
    }
    
    func isMovieInFavorites(id: Int) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Ошибка при проверке наличия в избранном: \(error)")
            return false
        }
    }
    
    func getAllFavorites() -> [FavoriteMovie] {
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Ошибка при получении списка избранного: \(error)")
            return []
        }
    }
    
    func convertToMoviesDescription(favoriteMovie: FavoriteMovie) -> MoviesDescription {
        let genres = favoriteMovie.genres?.components(separatedBy: ",").map { Genre(genre: $0) } ?? []
        
        return MoviesDescription(
            kinopoiskID: Int(favoriteMovie.id),
            nameRU: favoriteMovie.title ?? "",
            posterURL: URL(string: favoriteMovie.posterUrl ?? "") ?? URL(string: "https://placeholder.com")!,
            ratingKinopoisk: favoriteMovie.rating,
            year: Int(favoriteMovie.year),
            description: favoriteMovie.movieDescription ?? "",
            genres: genres
        )
    }
}