import Foundation
import NIOConcurrencyHelpers
import FluentPostGIS
import FluentPostgresDriver
import FluentKit
import SQLKit
import NIOCore
import NIOPosix
import Logging

enum TestDatabaseError: Error, CustomStringConvertible {
    case notBootstrapped
    case databaseUnavailable
    case registrationFailed

    var description: String {
        switch self {
        case .notBootstrapped:
            "TestDatabase has not been bootstrapped"
        case .databaseUnavailable:
            "Failed to obtain database connection"
        case .registrationFailed:
            "Suite registration failed"
        }
    }
}

actor TestDatabase {
    static let shared = TestDatabase()

    private var eventLoopGroup: (any EventLoopGroup)?
    private var threadPool: NIOThreadPool?
    private var databases: Databases?
    private var registeredSuites: Set<String> = []
    private var bootstrapped = false
    private var extensionCreated = false

    // MARK: - Postgres config

    private nonisolated func pgConfig() -> SQLPostgresConfiguration {
        let env = ProcessInfo.processInfo.environment
        return SQLPostgresConfiguration(
            hostname: env["DB_HOST"] ?? "127.0.0.1",
            port: env["DB_PORT"].flatMap(Int.init) ?? 55432,
            username: env["DB_USER"] ?? "fluentpostgis",
            password: env["DB_PASS"] ?? "fluentpostgis",
            database: env["DB_NAME"] ?? "postgis_tests",
            tls: .disable
        )
    }

    // MARK: - Bootstrap (once per process)

    private func bootstrap() async throws {
        if bootstrapped { return }

        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        let tp = NIOThreadPool(numberOfThreads: 2)
        tp.start()

        let dbs = Databases(threadPool: tp, on: elg)

        self.eventLoopGroup = elg
        self.threadPool = tp
        self.databases = dbs
        self.bootstrapped = true
    }

    // MARK: - Public interface

    func database(
        suite: String,
        migrations suiteMigrations: [any Migration]
    ) async throws -> any Database {
        try await bootstrap()

        let schemaName = suite.lowercased()
        let dbID = DatabaseID(string: schemaName)

        guard let dbs = self.databases, let elg = self.eventLoopGroup else {
            throw TestDatabaseError.notBootstrapped
        }

        if !registeredSuites.contains(suite) {
            var config = pgConfig()
            config.searchPath = [schemaName, "public"]

            dbs.use(.postgres(configuration: config), as: dbID)

            guard let db = dbs.database(dbID, logger: Logger(label: suite), on: elg.any()),
                  let sqlDB = db as? any SQLDatabase else {
                throw TestDatabaseError.databaseUnavailable
            }

            // Create extension on first suite registration
            if !extensionCreated {
                try await sqlDB.raw("CREATE EXTENSION IF NOT EXISTS postgis").run()
                extensionCreated = true
            }

            try await sqlDB.raw("DROP SCHEMA IF EXISTS \(unsafeRaw: schemaName) CASCADE").run()
            try await sqlDB.raw("CREATE SCHEMA \(unsafeRaw: schemaName)").run()

            let migrations = Migrations()
            for m in suiteMigrations {
                migrations.add(m, to: dbID)
            }

            let migrator = Migrator(
                databases: dbs,
                migrations: migrations,
                logger: Logger(label: "migrator-\(suite)"),
                on: elg.any()
            )

            try await migrator.setupIfNeeded().get()
            try await migrator.prepareBatch().get()

            registeredSuites.insert(suite)
        } else {
            guard let db = dbs.database(dbID, logger: Logger(label: suite), on: elg.any()),
                  let sqlDB = db as? any SQLDatabase else {
                throw TestDatabaseError.databaseUnavailable
            }

            try await sqlDB.raw("""
                DO $$
                DECLARE r RECORD;
                BEGIN
                    FOR r IN (
                        SELECT tablename FROM pg_tables
                        WHERE schemaname = current_schema()
                          AND tablename NOT IN ('_fluent_migrations', 'spatial_ref_sys')
                    ) LOOP
                        EXECUTE 'TRUNCATE TABLE ' || quote_ident(r.tablename)
                            || ' RESTART IDENTITY CASCADE';
                    END LOOP;
                END $$
                """).run()
        }

        guard let db = dbs.database(dbID, logger: Logger(label: "test-\(suite)"), on: elg.any()) else {
            throw TestDatabaseError.databaseUnavailable
        }

        return db
    }
}

// MARK: - Convenience

func withTestDatabase(
    suite: String = #filePath,
    migrations: [any Migration],
    _ body: (any Database) async throws -> Void
) async throws {
    let db = try await TestDatabase.shared.database(
        suite: suite,
        migrations: migrations
    )
    try await body(db)
}
