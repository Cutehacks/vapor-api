import XCTest
import Testing
import HTTP
import Sockets
@testable import Vapor
@testable import App

class UserControllerTests: TestCase {
    let initialName = "User Name"
    let updatedName = "John Doe"

    let controller = UserController()

    func testUserRoutes() throws {
        guard let userOne = try storeNewUser(), let idOne = userOne.id?.int else {
            XCTFail()
            return
        }

        try fetchOne(id: idOne)
        try fetchAll(expectCount: 1)
        try patch(id: idOne)
        try put(id: idOne)

        guard let userTwo = try storeNewUser(), let idTwo = userTwo.id?.int else {
            XCTFail()
            return
        }

        try fetchAll(expectCount: 2)

        try deleteOne(id: idOne)
        try fetchAll(expectCount: 1)

        try deleteOne(id: idTwo)
        try fetchAll(expectCount: 0)

        for _ in 1...5 {
            _ = try storeNewUser()
        }
        try fetchAll(expectCount: 5)
        try deleteAll()
        try fetchAll(expectCount: 0)
    }

    func storeNewUser() throws -> User? {
        let req = Request.makeTest(method: .post)
        req.json = try JSON(node: ["name": initialName])
        let res = try controller.store(req).makeResponse()

        let json = res.json
        XCTAssertNotNil(json)
        let newId: Int? = try json?.get("id")
        XCTAssertNotNil(newId)
        XCTAssertNotNil(json?["name"])
        XCTAssertEqual(json?["name"]?.string, initialName)
        return try User.find(newId)
    }

    func fetchOne(id: Int) throws {
        let req = Request.makeTest(method: .get)
        let user = try User.find(id)!
        let res = try controller.show(req, user: user).makeResponse()

        let json = res.json
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["name"])
        XCTAssertNotNil(json?["id"])
        XCTAssertEqual(json?["id"]?.int, id)
        XCTAssertEqual(json?["name"]?.string, initialName)
    }

    func fetchAll(expectCount count: Int) throws {
        let req = Request.makeTest(method: .get)
        let res = try controller.index(req).makeResponse()

        let json = res.json
        XCTAssertNotNil(json?.array)
        XCTAssertEqual(json?.array?.count, count)
    }

    func patch(id: Int) throws {
        let req = Request.makeTest(method: .patch)
        req.json = try JSON(node: ["name": updatedName])
        let user = try User.find(id)!
        let res = try controller.update(req, user: user).makeResponse()

        let json = res.json
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["name"])
        XCTAssertNotNil(json?["id"])
        XCTAssertEqual(json?["id"]?.int, id)
        XCTAssertEqual(json?["name"]?.string, updatedName)
    }

    func put(id: Int) throws {
        let req = Request.makeTest(method: .put)
        req.json = try JSON(node: ["name": updatedName])
        let user = try User.find(id)!
        let res = try controller.replace(req, user: user).makeResponse()

        let json = res.json
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["name"])
        XCTAssertNotNil(json?["id"])
        XCTAssertEqual(json?["id"]?.int, id)
        XCTAssertEqual(json?["name"]?.string, updatedName)
    }

    func deleteOne(id: Int) throws {
        let req = Request.makeTest(method: .delete)

        let user = try User.find(id)!
        _ = try controller.delete(req, user: user)
    }

    func deleteAll() throws {
        let req = Request.makeTest(method: .delete)
        _ = try controller.clear(req)
    }
}

// MARK: Manifest

extension UserControllerTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testUserRoutes", testUserRoutes),
        ]
}

