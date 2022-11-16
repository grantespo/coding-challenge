import Foundation

public class UserClient {
    public static let shared = UserClient()
    
    private let baseURL = "https://gorest.co.in/public/v2/users"
    private var token: String {
        let env = ProcessInfo.processInfo.environment
        guard let index = env.index(forKey: "go_rest_token") else {
            return ""
        }
        return env[index].1
    }
        
    public func fetchUsers(page: Int) async throws -> [User] {
        return try await withCheckedThrowingContinuation { continuation in
            let url = URL(string: "\(self.baseURL)?page=\(page)&per_page=20")!
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                do {
                    guard error == nil, let unwrappedData = data, let httpUrlResponse = response as? HTTPURLResponse, let totalPages = httpUrlResponse.allHeaderFields["x-pagination-pages"] as? String else {
                        throw error ?? NSError()
                    }
                    //MARK: 2) Using a logger, log the total number of pages from the previous request.
                    print("Total pages: \(totalPages)")
                    let users = try JSONDecoder().decode([User].self, from: unwrappedData)
                    continuation.resume(returning: users)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            task.resume()
        }
    }
    
    public func fetchUser(id: Int) async throws -> User {
        return try await withCheckedThrowingContinuation { continuation in
            let url = URL(string: "\(self.baseURL)/\(id)")!
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                do {
                    guard error == nil, let unwrappedData = data else {
                        throw error ?? NSError()
                    }
                    if statusCode == 404 {
                        // MARK: 7 b) Log the resulting http response code.
                        print("statusCode: \(statusCode)")
                        throw NSError(domain: "", code: statusCode, userInfo: [:])
                    }
                    let user = try JSONDecoder().decode(User.self, from: unwrappedData)
                    continuation.resume(returning: user)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            task.resume()
        }
    }
    
    public func updateUser(id: Int, params: [String: Any]) async throws -> User {
        return try await withCheckedThrowingContinuation { continuation in
            let url = URL(string: "\(self.baseURL)/\(id)")!
            var request = URLRequest(url: url)
            let postData = try? JSONSerialization.data(withJSONObject: params, options: [])
            
            request.httpMethod = "PUT"
            request.httpBody = postData
            request.allHTTPHeaderFields = [
                "content-type": "application/json",
                "Authorization": "Bearer \(self.token)"
            ]
            let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { (data, response, error) in
                do {
                    guard error == nil, let unwrappedData = data else {
                        throw error ?? NSError()
                    }
                    let user = try JSONDecoder().decode(User.self, from: unwrappedData)
                    continuation.resume(returning: user)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            task.resume()
        }
    }
    
    public func deleteUser(id: Int) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            let url = URL(string: "\(self.baseURL)/\(id)")!
            var request = URLRequest(url: url)
            
            request.httpMethod = "DELETE"
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)"
            ]
            let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { (data, response, error) in
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                do {
                    guard error == nil else {
                        throw error ?? NSError()
                    }
                    continuation.resume(returning: statusCode == 204)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            task.resume()
        }
    }
}
