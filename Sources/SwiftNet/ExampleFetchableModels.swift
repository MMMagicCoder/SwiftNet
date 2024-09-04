import Foundation

struct DataModel: FetchableModel {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

struct ImageModel: FetchableModel {
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}
