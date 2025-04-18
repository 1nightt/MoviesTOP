import Foundation

enum NetworkError: Error {
    case invalidURL, decodingError, noData
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private var apiKey: String? {
        return KeychainManager.shared.retrieve(key: "apiKey")
    }
    
    private init() {}
    
    func setApiKey(_ key: String) {
        let success = KeychainManager.shared.save(key: "apiKey", value: key)
        if success {
            print("API key saved successfully")
        } else {
            print("Failed to save API key")
        }
    }

    func fetchPoster(from url: URL, completion: @escaping (Data) -> Void) {
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else { return }
            
            DispatchQueue.main.async {
                completion(imageData)
            }
        }
    }
    
    func fetchMovies(page: Int, completion: @escaping (Result<Movies, NetworkError>) -> Void) {
        guard let apiKey = self.apiKey else {
            print("API key not set")
            return
        }
        
        var urlComponents = URLComponents(string: Link.allMovies.url.absoluteString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)")
        ]
        guard let url = urlComponents?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
            }
            
            guard let data = data else {
                print(error?.localizedDescription ?? "No error description")
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let moviesQuery = try decoder.decode(Movies.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(moviesQuery))
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }

    func fetchAllMovies(completion: @escaping (Result<[Film], NetworkError>) -> Void) {
        var allMovies: [Film] = []
        var currentPage = 1
        let dispatchGroup = DispatchGroup()
        
        func loadPage(page: Int) {
            dispatchGroup.enter()
            fetchMovies(page: page) { result in
                switch result {
                case .success(let movies):
                    allMovies.append(contentsOf: movies.films)
                    if page < movies.pagesCount {
                        currentPage += 1
                        loadPage(page: currentPage)
                    }
                case .failure(let error):
                    print("Error fetching page \(page): \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        loadPage(page: currentPage)
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(allMovies))
        }
    }

    func fetchDescriptionMovies(for filmId: String, completion: @escaping (Result<MoviesDescription, NetworkError>) -> Void) {
        guard let apiKey = self.apiKey else {
            print("API key not set")
            return
        }
        
        let urlString = "https://kinopoiskapiunofficial.tech/api/v2.2/films/\(filmId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
            }
            
            guard let data = data else {
                print(error?.localizedDescription ?? "No error description")
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let moviesDescriptionQuery = try decoder.decode(MoviesDescription.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(moviesDescriptionQuery))
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

extension NetworkManager {
    enum Link {
        case allMovies
        
        var url: URL {
            switch self {
            case .allMovies:
                return URL(string: "https://kinopoiskapiunofficial.tech/api/v2.2/films/top")!
            }
        }
    }
}
