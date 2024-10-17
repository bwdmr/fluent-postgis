import FluentSQL
import GEOSwift

extension QueryBuilder {
    @discardableResult
    public func filterGeometryDistanceWithin<Field>(
        _ field: KeyPath<Model, Field>,
        _ value: Field.Value,
        _ distance: Double
    ) -> Self where Field: QueryableProperty, Field.Model == Model,
        Field.Value: GeometryConvertible
    {
        self.filterDistanceWithin(
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
    ) -> Self where Field: QueryableProperty, Field.Model == Model,
        Field.Value: GeometryConvertible
    {
        self.filterDistanceWithin(
            QueryBuilder.path(field),
            QueryBuilder.queryExpressionGeography(value),
            SQLLiteral.numeric(String(distance))
        )
    }

    @discardableResult
    public func filterGeographyDistanceWithin<Field, OtherModel, OtherField>(
        _ field: KeyPath<Model, Field>,
        _ value: Field.Value,
        _ distance: KeyPath<OtherModel, OtherField>
    ) -> Self
        where Field: QueryableProperty,
        Field.Model == Model,
        Field.Value: GeometryConvertible,
        OtherModel: Schema,
        OtherField: QueryableProperty,
        OtherField.Model == OtherModel,
        OtherField.Value == Double
    {
        self.filterDistanceWithin(
            QueryBuilder.path(field),
            QueryBuilder.queryExpressionGeography(value),
            SQLColumn(QueryBuilder.path(distance))
        )
    }
}

extension QueryBuilder {
    func filterDistanceWithin(_ args: SQLExpression...) -> Self {
        self.filter(function: "ST_DWithin", args: args)
    }
}
