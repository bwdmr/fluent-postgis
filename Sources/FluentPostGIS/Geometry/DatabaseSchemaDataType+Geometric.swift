import FluentKit
import SQLKit

extension DatabaseSchema.DataType {
    public static var geometricPoint2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(Point, \(FluentPostGISSrid))"))
    }

    public static var geometricLineString2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(LineString, \(FluentPostGISSrid))"))
    }

    public static var geometricPolygon2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(Polygon, \(FluentPostGISSrid))"))
    }

    public static var geometricMultiPoint2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(MultiPoint, \(FluentPostGISSrid))"))
    }

    public static var geometricMultiLineString2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(MultiLineString, \(FluentPostGISSrid))"))
    }

    public static var geometricMultiPolygon2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(MultiPolygon, \(FluentPostGISSrid))"))
    }

    public static var geometricGeometryCollection2D: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(GeometryCollection, \(FluentPostGISSrid))"))
    }
}
