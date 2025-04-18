import Foundation

struct MoviesDescription: Codable {
    let kinopoiskID: Int
    let nameRU: String
    let posterURL: URL
    let ratingKinopoisk: Double
    let year: Int
    let description: String
    let genres: [Genre]
    
    enum CodingKeys: String, CodingKey {
        case kinopoiskID = "kinopoiskId"
        case nameRU = "nameRu"
        case posterURL = "posterUrl"
        case ratingKinopoisk
        case year
        case description
        case genres
    }
    
}

struct Genre: Codable {
    let genre: String
}
