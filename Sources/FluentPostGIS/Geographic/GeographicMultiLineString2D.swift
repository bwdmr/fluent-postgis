import Foundation
import FluentKit
import WKCodable

public struct GeographicMultiLineString2D: Codable, Equatable, CustomStringConvertible {
    /// The points
    public let lineStrings: [GeographicLineString2D]
    
    /// Create a new `GISGeographicMultiLineString2D`
    public init(lineStrings: [GeographicLineString2D]) {
        self.lineStrings = lineStrings
    }
}

extension GeographicMultiLineString2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = MultiLineString
    
    public init(geometry polygon: GeometryType) {
        let lineStrings = polygon.lineStrings.map { GeographicLineString2D(geometry: $0) }
        self.init(lineStrings: lineStrings)
    }
    
    public var geometry: GeometryType {
        let lineStrings = self.lineStrings.map { $0.geometry }
        return .init(lineStrings: lineStrings, srid: FluentPostGISSrid)
    }
    
    public var baseGeometry: Geometry {
        return self.geometry
    }
}

extension GeographicMultiLineString2D: PostGISDataType {
    public static var dataType: DatabaseSchema.DataType { PostGISDataTypeList.geographicMultiLineString }
}
