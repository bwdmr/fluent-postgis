import FluentSQL
import WKCodable

extension QueryBuilder {
    static func queryExpressionGeometry<T: GeometryConvertible>(_ geometry: T) -> SQLExpression {
        let geometryText = WKTEncoder().encode(geometry.geometry)
        return SQLFunction("ST_GeomFromEWKT", args: [SQLLiteral.string(geometryText)])
    }

    static func queryExpressionGeography<T: GeometryConvertible>(_ geometry: T) -> SQLExpression {
        let geometryText = WKTEncoder().encode(geometry.geometry)
        return SQLFunction("ST_GeogFromText", args: [SQLLiteral.string(geometryText)])
    }

    static func path<M, F>(_ field: KeyPath<M, F>) -> String
    where M: Schema, F: QueryableProperty, F.Model == M {
        return M.path(for: field).map(\.description).joined(separator: "_")
    }
}

extension QueryBuilder {
    func applyFilter(function: String, args: [SQLExpression]) {
        query.filters.append(.custom(SQLFunction(function, args: args)))
    }
    
    func applyFilter(function: String, path: String, value: SQLExpression) {
        applyFilter(function: function, args: [SQLColumn(path), value])
    }
    
    func applyFilter(function: String, value: SQLExpression, path: String) {
        applyFilter(function: function, args: [value, SQLColumn(path)])
    }
}

extension QueryBuilder {
    func applySort(function: String, args: [SQLExpression]) {
        query.sorts.append(.custom(SQLFunction(function, args: args)))
    }
}
