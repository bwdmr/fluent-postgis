import FluentKit
import FluentPostgresDriver
import PostgresKit
import XCTest

class FluentPostGISTestCase: XCTestCase {
    var dbs: Databases!
    var db: Database {
        self.dbs.database(
            logger: .init(label: "lib.fluent.postgis"),
            on: self.dbs.eventLoopGroup.next()
        )!
    }

    override func setUp() async throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let threadPool = NIOThreadPool(numberOfThreads: 1)
        self.dbs = Databases(threadPool: threadPool, on: eventLoopGroup)
        let configuration = PostgresConfiguration(
            hostname: "localhost",
            username: "fluentpostgis",
            password: "fluentpostgis",
            database: "postgis_tests"
        )
        self.dbs.use(.postgres(configuration: configuration), as: .psql)

        for migration in self.migrations {
            try await migration.prepare(on: self.db)
        }
    }

    override func tearDown() async throws {
        for migration in self.migrations {
            try await migration.revert(on: self.db)
        }
    }

    private let migrations: [AsyncMigration] = [
        UserLocationMigration(),
        CityMigration(),
        UserPathMigration(),
        UserAreaMigration(),
        UserCollectionMigration(),
    ]
}
