import Foundation
import XCTest

public class UserTest: XCTestCase {
    
    private var mockUserClient = UserClient()

    func testFetchUserNotFound() async {
       let expectation = XCTestExpectation(description: "testFetchUserNotFound")
        do {
            _ = try await mockUserClient.fetchUser(id: 5555)
            XCTFail("user found")
            expectation.fulfill()
        } catch {
            XCTAssertTrue((error as NSError).code == 404)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
   }
    
    func testFetchUserFound() async {
        let expectation = XCTestExpectation(description: "testFetchUserFound")
        do {
            let user = try await mockUserClient.fetchUser(id: 2)
            XCTAssertTrue(user.id == 2)
            expectation.fulfill()
        } catch {
            XCTFail("user not found")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testFetchUsers() async {
        let expectation = XCTestExpectation(description: "testFetchUsers")
        do {
            let users = try await mockUserClient.fetchUsers(page: 3)
            XCTAssertFalse(users.isEmpty)
            expectation.fulfill()
        } catch {
            XCTFail("users not found")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testUpdateUser() async {
        let nameToUpdate = "Einstein"
        let expectation = XCTestExpectation(description: "testUpdateUser")
        do {
            let updatedUser = try await self.mockUserClient.updateUser(id: 31, params: ["name": nameToUpdate])
            XCTAssert(updatedUser.name == nameToUpdate)
            expectation.fulfill()
        } catch {
            XCTFail("user not found")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDeleteUser() async {
        let expectation = XCTestExpectation(description: "testUpdateUser")
        do {
            let success = try await self.mockUserClient.deleteUser(id: 30)
            XCTAssertTrue(success)
            expectation.fulfill()
        } catch {
            XCTFail("failed to delete")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
