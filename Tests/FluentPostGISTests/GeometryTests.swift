import XCTest
@testable import FluentPostGIS

final class GeometryTests: FluentPostGISTests {
    func testPoint() throws {
        try UserLocationMigration().prepare(on: conn).wait()
        defer { try! UserLocationMigration().revert(on: conn).wait() }

        let point = GeometricPoint2D(x: 1, y: 2)

        let user = UserLocation()
        user.location = point
        _ = try user.save(on: conn).wait()

        let fetched = try UserLocation.find(1, on: conn).wait()
        XCTAssertEqual(fetched?.location, point)

        let all = try UserLocation.query(on: conn).filterGeometryDistanceWithin(\.$location, user.location, 1000).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testLineString() throws {
        try UserPathMigration().prepare(on: conn).wait()
        defer { try! UserPathMigration().revert(on: conn).wait() }

        let point = GeometricPoint2D(x: 1, y: 2)
        let point2 = GeometricPoint2D(x: 2, y: 3)
        let point3 = GeometricPoint2D(x: 3, y: 2)
        let lineString = GeometricLineString2D(points: [point, point2, point3, point])

        let user = UserPath()
        user.path = lineString
        _ = try user.save(on: conn).wait()

        let fetched = try UserPath.find(1, on: conn).wait()
        XCTAssertEqual(fetched?.path, lineString)
    }

    func testPolygon() throws {
        try UserAreaMigration().prepare(on: conn).wait()
        defer { try! UserAreaMigration().revert(on: conn).wait() }

        let point = GeometricPoint2D(x: 1, y: 2)
        let point2 = GeometricPoint2D(x: 2, y: 3)
        let point3 = GeometricPoint2D(x: 3, y: 2)
        let lineString = GeometricLineString2D(points: [point, point2, point3, point])
        let polygon = GeometricPolygon2D(exteriorRing: lineString, interiorRings: [lineString, lineString])

        let user = UserArea()
        user.area = polygon
        _ = try user.save(on: conn).wait()

        let fetched = try UserArea.find(1, on: conn).wait()
        XCTAssertEqual(fetched?.area, polygon)
    }

    func testGeometryCollection() throws {
        try UserCollectionMigration().prepare(on: conn).wait()
        defer { try! UserCollectionMigration().revert(on: conn).wait() }

        let point = GeometricPoint2D(x: 1, y: 2)
        let point2 = GeometricPoint2D(x: 2, y: 3)
        let point3 = GeometricPoint2D(x: 3, y: 2)
        let lineString = GeometricLineString2D(points: [point, point2, point3, point])
        let polygon = GeometricPolygon2D(exteriorRing: lineString, interiorRings: [lineString, lineString])
        let geometries: [GeometryCollectable] = [point, point2, point3, lineString, polygon]
        let geometryCollection = GeometricGeometryCollection2D(geometries: geometries)

        let user = UserCollection()
        user.collection = geometryCollection
        _ = try user.save(on: conn).wait()

        let fetched = try UserCollection.find(1, on: conn).wait()
        XCTAssertEqual(fetched?.collection, geometryCollection)
    }
}
