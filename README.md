# FluentPostGIS

![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20OS%20X-blue.svg)
![Package Managers](https://img.shields.io/badge/package%20managers-SwiftPM-yellow.svg)

PostGIS support for [fluent-postgres-driver](https://github.com/vapor/fluent-postgres-driver) and [Vapor 4](https://github.com/vapor/vapor)

# Installation

## Swift Package Manager

```swift
.package(url: "https://github.com/rabc/fluent-postgis.git", .branch("vapor_4"))
```
# Setup
Import module
```swift
import FluentPostGIS
```

Optionally, you can add a `Migration` to enable PostGIS:
```swift
app.migrations.add(EnablePostGISMigration())

```

# Models
Add a type to your model
```swift
final class UserLocation: Model {
    static let schema = "user_location"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    @Field(key: "location")
    var location: GeometricPoint2D
}
```

Then use its data type in the `Migration`:

```swift
struct UserLocationMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserLocation.schema)
            .field("id", .int, .identifier(auto: true))
            .field("location", GeometricPoint2D.dataType)
            .create()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserLocation.schema).delete()
    }
}
```

| Geometric Types | Geographic Types  |
|---|---|
|GeometricPoint2D|GeographicPoint2D|
|GeometricLineString2D|GeographicLineString2D|
|GeometricPolygon2D|GeographicPolygon2D|
|GeometricMultiPoint2D|GeographicMultiPoint2D|
|GeometricMultiLineString2D|GeographicMultiLineString2D|
|GeometricMultiPolygon2D|GeographicMultiPolygon2D|
|GeometricGeometryCollection2D|GeographicGeometryCollection2D|

# Queries
Query using any of the filter functions:
```swift        
let searchLocation = GeometricPoint2D(x: 1, y: 2)
try UserLocation.query(on: conn).filterGeometryDistanceWithin(\.$location, user.location, 1000).all().wait()
```

| Queries |
|---|
|filterGeometryContains|
|filterGeometryCrosses|
|filterGeometryDisjoint|
|filterGeometryDistance|
|filterGeometryDistanceWithin|
|filterGeometryEquals|
|filterGeometryIntersects|
|filterGeometryOverlaps|
|filterGeometryTouches|
|filterGeometryWithin|
|sortByDistance|

:gift_heart: Contributing
------------
Please create an issue with a description of your problem or open a pull request with a fix.

:v: License
-------
MIT

:alien: Author
------
BrokenHands, Tim Condon, Nikolai Guyot - https://www.brokenhands.io/
Ricardo Carvalho - https://rabc.github.io/
Phil Larson - http://dizm.com
