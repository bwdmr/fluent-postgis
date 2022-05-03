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

    static func path<M, F>(_ field: KeyPath<M, F>) -> SQLExpression
        where M: Schema, F: QueryableProperty, F.Model == M
    {
        let path = M.path(for: field).map(\.description).joined(separator: "_")
        return SQLColumn(path)
    }
}

extension QueryBuilder {
    func filter(function: String, args: [SQLExpression]) -> Self {
        self.filter(.sql(SQLFunction(function, args: args)))
    }

    func sort(function: String, args: [SQLExpression]) -> Self {
        self.sort(.sql(SQLFunction(function, args: args)))
    }
}
