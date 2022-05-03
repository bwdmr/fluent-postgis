import FluentKit
import SQLKit

extension DatabaseSchema.DataType {
    public static var geographicPoint2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(Point, \(FluentPostGISSrid))"))
    }

    public static var geographicLineString2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(LineString, \(FluentPostGISSrid))"))
    }

    public static var geographicPolygon2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(Polygon, \(FluentPostGISSrid))"))
    }

    public static var geographicMultiPoint2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(MultiPoint, \(FluentPostGISSrid))"))
    }

    public static var geographicMultiLineString2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(MultiLineString, \(FluentPostGISSrid))"))
    }

    public static var geographicMultiPolygon2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(MultiPolygon, \(FluentPostGISSrid))"))
    }

    public static var geographicGeometryCollection2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(GeometryCollection, \(FluentPostGISSrid))"))
    }
}
