import FluentKit
import WKCodable

public struct GeographicGeometryCollection2D: Codable, Equatable, CustomStringConvertible, Sendable {
    /// The points
    public let geometries: [any GeometryCollectable]

    /// Create a new `GISGeographicGeometryCollection2D`
    public init(geometries: [any GeometryCollectable]) {
        self.geometries = geometries
    }
}

extension GeographicGeometryCollection2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = GeometryCollection

    public init(geometry: GeometryCollection) {
        self.geometries = geometry.geometries.map {
            if let value = $0 as? Point {
                return GeographicPoint2D(geometry: value)
            } else if let value = $0 as? LineString {
                return GeographicLineString2D(geometry: value)
            } else if let value = $0 as? WKCodable.Polygon {
                return GeographicPolygon2D(geometry: value)
            } else if let value = $0 as? MultiPoint {
                return GeographicMultiPoint2D(geometry: value)
            } else if let value = $0 as? MultiLineString {
                return GeographicMultiLineString2D(geometry: value)
            } else if let value = $0 as? MultiPolygon {
                return GeographicMultiPolygon2D(geometry: value)
            } else if let value = $0 as? GeometryCollection {
                return GeographicGeometryCollection2D(geometry: value)
            } else {
                assertionFailure()
                return GeographicPoint2D(longitude: 0, latitude: 0)
            }
        }
    }

    public var geometry: GeometryCollection {
        let geometries = geometries.map(\.baseGeometry)
        return .init(geometries: geometries, srid: FluentPostGISSrid)
    }

    public var baseGeometry: any Geometry {
        self.geometry
    }

    public init(from decoder: any Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        let wkbGeometry: GeometryCollection = try WKTDecoder().decode(from: value)
        self.init(geometry: wkbGeometry)
    }

    public func encode(to encoder: any Encoder) throws {
        let wktEncoder = WKTEncoder()
        let value = wktEncoder.encode(self.geometry)
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }

    public static func == (
        lhs: GeographicGeometryCollection2D,
        rhs: GeographicGeometryCollection2D
    ) -> Bool {
        guard lhs.geometries.count == rhs.geometries.count else {
            return false
        }
        for i in 0 ..< lhs.geometries.count {
            guard lhs.geometries[i].isEqual(to: rhs.geometries[i]) else {
                return false
            }
        }
        return true
    }
}
