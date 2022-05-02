import FluentKit
import SQLKit

public protocol PostGISDataType {
    static var dataType: DatabaseSchema.DataType { get }
}

public enum PostGISDataTypeList {
    static var geometricPoint: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(Point, \(FluentPostGISSrid))"))
    }

    static var geographicPoint: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(Point, \(FluentPostGISSrid))"))
    }

    static var geometricLineString: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(LineString, \(FluentPostGISSrid))"))
    }

    static var geographicLineString: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(LineString, \(FluentPostGISSrid))"))
    }

    static var geometricPolygon: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(Polygon, \(FluentPostGISSrid))"))
    }

    static var geographicPolygon: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(Polygon, \(FluentPostGISSrid))"))
    }

    static var geometricMultiPoint: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(MultiPoint, \(FluentPostGISSrid))"))
    }

    static var geographicMultiPoint: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(MultiPoint, \(FluentPostGISSrid))"))
    }

    static var geometricMultiLineString: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(MultiLineString, \(FluentPostGISSrid))"))
    }

    static var geographicMultiLineString: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(MultiLineString, \(FluentPostGISSrid))"))
    }

    static var geometricMultiPolygon: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(MultiPolygon, \(FluentPostGISSrid))"))
    }

    static var geographicMultiPolygon: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(MultiPolygon, \(FluentPostGISSrid))"))
    }

    static var geometricGeometryCollection: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(GeometryCollection, \(FluentPostGISSrid))"))
    }

    static var geographicGeometryCollection: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(GeometryCollection, \(FluentPostGISSrid))"))
    }
}

extension SchemaBuilder {
    public func field(
        _ name: String,
        _ type: PostGISDataType.Type,
        _ constraints: DatabaseSchema.FieldConstraint...
    ) -> Self {
        self.field(.definition(
            name: .key(.string(name)),
            dataType: type.dataType,
            constraints: constraints
        ))
    }
}

extension DatabaseSchema.DataType {
    public static var geometricPoint: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(Point, \(FluentPostGISSrid))"))
    }

    public static var geographicPoint: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(Point, \(FluentPostGISSrid))"))
    }

    public static var geometricLineString: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(LineString, \(FluentPostGISSrid))"))
    }

    public static var geographicLineString: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(LineString, \(FluentPostGISSrid))"))
    }

    public static var geometricPolygon: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(Polygon, \(FluentPostGISSrid))"))
    }

    public static var geographicPolygon: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(Polygon, \(FluentPostGISSrid))"))
    }

    public static var geometricMultiPoint: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(MultiPoint, \(FluentPostGISSrid))"))
    }

    public static var geographicMultiPoint: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(MultiPoint, \(FluentPostGISSrid))"))
    }

    public static var geometricMultiLineString: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(MultiLineString, \(FluentPostGISSrid))"))
    }

    public static var geographicMultiLineString: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(MultiLineString, \(FluentPostGISSrid))"))
    }

    public static var geometricMultiPolygon: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(MultiPolygon, \(FluentPostGISSrid))"))
    }

    public static var geographicMultiPolygon: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(MultiPolygon, \(FluentPostGISSrid))"))
    }

    public static var geometricGeometryCollection: DatabaseSchema.DataType {
        .custom(SQLRaw("geometry(GeometryCollection, \(FluentPostGISSrid))"))
    }

    public static var geographicGeometryCollection: DatabaseSchema.DataType {
        .custom(SQLRaw("geography(GeometryCollection, \(FluentPostGISSrid))"))
    }
}
