import Foundation

struct Movies: Codable {
    let pagesCount: Int
    let films: [Film]
}

struct Film: Codable {
    let filmID: Int
    let nameRU: String
    let posterURLPreview: URL
    
    enum CodingKeys: String, CodingKey {
        case filmID = "filmId"
        case nameRU = "nameRu"
        case posterURLPreview = "posterUrlPreview"
    }
}
