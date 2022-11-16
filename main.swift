import UIKit

public var users = [User]()

do {
    // MARK: 1) Retrieve page 3 of the list of all users.
    users = try await UserClient.shared.fetchUsers(page: 3)
    
    // MARK: 3) Sort the retrieved user list by name.
    users.sort(by: {
        $0.name.lowercased() < $1.name.lowercased()
    })
    
    // MARK: 4) After sorting, log the name of the last user.
    guard let lastUser = users.last else {
        throw NSError()
    }
    print("Last user: \(lastUser.name)")
    
    // MARK: 5) Update that user's name to a new value and use the correct http method to save it.
    let newName = "Jon Smith"
    guard let index = users.firstIndex(where: {
        $0.id == lastUser.id
    }) else {
        throw NSError()
    }
    users[index].name = newName
    let updatedUser = try await UserClient.shared.updateUser(id: users[index].id, params: ["name": newName])
    
    // MARK: 6) Delete that user
    let id = updatedUser.id
    users.removeAll {
        $0.id == updatedUser.id
    }
    let success = try await UserClient.shared.deleteUser(id: id)
    
    // MARK: 7 a) Attempt to retrieve a nonexistent user with ID 5555
    try await UserClient.shared.fetchUser(id: 5555)
} catch {
    print(error.localizedDescription)
}

// MARK: 8) Write unit tests for all code, mocking out calls to the actual API service.
UserTest.defaultTestSuite.run()

