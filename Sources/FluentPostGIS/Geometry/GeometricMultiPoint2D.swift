import FluentKit
import WKCodable

public struct GeometricMultiPoint2D: Codable, Equatable, CustomStringConvertible {
    /// The points
    public var points: [GeometricPoint2D]

    /// Create a new `GISGeometricLineString2D`
    public init(points: [GeometricPoint2D]) {
        self.points = points
    }
}

extension GeometricMultiPoint2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = MultiPoint

    public init(geometry lineString: GeometryType) {
        let points = lineString.points.map { GeometricPoint2D(geometry: $0) }
        self.init(points: points)
    }

    public var geometry: GeometryType {
        MultiPoint(points: self.points.map(\.geometry), srid: FluentPostGISSrid)
    }

    public var baseGeometry: Geometry {
        self.geometry
    }
}

extension GeometricMultiPoint2D: PostGISDataType {
    public static var dataType: DatabaseSchema.DataType { PostGISDataTypeList.geometricMultiPoint }
}
