import FluentKit
import WKCodable

public struct GeometricLineString2D: Codable, Equatable, CustomStringConvertible {
    /// The points
    public var points: [GeometricPoint2D]

    /// Create a new `GISGeometricLineString2D`
    public init(points: [GeometricPoint2D]) {
        self.points = points
    }
}

extension GeometricLineString2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = LineString

    public init(geometry lineString: GeometryType) {
        let points = lineString.points.map { GeometricPoint2D(geometry: $0) }
        self.init(points: points)
    }

    public var geometry: GeometryType {
        .init(points: self.points.map(\.geometry), srid: FluentPostGISSrid)
    }

    public var baseGeometry: Geometry {
        self.geometry
    }
}
