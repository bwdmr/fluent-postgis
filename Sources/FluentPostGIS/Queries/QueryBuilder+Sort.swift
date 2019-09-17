import FluentPostgreSQL

extension QueryBuilder where
    Database: QuerySupporting,
    Database.QuerySort: SQLOrderBy,
    Database.QueryFilter: SQLExpression,
    Database.QueryFilterValue == Database.QueryFilter
{
    @discardableResult
    public func sortByDistance<T,V>(between key: KeyPath<Result, T>, _ filter: V) -> Self
    where T: GeometryConvertible, V: GeometryConvertible {
        return self.sort(Database.distanceSort(between: Database.queryField(.keyPath(key)), Database.queryFilterValueGeographic(filter)))
    }

}

extension QuerySupporting where
    QuerySort: SQLOrderBy
{
    public static func distanceSort(between field: QueryField, _ filter: QueryFilterValue) -> QuerySort {
        let args: [QuerySort.Expression.Function.Argument] = [
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(PostgreSQLExpression.column(field as! PostgreSQLColumnIdentifier)),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(filter as! PostgreSQLExpression),
            ] as! [QuerySort.Expression.Function.Argument]
        return .orderBy(.function("ST Distance", args), .ascending)
    }
}


