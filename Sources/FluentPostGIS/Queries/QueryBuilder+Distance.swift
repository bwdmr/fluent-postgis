import FluentSQL
import WKCodable

extension QueryBuilder {
    @discardableResult
    public func filterGeometryDistance<F, V>(
        _ field: KeyPath<Model, F>,
        _ filter: V,
        _ method: SQLBinaryOperator,
        _ value: Double
    ) -> Self
        where F: QueryableProperty, F.Model == Model, V: GeometryConvertible
    {
        self.filterGeometryDistance(
            QueryBuilder.path(field),
            QueryBuilder.queryExpressionGeometry(filter),
            method,
            SQLLiteral.numeric(String(value))
        )
    }
}

extension QueryBuilder {
    public func filterGeometryDistance(
        _ path: any SQLExpression,
        _ filter: any SQLExpression,
        _ method: SQLBinaryOperator,
        _ value: any SQLExpression
    ) -> Self {
        self.filter(.sql(SQLFunction("ST_Distance", args: [path, filter]), method, value))
    }
}
