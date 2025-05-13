import FluentSQL
import WKCodable

extension QueryBuilder {
    /// Applies an ST_Touches filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filterGeometryTouches(\.area, path)
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - value: Geometry value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filterGeometryTouches<F, V>(_ field: KeyPath<Model, F>, _ value: V) -> Self
        where F: QueryableProperty, F.Model == Model, V: GeometryConvertible
    {
        self.filterGeometryTouches(
            QueryBuilder.path(field),
            QueryBuilder.queryExpressionGeometry(value)
        )
    }

    /// Applies an ST_Touches filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filterGeometryTouches(area, \.path)
    ///         .all()
    ///
    /// - parameters:
    ///     - value: Geometry value to filter by.
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filterGeometryTouches<F, V>(_ value: V, _ field: KeyPath<Model, F>) -> Self
        where F: QueryableProperty, F.Model == Model, V: GeometryConvertible
    {
        self.filterGeometryTouches(
            QueryBuilder.queryExpressionGeometry(value),
            QueryBuilder.path(field)
        )
    }
}

extension QueryBuilder {
    /// Creates an instance of `QueryFilter` for ST_Touches from a field and value.
    ///
    /// - parameters:
    ///     - field: Field to filter.
    ///     - value: Value type.
    public func filterGeometryTouches(_ args: any SQLExpression...) -> Self {
        self.filter(function: "ST_Touches", args: args)
    }
}
