import FluentKit
import WKCodable

public struct GeometricMultiPolygon2D: Codable, Equatable, CustomStringConvertible {
    /// The points
    public let polygons: [GeometricPolygon2D]

    /// Create a new `GISGeometricMultiPolygon2D`
    public init(polygons: [GeometricPolygon2D]) {
        self.polygons = polygons
    }
}

extension GeometricMultiPolygon2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = MultiPolygon

    public init(geometry polygon: GeometryType) {
        let polygons = polygon.polygons.map { GeometricPolygon2D(geometry: $0) }
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

extension GeometricMultiPolygon2D: PostGISDataType {
    public static var dataType: DatabaseSchema
        .DataType { PostGISDataTypeList.geometricMultiLineString }
}
