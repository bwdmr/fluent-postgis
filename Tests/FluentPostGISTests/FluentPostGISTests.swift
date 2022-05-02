import FluentKit
import FluentPostgresDriver
import PostgresKit
import XCTest

class FluentPostGISTests: XCTestCase {
    var eventLoopGroup: EventLoopGroup!
    var threadPool: NIOThreadPool!
    var dbs: Databases!
    var db: Database {
        self.dbs.database(
            logger: .init(label: "lib.fluent.postgis"),
            on: self.dbs.eventLoopGroup.next()
        )!
    }

    var postgres: PostgresDatabase {
        self.db as! PostgresDatabase
    }

    override func setUp() {
        let configuration = PostgresConfiguration(
            hostname: "localhost",
            username: "fluentpostgis",
            password: "fluentpostgis",
            database: "postgis_tests"
        )

        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.threadPool = NIOThreadPool(numberOfThreads: 1)
        self.dbs = Databases(threadPool: self.threadPool, on: self.eventLoopGroup)
        self.dbs.use(.postgres(configuration: configuration), as: .psql)
    }
}
