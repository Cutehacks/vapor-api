//
//  Group.swift
//  vapor-api
//
//  Created by Henrik Hartz on 11/10/2017.
//

import Vapor
import FluentProvider

final class Group: Model {
    let storage = Storage()

    var name: String
    var users: [String]

    init(name: String, users: [String]) {
        self.name = name
    }

    /// The column names for `id` and `content` in the database
    struct Keys {
        static let id = "id"
        static let name = "name"
        static let users = "users"
    }

    init(row: Row) throws {
        name = try row.get(Keys.name)
        users = try row.get(Keys.users)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.users, users)
        return row
    }
}

// MARK: Fluent Preparation

extension Group: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.name)
            builder.string(Keys.users)
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
extension Group: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Keys.name),
            users: try json.get(Keys.users)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.name, name)
        try json.set(Keys.users, users)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Group: ResponseRepresentable { }

// make entity have timestamp
extension Group: Timestampable {}

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Group: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Group>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Keys.name, Double.self) { group, name in
                group.name = name
            },
            UpdateableKey(Keys.users, Double.self) { group, users in
                group.users = users
            },
        ]
    }
}


