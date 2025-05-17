@testable import FluentPostGIS
import FluentKit
import XCTest

final class QueryTests: FluentPostGISTestCase {
    func testAlias() {
        let query = Guest.query(on: self.db)
            .join(Host.self, on: \Guest.$host.$id == \Host.$id)
        
        for join in query.query.joins {
            if case DatabaseQuery.Join.join(
                schema: let schema,
                alias: let alias?,
                let method,
                let foreign,
                let local
            ) = join
            { XCTAssertTrue(!alias.isEmpty) }
        }
    }
    
    func testContains() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let user = UserArea(area: polygon)
        try await user.save(on: self.db)

        let testPoint = GeometricPoint2D(x: 5, y: 5)
        let all = try await UserArea.query(on: self.db)
            .filterGeometryContains(\.$area, testPoint)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testContainsReversed() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPoint = GeometricPoint2D(x: 5, y: 5)
        let user = UserLocation(location: testPoint)
        try await user.save(on: self.db)

        let all = try await UserLocation.query(on: self.db)
            .filterGeometryContains(polygon, \.$location)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testContainsWithHole() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let hole = GeometricLineString2D(points: [
            GeometricPoint2D(x: 2.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 2.5),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing, interiorRings: [hole])

        let user = UserArea(area: polygon)
        try await user.save(on: self.db)

        let testPoint = GeometricPoint2D(x: 5, y: 5)
        let all = try await UserArea.query(on: self.db)
            .filterGeometryContains(\.$area, testPoint)
            .all()
        XCTAssertEqual(all.count, 0)

        let testPoint2 = GeometricPoint2D(x: 1, y: 5)
        let all2 = try await UserArea.query(on: self.db)
            .filterGeometryContains(\.$area, testPoint2)
            .all()
        XCTAssertEqual(all2.count, 1)
    }

    func testCrosses() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 5, y: 5),
        ])

        let user = UserArea(area: polygon)
        try await user.save(on: self.db)

        let all = try await UserArea.query(on: self.db)
            .filterGeometryCrosses(\.$area, testPath)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testCrossesReversed() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 5, y: 5),
        ])

        let user = UserPath(path: testPath)
        try await user.save(on: self.db)

        let all = try await UserPath.query(on: self.db)
            .filterGeometryCrosses(polygon, \.$path)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testDisjoint() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 11, y: 5),
        ])

        let user = UserArea(area: polygon)
        try await user.save(on: self.db)

        let all = try await UserArea.query(on: self.db)
            .filterGeometryDisjoint(\.$area, testPath)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testDisjointReversed() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 11, y: 5),
        ])

        let user = UserPath(path: testPath)
        try await user.save(on: self.db)

        let all = try await UserPath.query(on: self.db)
            .filterGeometryDisjoint(polygon, \.$path)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testEquals() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let user = UserArea(area: polygon)
        try await user.save(on: self.db)

        let all = try await UserArea.query(on: self.db)
            .filterGeometryEquals(\.$area, polygon)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testIntersects() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 5, y: 5),
        ])

        let user = UserArea(area: polygon)
        try await user.save(on: self.db)

        let all = try await UserArea.query(on: self.db)
            .filterGeometryIntersects(\.$area, testPath)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testIntersectsReversed() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 5, y: 5),
        ])

        let user = UserPath(path: testPath)
        try await user.save(on: self.db)

        let all = try await UserPath.query(on: self.db)
            .filterGeometryIntersects(polygon, \.$path)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testOverlaps() async throws {
        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 5, y: 5),
            GeometricPoint2D(x: 6, y: 6),
            GeometricPoint2D(x: 0, y: 0),
        ])

        let testPath2 = GeometricLineString2D(points: [
            GeometricPoint2D(x: 16, y: 0),
            GeometricPoint2D(x: 5, y: 5),
            GeometricPoint2D(x: 6, y: 6),
            GeometricPoint2D(x: 2, y: 0),
        ])

        let user = UserPath(path: testPath)
        try await user.save(on: self.db)

        let all = try await UserPath.query(on: self.db)
            .filterGeometryOverlaps(\.$path, testPath2)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testOverlapsReversed() async throws {
        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 5, y: 5),
            GeometricPoint2D(x: 6, y: 6),
            GeometricPoint2D(x: 0, y: 0),
        ])

        let testPath2 = GeometricLineString2D(points: [
            GeometricPoint2D(x: 16, y: 0),
            GeometricPoint2D(x: 5, y: 5),
            GeometricPoint2D(x: 6, y: 6),
            GeometricPoint2D(x: 2, y: 0),
        ])

        let user = UserPath(path: testPath)
        try await user.save(on: self.db)

        let all = try await UserPath.query(on: self.db)
            .filterGeometryOverlaps(testPath2, \.$path)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testTouches() async throws {
        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 1, y: 1),
            GeometricPoint2D(x: 0, y: 2),
        ])

        let testPoint = GeometricPoint2D(x: 0, y: 2)

        let user = UserPath(path: testPath)
        try await user.save(on: self.db)

        let all = try await UserPath.query(on: self.db)
            .filterGeometryTouches(\.$path, testPoint)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testTouchesReversed() async throws {
        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 1, y: 1),
            GeometricPoint2D(x: 0, y: 2),
        ])

        let testPoint = GeometricPoint2D(x: 0, y: 2)

        let user = UserPath(path: testPath)
        try await user.save(on: self.db)

        let all = try await UserPath.query(on: self.db)
            .filterGeometryTouches(testPoint, \.$path)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testWithin() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)
        let hole = GeometricLineString2D(points: [
            GeometricPoint2D(x: 2.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 2.5),
        ])
        let polygon2 = GeometricPolygon2D(exteriorRing: hole)

        let user = UserArea(area: polygon2)
        try await user.save(on: self.db)

        let all = try await UserArea.query(on: self.db)
            .filterGeometryWithin(\.$area, polygon)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testWithinReversed() async throws {
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0),
        ])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)
        let hole = GeometricLineString2D(points: [
            GeometricPoint2D(x: 2.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 2.5),
        ])
        let polygon2 = GeometricPolygon2D(exteriorRing: hole)

        let user = UserArea(area: polygon)
        try await user.save(on: self.db)

        let all = try await UserArea.query(on: self.db)
            .filterGeometryWithin(polygon2, \.$area)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testDistanceWithin() async throws {
        let berlin = GeographicPoint2D(longitude: 13.41053, latitude: 52.52437)

        // 255 km from Berlin
        let hamburg = City(location: GeographicPoint2D(longitude: 10.01534, latitude: 53.57532))
        try await hamburg.save(on: self.db)

        // 505 km from Berlin
        let munich = City(location: GeographicPoint2D(longitude: 11.57549, latitude: 48.13743))
        try await munich.save(on: self.db)

        // 27 km from Berlin
        let potsdam = City(location: GeographicPoint2D(longitude: 13.06566, latitude: 52.39886))
        try await potsdam.save(on: self.db)

        let all = try await City.query(on: self.db)
            .filterGeographyDistanceWithin(\.$location, berlin, 30 * 1000)
            .all()

        XCTAssertEqual(all.map(\.id), [potsdam].map(\.id))
    }

    func testSortByDistance() async throws {
        let berlin = GeographicPoint2D(longitude: 13.41053, latitude: 52.52437)

        // 255 km from Berlin
        let hamburg = City(location: GeographicPoint2D(longitude: 10.01534, latitude: 53.57532))
        try await hamburg.save(on: self.db)

        // 505 km from Berlin
        let munich = City(location: GeographicPoint2D(longitude: 11.57549, latitude: 48.13743))
        try await munich.save(on: self.db)

        // 27 km from Berlin
        let potsdam = City(location: GeographicPoint2D(longitude: 13.06566, latitude: 52.39886))
        try await potsdam.save(on: self.db)

        let all = try await City.query(on: self.db)
            .sortByDistance(between: \.$location, berlin)
            .all()
        XCTAssertEqual(all.map(\.id), [potsdam, hamburg, munich].map(\.id))
    }
}
