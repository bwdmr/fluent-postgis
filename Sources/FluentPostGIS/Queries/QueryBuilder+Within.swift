import FluentSQL
import WKCodable

extension QueryBuilder {
    /// Applies an ST_Within filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filterGeometryWithin(\.area, path)
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - value: Geometry value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filterGeometryWithin<F, V>(_ field: KeyPath<Model, F>, _ value: V) -> Self
        where F: QueryableProperty, F.Model == Model, V: GeometryConvertible
    {
        self.filterGeometryWithin(
            QueryBuilder.path(field),
            QueryBuilder.queryExpressionGeometry(value)
        )
    }

    /// Applies an ST_Within filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filterGeometryWithin(area, \.path)
    ///         .all()
    ///
    /// - parameters:
    ///     - value: Geometry value to filter by.
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filterGeometryWithin<F, V>(_ value: V, _ field: KeyPath<Model, F>) -> Self
        where F: QueryableProperty, F.Model == Model, V: GeometryConvertible
    {
        self.filterGeometryWithin(
            QueryBuilder.queryExpressionGeometry(value),
            QueryBuilder.path(field)
        )
    }
}

extension QueryBuilder {
    /// Applies an ST_Within filter to a joined model's field.
    @discardableResult
    public func filterGeometryWithin<Joined, F, V>(
        _ joined: Joined.Type,
        _ field: KeyPath<Joined, F>,
        _ value: V
    ) -> Self
        where Joined: Schema, F: QueryableProperty, F.Model == Joined, V: GeometryConvertible
    {
        self.filterGeometryWithin(
            QueryBuilder.path(field),
            QueryBuilder.queryExpressionGeometry(value)
        )
    }

    /// Applies a reversed ST_Within filter to a joined model's field.
    @discardableResult
    public func filterGeometryWithin<Joined, F, V>(
        _ joined: Joined.Type,
        _ value: V,
        _ field: KeyPath<Joined, F>
    ) -> Self
        where Joined: Schema, F: QueryableProperty, F.Model == Joined, V: GeometryConvertible
    {
        self.filterGeometryWithin(
            QueryBuilder.queryExpressionGeometry(value),
            QueryBuilder.path(field)
        )
    }
}

extension QueryBuilder {
    /// Creates an instance of `QueryFilter` for ST_Within from a field and value.
    ///
    /// - parameters:
    ///     - field: Field to filter.
    ///     - value: Value type.
    public func filterGeometryWithin(_ args: any SQLExpression...) -> Self {
        self.filter(function: "ST_Within", args: args)
    }
}
