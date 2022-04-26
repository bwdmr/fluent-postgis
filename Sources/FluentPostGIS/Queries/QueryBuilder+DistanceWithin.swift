import FluentSQL
import WKCodable

extension QueryBuilder {
    @discardableResult
    public func filterGeometryDistanceWithin<Field>(
        _ field: KeyPath<Model, Field>,
        _ value: Field.Value,
        _ distance: Double
    ) -> Self where Field: QueryableProperty, Field.Value: GeometryConvertible {
        self.queryFilterDistanceWithin(
            QueryBuilder.path(field),
            QueryBuilder.queryExpressionGeometry(value),
            SQLLiteral.numeric(String(distance))
        )
    }

    @discardableResult
    public func filterGeographyDistanceWithin<Field>(
        _ field: KeyPath<Model, Field>,
        _ value: Field.Value,
        _ distance: Double
    ) -> Self where Field: QueryableProperty, Field.Value: GeometryConvertible {
        self.queryFilterDistanceWithin(
            QueryBuilder.path(field),
            QueryBuilder.queryExpressionGeography(value),
            SQLLiteral.numeric(String(distance))
        )
    }
}

extension QueryBuilder {
    func queryFilterDistanceWithin(_ path: String, _ filter: SQLExpression, _ distance: SQLExpression) -> Self {
        applyFilter(function: "ST_DWithin", args: [SQLColumn(path), filter, distance])
        return self
    }
}
