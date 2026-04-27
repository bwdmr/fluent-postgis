import FluentSQL
import WKCodable

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
    /// Applies an ST_DWithin geometry filter to a joined model's field.
    @discardableResult
    public func filterGeometryDistanceWithin<Joined, Field>(
        _ joined: Joined.Type,
        _ field: KeyPath<Joined, Field>,
        _ value: Field.Value,
        _ distance: Double
    ) -> Self where Joined: Schema, Field: QueryableProperty, Field.Model == Joined,
        Field.Value: GeometryConvertible
    {
        self.filterDistanceWithin(
            QueryBuilder.path(field),
            QueryBuilder.queryExpressionGeometry(value),
            SQLLiteral.numeric(String(distance))
        )
    }

    /// Applies an ST_DWithin geography filter to a joined model's field.
    @discardableResult
    public func filterGeographyDistanceWithin<Joined, Field>(
        _ joined: Joined.Type,
        _ field: KeyPath<Joined, Field>,
        _ value: Field.Value,
        _ distance: Double
    ) -> Self where Joined: Schema, Field: QueryableProperty, Field.Model == Joined,
        Field.Value: GeometryConvertible
    {
        self.filterDistanceWithin(
            QueryBuilder.path(field),
            QueryBuilder.queryExpressionGeography(value),
            SQLLiteral.numeric(String(distance))
        )
    }

    /// Applies an ST_DWithin geography filter to a joined model's field with a distance from another joined model.
    @discardableResult
    public func filterGeographyDistanceWithin<Joined, Field, OtherModel, OtherField>(
        _ joined: Joined.Type,
        _ field: KeyPath<Joined, Field>,
        _ value: Field.Value,
        _ distance: KeyPath<OtherModel, OtherField>
    ) -> Self
        where Joined: Schema,
        Field: QueryableProperty,
        Field.Model == Joined,
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
    func filterDistanceWithin(_ args: any SQLExpression...) -> Self {
        self.filter(function: "ST_DWithin", args: args)
    }
}
