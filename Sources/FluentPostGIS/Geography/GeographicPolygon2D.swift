import FluentKit
import WKCodable

public struct GeographicPolygon2D: Codable, Equatable, CustomStringConvertible, Sendable {
    /// The points
    public let exteriorRing: GeographicLineString2D
    public let interiorRings: [GeographicLineString2D]

    public init(exteriorRing: GeographicLineString2D) {
        self.init(exteriorRing: exteriorRing, interiorRings: [])
    }

    /// Create a new `GISGeographicPolygon2D`
    public init(exteriorRing: GeographicLineString2D, interiorRings: [GeographicLineString2D]) {
        self.exteriorRing = exteriorRing
        self.interiorRings = interiorRings
    }
}

extension GeographicPolygon2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = WKCodable.Polygon

    public init(geometry polygon: GeometryType) {
        let exteriorRing = GeographicLineString2D(geometry: polygon.exteriorRing)
        let interiorRings = polygon.interiorRings.map { GeographicLineString2D(geometry: $0) }
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

    public var baseGeometry: any Geometry {
        self.geometry
    }
}
