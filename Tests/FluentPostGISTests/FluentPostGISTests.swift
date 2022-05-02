import FluentKit
import FluentPostgresDriver
import PostgresKit
import XCTest

class FluentPostGISTests: XCTestCase {
    var dbs: Databases!
    var db: Database {
        self.dbs.database(
            logger: .init(label: "lib.fluent.postgis"),
            on: self.dbs.eventLoopGroup.next()
        )!
    }

    override func setUp() {
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
    }
}
