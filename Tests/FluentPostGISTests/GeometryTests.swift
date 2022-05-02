import XCTest
@testable import FluentPostGIS

final class GeometryTests: FluentPostGISTests {
    func testPoint() async throws {
        try await UserLocationMigration().prepare(on: db)
        defer { try! UserLocationMigration().revert(on: db).wait() }

        let point = GeometricPoint2D(x: 1, y: 2)

        let user = UserLocation(location: point)
        try await user.save(on: db)

        let fetched = try await UserLocation.find(1, on: db)
        XCTAssertEqual(fetched?.location, point)

        let all = try await UserLocation.query(on: db)
            .filterGeometryDistanceWithin(\.$location, user.location, 1000)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testLineString() async throws {
        try await UserPathMigration().prepare(on: db)
        defer { try! UserPathMigration().revert(on: db).wait() }

        let point = GeometricPoint2D(x: 1, y: 2)
        let point2 = GeometricPoint2D(x: 2, y: 3)
        let point3 = GeometricPoint2D(x: 3, y: 2)
        let lineString = GeometricLineString2D(points: [point, point2, point3, point])

        let user = UserPath(path: lineString)
        try await user.save(on: db)

        let fetched = try await UserPath.find(1, on: db)
        XCTAssertEqual(fetched?.path, lineString)
    }

    func testPolygon() async throws {
        try await UserAreaMigration().prepare(on: db)
        defer { try! UserAreaMigration().revert(on: db).wait() }

        let point = GeometricPoint2D(x: 1, y: 2)
        let point2 = GeometricPoint2D(x: 2, y: 3)
        let point3 = GeometricPoint2D(x: 3, y: 2)
        let lineString = GeometricLineString2D(points: [point, point2, point3, point])
        let polygon = GeometricPolygon2D(exteriorRing: lineString, interiorRings: [lineString, lineString])

        let user = UserArea(area: polygon)
        try await user.save(on: db)

        let fetched = try await UserArea.find(1, on: db)
        XCTAssertEqual(fetched?.area, polygon)
    }

    func testGeometryCollection() async throws {
        try await UserCollectionMigration().prepare(on: db)
        defer { try! UserCollectionMigration().revert(on: db).wait() }

        let point = GeometricPoint2D(x: 1, y: 2)
        let point2 = GeometricPoint2D(x: 2, y: 3)
        let point3 = GeometricPoint2D(x: 3, y: 2)
        let lineString = GeometricLineString2D(points: [point, point2, point3, point])
        let polygon = GeometricPolygon2D(exteriorRing: lineString, interiorRings: [lineString, lineString])
        let geometries: [GeometryCollectable] = [point, point2, point3, lineString, polygon]
        let geometryCollection = GeometricGeometryCollection2D(geometries: geometries)

        let user = UserCollection(collection: geometryCollection)
        try await user.save(on: db)

        let fetched = try await UserCollection.find(1, on: db)
        XCTAssertEqual(fetched?.collection, geometryCollection)
    }
}
