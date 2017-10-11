import XCTest
import Testing
import HTTP
import Sockets
@testable import Vapor
@testable import App

class LocationControllerTests: TestCase {
    let initialLatLonElevDate = (10.0,59.0,1.0,123456789.0,"1")
    let updatedLatLonElevDate = (11.0,60.0,1.0,987654321.0,"2")

    let controller = LocationController()

    func testLocationRoutes() throws {
        guard let locationOne = try storeNewLocation(), let idOne = locationOne.id?.int else {
            XCTFail()
            return
        }

        try fetchOne(id: idOne)
        try fetchAll(expectCount: 1)
        try patch(id: idOne)
        try put(id: idOne)

        guard let locationTwo = try storeNewLocation(), let idTwo = locationTwo.id?.int else {
            XCTFail()
            return
        }

        try fetchAll(expectCount: 2)

        try deleteOne(id: idOne)
        try fetchAll(expectCount: 1)

        try deleteOne(id: idTwo)
        try fetchAll(expectCount: 0)

        for _ in 1...5 {
            _ = try storeNewLocation()
        }
        try fetchAll(expectCount: 5)
        try deleteAll()
        try fetchAll(expectCount: 0)
    }

    func storeNewLocation() throws -> Location? {
        let req = Request.makeTest(method: .post)
        req.json = try JSON(node: [
            "lat": initialLatLonElevDate.0,
            "lon": initialLatLonElevDate.1,
            "elev": initialLatLonElevDate.2,
            "ts": initialLatLonElevDate.3,
            "userId": initialLatLonElevDate.4
            ]
        )
        let res = try controller.store(req).makeResponse()

        let json = res.json
        XCTAssertNotNil(json)
        let newId: Int? = try json?.get("id")
        XCTAssertNotNil(newId)
        XCTAssertNotNil(json?["lat"])
        XCTAssertEqual(json?["lat"]?.double, initialLatLonElevDate.0)
        XCTAssertEqual(json?["userId"]?.string, initialLatLonElevDate.4)
        return try Location.find(newId)
    }

    func fetchOne(id: Int) throws {
        let req = Request.makeTest(method: .get)
        let location = try Location.find(id)!
        let res = try controller.show(req, location: location).makeResponse()

        let json = res.json
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["id"])
        XCTAssertNotNil(json?["lat"])
        XCTAssertNotNil(json?["lon"])
        XCTAssertNotNil(json?["elev"])
        XCTAssertNotNil(json?["ts"])
        XCTAssertEqual(json?["id"]?.int, id)
        XCTAssertEqual(json?["lat"]?.double, initialLatLonElevDate.0)
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
        req.json = try JSON(node: [
            "lat": updatedLatLonElevDate.0,
            "lon": updatedLatLonElevDate.1,
            "elev": updatedLatLonElevDate.2,
            "ts": updatedLatLonElevDate.3,
            "userId": updatedLatLonElevDate.4
            ])
        let location = try Location.find(id)!
        let res = try controller.update(req, location: location).makeResponse()

        let json = res.json
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["lat"])
        XCTAssertNotNil(json?["lon"])
        XCTAssertNotNil(json?["elev"])
        XCTAssertNotNil(json?["ts"])
        XCTAssertNotNil(json?["id"])
        XCTAssertEqual(json?["id"]?.int, id)
        XCTAssertEqual(json?["lon"]?.double, updatedLatLonElevDate.1)
        XCTAssertEqual(json?["userId"]?.string, initialLatLonElevDate.4)
    }

    func put(id: Int) throws {
        let req = Request.makeTest(method: .put)
        req.json = try JSON(node: [
            "lat": updatedLatLonElevDate.0,
            "lon": updatedLatLonElevDate.1,
            "elev": updatedLatLonElevDate.2,
            "ts": updatedLatLonElevDate.3,
            "userId": updatedLatLonElevDate.4
            ])
        let location = try Location.find(id)!
        let res = try controller.replace(req, location: location).makeResponse()

        let json = res.json
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["lat"])
        XCTAssertNotNil(json?["id"])
        XCTAssertEqual(json?["id"]?.int, id)
        XCTAssertEqual(json?["lat"]?.double, updatedLatLonElevDate.0)
    }

    func deleteOne(id: Int) throws {
        let req = Request.makeTest(method: .delete)

        let location = try Location.find(id)!
        _ = try controller.delete(req, location: location)
    }

    func deleteAll() throws {
        let req = Request.makeTest(method: .delete)
        _ = try controller.clear(req)
    }
}

// MARK: Manifest

extension LocationControllerTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testLocationRoutes", testLocationRoutes),
        ]
}


