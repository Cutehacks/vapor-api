import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Posts table
final class LocationController: ResourceRepresentable {
    /// When users call 'GET' on '/posts'
    /// it should return an index of all available posts
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Location.all().makeJSON()
    }

    /// When consumers call 'POST' on '/posts' with valid JSON
    /// construct and save the user
    func store(_ req: Request) throws -> ResponseRepresentable {
        let location = try req.location()
        try location.save()
        return location
    }

    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific user
    func show(_ req: Request, location: Location) throws -> ResponseRepresentable {
        return location
    }

    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    func delete(_ req: Request, location: Location) throws -> ResponseRepresentable {
        try location.delete()
        return Response(status: .ok)
    }

    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/posts' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Location.makeQuery().delete()
        return Response(status: .ok)
    }

    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, location: Location) throws -> ResponseRepresentable {
        // See `extension Location: Updateable`
        try location.update(for: req)

        // Save an return the updated user.
        try location.save()
        return location
    }

    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Location with the same ID.
    func replace(_ req: Request, location: Location) throws -> ResponseRepresentable {
        // First attempt to create a new Location from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.location()

        // Update the user with all of the properties from
        // the new user
        location.lat = new.lat
        location.lon = new.lon
        location.elev = new.elev
        location.ts = new.ts
        location.userId = new.userId
        try location.save()

        // Return the updated user
        return location
    }

    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Location> {
        return Resource(
            index: index,
            store: store,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    /// Create a user from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func location() throws -> Location {
        guard let json = json else {
            throw Abort.badRequest
        }
        return try Location(json: json)
    }
}

/// Since PostController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension LocationController: EmptyInitializable { }


