import WKCodable
import FluentKit
import Foundation

public protocol GeometryCollectable {
    var baseGeometry: Geometry { get }
    func isEqual(to other: Any?) -> Bool
}

public protocol GeometryConvertible {
    associatedtype GeometryType: Geometry
    init(geometry: GeometryType)
    var geometry: GeometryType { get }
}

extension GeometryCollectable where Self: Equatable {
    public func isEqual(to other: Any?) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}

extension GeometryConvertible where Self: CustomStringConvertible {
    public var description: String {
        return WKTEncoder().encode(geometry)
    }
}

extension GeometryConvertible {
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Data.self)
        let decoder = WKBDecoder()
        let geometry: GeometryType = try decoder.decode(from: value)
        self.init(geometry: geometry)
    }

    public func encode(to encoder: Encoder) throws {
        let wkEncoder = WKBEncoder(byteOrder: .littleEndian)
        let data = wkEncoder.encode(geometry)

        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
}
