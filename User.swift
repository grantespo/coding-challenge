import Foundation

public struct User: Codable, Equatable {
    public let id: Int
    public var name: String
    private let email: String
    
    init(id: Int, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
