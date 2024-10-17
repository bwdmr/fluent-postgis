import FluentKit
import GEOSwift

public struct GeographicMultiPolygon2D: Codable, Equatable, CustomStringConvertible {
    /// The points
    public let polygons: [GeographicPolygon2D]

    /// Create a new `GISGeographicMultiPolygon2D`
    public init(polygons: [GeographicPolygon2D]) {
        self.polygons = polygons
    }
}

extension GeographicMultiPolygon2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = MultiPolygon

    public init(geometry polygon: GeometryType) {
        let polygons = polygon.polygons.map { GeographicPolygon2D(geometry: $0) }
        self.init(polygons: polygons)
    }

    public var geometry: GeometryType {
        let polygons = polygons.map(\.geometry)
        return .init(polygons: polygons, srid: FluentPostGISSrid)
    }

    public var baseGeometry: Geometry {
        self.geometry
    }
}
