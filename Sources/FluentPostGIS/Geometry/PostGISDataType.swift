import FluentKit
import SQLKit

public protocol PostGISDataType {
    static var dataType: DatabaseSchema.DataType { get }
}

public struct PostGISDataTypeList {
    static var geometricPoint: DatabaseSchema.DataType {
        return .custom(SQLRaw("geometry(Point, \(FluentPostGISSrid))"))
    }

    static var geographicPoint: DatabaseSchema.DataType {
        return .custom(SQLRaw("geography(Point, \(FluentPostGISSrid))"))
    }

    static var geometricLineString: DatabaseSchema.DataType {
        return .custom(SQLRaw("geometry(LineString, \(FluentPostGISSrid))"))
    }

    static var geographicLineString: DatabaseSchema.DataType {
        return .custom(SQLRaw("geography(LineString, \(FluentPostGISSrid))"))
    }

    static var geometricPolygon: DatabaseSchema.DataType {
        return .custom(SQLRaw("geometry(Polygon, \(FluentPostGISSrid))"))
    }

    static var geographicPolygon: DatabaseSchema.DataType {
        return .custom(SQLRaw("geography(Polygon, \(FluentPostGISSrid))"))
    }

    static var geometricMultiPoint: DatabaseSchema.DataType {
        return .custom(SQLRaw("geometry(MultiPoint, \(FluentPostGISSrid))"))
    }

    static var geographicMultiPoint: DatabaseSchema.DataType {
        return .custom(SQLRaw("geography(MultiPoint, \(FluentPostGISSrid))"))
    }

    static var geometricMultiLineString: DatabaseSchema.DataType {
        return .custom(SQLRaw("geometry(MultiLineString, \(FluentPostGISSrid))"))
    }

    static var geographicMultiLineString: DatabaseSchema.DataType {
        return .custom(SQLRaw("geography(MultiLineString, \(FluentPostGISSrid))"))
    }

    static var geometricMultiPolygon: DatabaseSchema.DataType {
        return .custom(SQLRaw("geometry(MultiPolygon, \(FluentPostGISSrid))"))
    }

    static var geographicMultiPolygon: DatabaseSchema.DataType {
        return .custom(SQLRaw("geography(MultiPolygon, \(FluentPostGISSrid))"))
    }

    static var geometricGeometryCollection: DatabaseSchema.DataType {
        return .custom(SQLRaw("geometry(GeometryCollection, \(FluentPostGISSrid))"))
    }

    static var geographicGeometryCollection: DatabaseSchema.DataType {
        return .custom(SQLRaw("geography(GeometryCollection, \(FluentPostGISSrid))"))
    }
}

public extension SchemaBuilder {
    func field(
        _ name: String,
        _ type: PostGISDataType.Type,
        _ constraints: DatabaseSchema.FieldConstraint...
    ) -> Self {
        return self.field(.definition(name: .key(.string(name)),
                                      dataType: type.dataType,
                                      constraints: constraints))
    }
}
