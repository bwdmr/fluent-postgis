import FluentKit
import GEOSwift

public struct GeometricPolygon2D: Codable, Equatable, CustomStringConvertible {
    /// The points
    public let exteriorRing: GeometricLineString2D
    public let interiorRings: [GeometricLineString2D]

    public init(exteriorRing: GeometricLineString2D) {
        self.init(exteriorRing: exteriorRing, interiorRings: [])
    }

    /// Create a new `GISGeometricPolygon2D`
    public init(exteriorRing: GeometricLineString2D, interiorRings: [GeometricLineString2D]) {
        self.exteriorRing = exteriorRing
        self.interiorRings = interiorRings
    }
}

extension GeometricPolygon2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = WKCodable.Polygon

    public init(geometry polygon: GeometryType) {
        let exteriorRing = GeometricLineString2D(geometry: polygon.exteriorRing)
        let interiorRings = polygon.interiorRings.map { GeometricLineString2D(geometry: $0) }
        self.init(exteriorRing: exteriorRing, interiorRings: interiorRings)
    }

    public var geometry: GeometryType {
        let exteriorRing = exteriorRing.geometry
        let interiorRings = interiorRings.map(\.geometry)
        return .init(
            exteriorRing: exteriorRing,
            interiorRings: interiorRings,
            srid: FluentPostGISSrid
        )
    }

    public var baseGeometry: Geometry {
        self.geometry
    }
}
