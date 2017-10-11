//
//  User.swift
//  vapor-apiPackageDescription
//
//  Created by Henrik Hartz on 11/10/2017.
//

import Vapor
import FluentProvider

final class User: Model {
    let storage = Storage()

    var name: String

    init(name aName:String) {
        name = aName
    }

    /// The column names for `id` and `content` in the database
    struct Keys {
        static let id = "id"
        static let name = "name"
    }

    init(row: Row) throws {
        name = try row.get(User.Keys.name)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        return row
    }
}

// MARK: Fluent Preparation

extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.name)
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
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Keys.name)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.name, name)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension User: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension User: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<User>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Keys.name, String.self) { user, name in
                user.name = name
            }
        ]
    }
}
