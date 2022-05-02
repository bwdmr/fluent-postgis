import XCTest
@testable import FluentPostGIS

final class QueryTests: FluentPostGISTests {
    func testContains() throws {
        try UserAreaMigration().prepare(on: conn).wait()
        defer { try! UserAreaMigration().revert(on: conn).wait() }
        
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)
        
        let user = UserArea()
        user.area = polygon
        _ = try user.save(on: conn).wait()
        
        let testPoint = GeometricPoint2D(x: 5, y: 5)
        let all = try UserArea.query(on: conn).filterGeometryContains(\.$area, testPoint).all().wait()
        XCTAssertEqual(all.count, 1)
    }
    
    func testContainsReversed() throws {
        try UserLocationMigration().prepare(on: conn).wait()
        defer { try! UserLocationMigration().revert(on: conn).wait() }

        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPoint = GeometricPoint2D(x: 5, y: 5)
        let user = UserLocation()
        user.location = testPoint
        _ = try user.save(on: conn).wait()

        let all = try UserLocation.query(on: conn).filterGeometryContains(polygon, \.$location).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testContainsWithHole() throws {
        try UserAreaMigration().prepare(on: conn).wait()
        defer { try! UserAreaMigration().revert(on: conn).wait() }

        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let hole = GeometricLineString2D(points: [
            GeometricPoint2D(x: 2.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 2.5)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing, interiorRings: [hole])

        let user = UserArea()
        user.area = polygon
        _ = try user.save(on: conn).wait()

        let testPoint = GeometricPoint2D(x: 5, y: 5)
        let all = try UserArea.query(on: conn).filterGeometryContains(\.$area, testPoint).all().wait()
        XCTAssertEqual(all.count, 0)

        let testPoint2 = GeometricPoint2D(x: 1, y: 5)
        let all2 = try UserArea.query(on: conn).filterGeometryContains(\.$area, testPoint2).all().wait()
        XCTAssertEqual(all2.count, 1)
    }

    func testCrosses() throws {
        try UserAreaMigration().prepare(on: conn).wait()
        defer { try! UserAreaMigration().revert(on: conn).wait() }

        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 5, y: 5)
            ])

        let user = UserArea()
        user.area = polygon
        _ = try user.save(on: conn).wait()

        let all = try UserArea.query(on: conn).filterGeometryCrosses(\.$area, testPath).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testCrossesReversed() throws {
        try UserPathMigration().prepare(on: conn).wait()
        defer { try! UserPathMigration().revert(on: conn).wait() }

        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 5, y: 5)
            ])

        let user = UserPath()
        user.path = testPath
        _ = try user.save(on: conn).wait()

        let all = try UserPath.query(on: conn).filterGeometryCrosses(polygon, \.$path).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testDisjoint() throws {
        try UserAreaMigration().prepare(on: conn).wait()
        defer { try! UserAreaMigration().revert(on: conn).wait() }

        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 11, y: 5)
            ])

        let user = UserArea()
        user.area = polygon
        _ = try user.save(on: conn).wait()

        let all = try UserArea.query(on: conn).filterGeometryDisjoint(\.$area, testPath).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testDisjointReversed() throws {
        try UserPathMigration().prepare(on: conn).wait()
        defer { try! UserPathMigration().revert(on: conn).wait() }

        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 11, y: 5)
            ])

        let user = UserPath()
        user.path = testPath
        _ = try user.save(on: conn).wait()

        let all = try UserPath.query(on: conn).filterGeometryDisjoint(polygon, \.$path).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testEquals() throws {
        try UserAreaMigration().prepare(on: conn).wait()
        defer { try! UserAreaMigration().revert(on: conn).wait() }
        
        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let user = UserArea()
        user.area = polygon
        _ = try user.save(on: conn).wait()

        let all = try UserArea.query(on: conn).filterGeometryEquals(\.$area, polygon).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testIntersects() throws {
        try UserAreaMigration().prepare(on: conn).wait()
        defer { try! UserAreaMigration().revert(on: conn).wait() }

        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 5, y: 5)
            ])

        let user = UserArea()
        user.area = polygon
        _ = try user.save(on: conn).wait()

        let all = try UserArea.query(on: conn).filterGeometryIntersects(\.$area, testPath).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testIntersectsReversed() throws {
        try UserPathMigration().prepare(on: conn).wait()
        defer { try! UserPathMigration().revert(on: conn).wait() }

        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 15, y: 0),
            GeometricPoint2D(x: 5, y: 5)
            ])

        let user = UserPath()
        user.path = testPath
        _ = try user.save(on: conn).wait()

        let all = try UserPath.query(on: conn).filterGeometryIntersects(polygon, \.$path).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testOverlaps() throws {
        try UserPathMigration().prepare(on: conn).wait()
        defer { try! UserPathMigration().revert(on: conn).wait() }

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

        let user = UserPath()
        user.path = testPath
        _ = try user.save(on: conn).wait()

        let all = try UserPath.query(on: conn).filterGeometryOverlaps(\.$path, testPath2).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testOverlapsReversed() throws {
        try UserPathMigration().prepare(on: conn).wait()
        defer { try! UserPathMigration().revert(on: conn).wait() }

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

        let user = UserPath()
        user.path = testPath
        _ = try user.save(on: conn).wait()

        let all = try UserPath.query(on: conn).filterGeometryOverlaps(testPath2, \.$path).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testTouches() throws {
        try UserPathMigration().prepare(on: conn).wait()
        defer { try! UserPathMigration().revert(on: conn).wait() }

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 1, y: 1),
            GeometricPoint2D(x: 0, y: 2)
            ])

        let testPoint = GeometricPoint2D(x: 0, y: 2)

        let user = UserPath()
        user.path = testPath
        _ = try user.save(on: conn).wait()

        let all = try UserPath.query(on: conn).filterGeometryTouches(\.$path, testPoint).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testTouchesReversed() throws {
        try UserPathMigration().prepare(on: conn).wait()
        defer { try! UserPathMigration().revert(on: conn).wait() }

        let testPath = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 1, y: 1),
            GeometricPoint2D(x: 0, y: 2)
            ])

        let testPoint = GeometricPoint2D(x: 0, y: 2)

        let user = UserPath()
        user.path = testPath
        _ = try user.save(on: conn).wait()

        let all = try UserPath.query(on: conn).filterGeometryTouches(testPoint, \.$path).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testWithin() throws {
        try UserAreaMigration().prepare(on: conn).wait()
        defer { try! UserAreaMigration().revert(on: conn).wait() }

        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)
        let hole = GeometricLineString2D(points: [
            GeometricPoint2D(x: 2.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 2.5)])
        let polygon2 = GeometricPolygon2D(exteriorRing: hole)

        let user = UserArea()
        user.area = polygon2
        _ = try user.save(on: conn).wait()

        let all = try UserArea.query(on: conn).filterGeometryWithin(\.$area, polygon).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testWithinReversed() throws {
        try UserAreaMigration().prepare(on: conn).wait()
        defer { try! UserAreaMigration().revert(on: conn).wait() }

        let exteriorRing = GeometricLineString2D(points: [
            GeometricPoint2D(x: 0, y: 0),
            GeometricPoint2D(x: 10, y: 0),
            GeometricPoint2D(x: 10, y: 10),
            GeometricPoint2D(x: 0, y: 10),
            GeometricPoint2D(x: 0, y: 0)])
        let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)
        let hole = GeometricLineString2D(points: [
            GeometricPoint2D(x: 2.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 2.5),
            GeometricPoint2D(x: 7.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 7.5),
            GeometricPoint2D(x: 2.5, y: 2.5)])
        let polygon2 = GeometricPolygon2D(exteriorRing: hole)

        let user = UserArea()
        user.area = polygon
        _ = try user.save(on: conn).wait()

        let all = try UserArea.query(on: conn).filterGeometryWithin(polygon2, \.$area).all().wait()
        XCTAssertEqual(all.count, 1)
    }

    func testDistanceWithin() throws {
        try CityLocationMigration().prepare(on: conn).wait()
        defer { try! CityLocationMigration().revert(on: conn).wait() }

        let berlin = GeographicPoint2D(longitude: 13.41053, latitude: 52.52437)

        // 255 km from Berlin
        let hamburg = CityLocation()
        hamburg.location = GeographicPoint2D(longitude: 10.01534, latitude: 53.57532)
        try hamburg.save(on: conn).wait()

        // 505 km from Berlin
        let munich = CityLocation()
        munich.location = GeographicPoint2D(longitude: 11.57549, latitude: 48.13743)
        try munich.save(on: conn).wait()

        // 27 km from Berlin
        let potsdam = CityLocation()
        potsdam.location = GeographicPoint2D(longitude: 13.06566, latitude: 52.39886)
        try potsdam.save(on: conn).wait()

        let all = try CityLocation.query(on: conn)
            .filterGeographyDistanceWithin(\.$location, berlin, 30 * 1_000)
            .all()
            .wait()

        XCTAssertEqual(all.map(\.id), [potsdam].map(\.id))
    }

    func testSortByDistance() throws {
        try CityLocationMigration().prepare(on: conn).wait()
        defer { try! CityLocationMigration().revert(on: conn).wait() }

        let berlin = GeographicPoint2D(longitude: 13.41053, latitude: 52.52437)

        // 255 km from Berlin
        let hamburg = CityLocation()
        hamburg.location = GeographicPoint2D(longitude: 10.01534, latitude: 53.57532)
        try hamburg.save(on: conn).wait()

        // 505 km from Berlin
        let munich = CityLocation()
        munich.location = GeographicPoint2D(longitude: 11.57549, latitude: 48.13743)
        try munich.save(on: conn).wait()

        // 27 km from Berlin
        let potsdam = CityLocation()
        potsdam.location = GeographicPoint2D(longitude: 13.06566, latitude: 52.39886)
        try potsdam.save(on: conn).wait()

        let all = try CityLocation.query(on: conn)
            .sortByDistance(between: \.$location, berlin)
            .all()
            .wait()
        XCTAssertEqual(all.map(\.id), [potsdam, hamburg, munich].map(\.id))
    }
}
