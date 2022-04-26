import FluentSQL
import WKCodable


extension QueryBuilder {
    @discardableResult
    public func filterGeometryDistanceWithin<F,V>(_ field: KeyPath<Model, F>, _ filter: V, _ value: Double) -> Self
        where F: QueryableProperty, V: GeometryConvertible
    {
        return queryFilterGeometryDistanceWithin(QueryBuilder.path(field),
                                                 QueryBuilder.queryExpressionGeometry(filter),
                                                 SQLLiteral.numeric(String(value)))
    }

    @discardableResult
    public func filterGeometryDistanceWithin<T>(_ key: KeyPath<Result, T>, _ filter: Database.QueryFilterValue, _ value: Double) -> Self
        where T: GeometryConvertible
    {
        return filterGeometryDistanceWithin(Database.queryField(.keyPath(key)), filter, Database.queryFilterValue([value]))
    }

    @discardableResult
    public func filterGeometryDistanceWithin<A, T>(_ key: KeyPath<A, T>, _ filter: Database.QueryFilterValue, _ value: Double) -> Self
        where T: GeometryConvertible
    {
        return filterGeometryDistanceWithin(Database.queryField(.keyPath(key)), filter, Database.queryFilterValue([value]))
    }

    @discardableResult
    public func filterGeometryDistanceWithin(_ field: Database.QueryField, _ filter: Database.QueryFilterValue, _ value: Double) -> Self
    {
        return filterGeometryDistanceWithin(field, filter, Database.queryFilterValue([value]))
    }

    @discardableResult
    private func filterGeometryDistanceWithin(_ field: Database.QueryField, _ filter: Database.QueryFilterValue, _ value: Database.QueryFilterValue) -> Self {
        return self.filter(custom: Database.queryFilterGeometryDistanceWithin(field, filter, value))
    }

    @discardableResult
    public func filterGeographyDistanceWithin<T,V>(_ key: KeyPath<Result, T>, _ filter: V, _ value: Double) -> Self
        where T: GeometryConvertible, V: GeometryConvertible
    {
        return filterGeographyDistanceWithin(Database.queryField(.keyPath(key)), Database.queryFilterValueGeographic(filter),  Database.queryFilterValue([value]))
    }

    @discardableResult
    public func filterGeographyDistanceWithin<T,V, OtherResult>(_ key: KeyPath<Result, T>, _ filter: V, _ valueKey: KeyPath<OtherResult, Double>) -> Self
        where T: GeometryConvertible, V: GeometryConvertible, OtherResult: Model, OtherResult.Database == Database
    {
        return filterGeographyDistanceWithin(Database.queryField(.keyPath(key)), Database.queryFilterValueGeographic(filter),  Database.queryField(.keyPath(valueKey)))
    }

    @discardableResult
    private func filterGeographyDistanceWithin(_ field: Database.QueryField, _ filter: Database.QueryFilterValue, _ value: Database.QueryFilterValue) -> Self {
        return self.filter(custom: Database.filterGeographyDistanceWithin(field, filter, value))
    }

    @discardableResult
    private func filterGeographyDistanceWithin(_ field: Database.QueryField, _ filter: Database.QueryFilterValue, _ value: Database.QueryField) -> Self {
        return self.filter(custom: Database.filterGeographyDistanceWithin(field, filter, value))
    }

}

extension QueryBuilder {
    func queryFilterGeometryDistanceWithin(_ path: String, _ filter: SQLExpression, _ value: SQLExpression) -> Self {
        applyFilter(function: "ST_DWithin", args: [SQLColumn(path), filter, value])
        return self
    }
}

extension QuerySupporting where QueryFilterValue: SQLExpression {
    public static func queryFilterValueGeographic<T: GeometryConvertible>(_ geometry: T) -> QueryFilterValue {
        let geometryText = WKTEncoder().encode(geometry.geometry)
        return .function("ST_GeogFromText", [.expression(.literal(.string(geometryText)))])
    }
}

extension QuerySupporting where
    QueryFilter: SQLExpression,
    QueryField == QueryFilter.ColumnIdentifier,
    QueryFilterMethod == QueryFilter.BinaryOperator,
    QueryFilterValue == QueryFilter
{
    public static func filterGeographyDistanceWithin(_ field: QueryField, _ filter: QueryFilterValue, _ value: QueryFilterValue) -> QueryFilter {
        let args: [QueryFilter.Function.Argument] = [
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(PostgreSQLExpression.column(field as! PostgreSQLColumnIdentifier)),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(filter as! PostgreSQLExpression),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(value as! PostgreSQLExpression),
            ] as! [QueryFilter.Function.Argument]
        return .function("ST_DWithin", args)
    }

    public static func filterGeographyDistanceWithin(_ field: QueryField, _ filter: QueryFilterValue, _ valueField: QueryField) -> QueryFilter {
        let args: [QueryFilter.Function.Argument] = [
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(PostgreSQLExpression.column(field as! PostgreSQLColumnIdentifier)),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(filter as! PostgreSQLExpression),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(PostgreSQLExpression.column(valueField as! PostgreSQLColumnIdentifier)),
            ] as! [QueryFilter.Function.Argument]
        return .function("ST_DWithin", args)
    }
}
