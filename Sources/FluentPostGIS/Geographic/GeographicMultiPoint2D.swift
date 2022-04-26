import Foundation
import FluentKit
import WKCodable

public struct GeographicMultiPoint2D: Codable, Equatable, CustomStringConvertible {
    /// The points
    public var points: [GeographicPoint2D]
    
    /// Create a new `GISGeographicLineString2D`
    public init(points: [GeographicPoint2D]) {
        self.points = points
    }
}

extension GeographicMultiPoint2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = MultiPoint
    
    public init(geometry lineString: GeometryType) {
        let points = lineString.points.map { GeographicPoint2D(geometry: $0) }
        self.init(points: points)
    }
    
    public var geometry: GeometryType {
        return .init(points: self.points.map { $0.geometry }, srid: FluentPostGISSrid)
    }
    
    public var baseGeometry: Geometry {
        return self.geometry
    }
}

extension GeographicMultiPoint2D: PostGISDataType {
    public static var dataType: DatabaseSchema.DataType { PostGISDataTypeList.geographicMultiPoint }
}
