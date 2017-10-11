//
//  Location.swift
//  vapor-api
//
//  Created by Henrik Hartz on 11/10/2017.
//

import Vapor
import FluentProvider

final class Location: Model {
    let storage = Storage()

    var userId: String
    var lat: Double
    var lon: Double
    var elev: Double
    var ts: Double

    init(userId aUserId: String, latitude: Double, longitude: Double, elevation: Double = 0, timestamp: Double) {
        userId = aUserId
        lat = latitude
        lon = longitude
        elev = elevation
        ts = timestamp
    }

    /// The column names for `id` and `content` in the database
    struct Keys {
        static let id = "id"
        static let userId = "userId"
        static let lat = "lat"
        static let lon = "lon"
        static let elev = "elev"
        static let ts = "ts"
    }

    init(row: Row) throws {
        userId = try row.get(Keys.userId)
        lat = try row.get(Keys.lat)
        lon = try row.get(Keys.lon)
        elev = try row.get(Keys.elev)
        ts = try row.get(Keys.ts)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.userId, userId)
        try row.set(Keys.lat, lat)
        try row.set(Keys.lon, lon)
        try row.set(Keys.elev, elev)
        try row.set(Keys.ts, ts)
        return row
    }
}

// MARK: Fluent Preparation

extension Location: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.userId)
            builder.double(Keys.lat)
            builder.double(Keys.lon)
            builder.double(Keys.elev)
            builder.double(Keys.ts)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Location: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            userId: try json.get(Keys.userId),
            latitude: try json.get(Keys.lat),
            longitude: try json.get(Keys.lon),
            elevation: try json.get(Keys.elev),
            timestamp: try json.get(Keys.ts)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.userId, userId)
        try json.set(Keys.lat, lat)
        try json.set(Keys.lon, lon)
        try json.set(Keys.elev, elev)
        try json.set(Keys.ts, ts)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Location: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Location: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Location>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Keys.lat, Double.self) { location, lat in
                location.lat = lat
            },
            UpdateableKey(Keys.lon, Double.self) { location, lon in
                location.lon = lon
            },
            UpdateableKey(Keys.elev, Double.self) { location, elev in
                location.elev = elev
            },
            UpdateableKey(Keys.ts, Double.self) { location, ts in
                location.ts = ts
            },
//            UpdateableKey(Keys.userId, String.self) { location, userId in
//                location.userId = userId
//            }
        ]
    }
}
