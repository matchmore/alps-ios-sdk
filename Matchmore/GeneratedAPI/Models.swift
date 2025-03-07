// Models.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

protocol JSONEncodable {
    func encodeToJSON() -> Any
}

public enum ErrorResponse: Error {
    case Error(Int, Data?, Error)
}

open class Response<T> {
    open let statusCode: Int
    open let header: [String: String]
    open let body: T?

    public init(statusCode: Int, header: [String: String], body: T?) {
        self.statusCode = statusCode
        self.header = header
        self.body = body
    }

    public convenience init(response: HTTPURLResponse, body: T?) {
        let rawHeader = response.allHeaderFields
        var header = [String: String]()
        for (key, value) in rawHeader {
            header[key as! String] = value as? String
        }
        self.init(statusCode: response.statusCode, header: header, body: body)
    }
}

private var once = Int()
class Decoders {
    fileprivate static var decoders = Dictionary<String, ((AnyObject, AnyObject?) -> AnyObject)>()

    static func addDecoder<T>(clazz _: T.Type, decoder: @escaping ((AnyObject, AnyObject?) -> T)) {
        let key = "\(T.self)"
        decoders[key] = { decoder($0, $1) as AnyObject }
    }

    static func decode<T>(clazz: T.Type, discriminator: String, source: AnyObject) -> T {
        let key = discriminator
        if let decoder = decoders[key] {
            return decoder(source, nil) as! T
        } else {
            fatalError("Source \(source) is not convertible to type \(clazz): Maybe swagger file is insufficient")
        }
    }

    static func decode<T>(clazz _: [T].Type, source: AnyObject) -> [T] {
        let array = source as! [AnyObject]
        return array.map { Decoders.decode(clazz: T.self, source: $0, instance: nil) }
    }

    static func decode<T, Key: Hashable>(clazz _: [Key: T].Type, source: AnyObject) -> [Key: T] {
        let sourceDictionary = source as! [Key: AnyObject]
        var dictionary = [Key: T]()
        for (key, value) in sourceDictionary {
            dictionary[key] = Decoders.decode(clazz: T.self, source: value, instance: nil)
        }
        return dictionary
    }

    static func decode<T>(clazz: T.Type, source: AnyObject, instance: AnyObject?) -> T {
        initialize()
        if T.self is Int32.Type && source is NSNumber {
            return (source as! NSNumber).int32Value as! T
        }
        if T.self is Int64.Type && source is NSNumber {
            return (source as! NSNumber).int64Value as! T
        }
        if T.self is UUID.Type && source is String {
            return UUID(uuidString: source as! String) as! T
        }
        if source is T {
            return source as! T
        }
        if T.self is Data.Type && source is String {
            return Data(base64Encoded: source as! String) as! T
        }

        let key = "\(T.self)"
        if let decoder = decoders[key] {
            return decoder(source, instance) as! T
        } else {
            fatalError("Source \(source) is not convertible to type \(clazz): Maybe swagger file is insufficient")
        }
    }

    static func decodeOptional<T>(clazz: T.Type, source: AnyObject?) -> T? {
        if source is NSNull {
            return nil
        }
        return source.map { (source: AnyObject) -> T in
            Decoders.decode(clazz: clazz, source: source, instance: nil)
        }
    }

    static func decodeOptional<T>(clazz: [T].Type, source: AnyObject?) -> [T]? {
        if source is NSNull {
            return nil
        }
        return source.map { (someSource: AnyObject) -> [T] in
            Decoders.decode(clazz: clazz, source: someSource)
        }
    }

    static func decodeOptional<T, Key: Hashable>(clazz: [Key: T].Type, source: AnyObject?) -> [Key: T]? {
        if source is NSNull {
            return nil
        }
        return source.map { (someSource: AnyObject) -> [Key: T] in
            Decoders.decode(clazz: clazz, source: someSource)
        }
    }

    private static var __once: () = {
        let formatters = [
            "yyyy-MM-dd",
            "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd HH:mm:ss"
        ].map { (format: String) -> DateFormatter in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            return formatter
        }
        // Decoder for Date
        Decoders.addDecoder(clazz: Date.self) { (source: AnyObject, _: AnyObject?) -> Date in
            if let sourceString = source as? String {
                for formatter in formatters {
                    if let date = formatter.date(from: sourceString) {
                        return date
                    }
                }
            }
            if let sourceInt = source as? Int64 {
                // treat as a java date
                return Date(timeIntervalSince1970: Double(sourceInt / 1000))
            }
            fatalError("formatter failed to parse \(source)")
        }

        // Decoder for [APIError]
        Decoders.addDecoder(clazz: [APIError].self) { (source: AnyObject, _: AnyObject?) -> [APIError] in
            return Decoders.decode(clazz: [APIError].self, source: source)
        }
        // Decoder for APIError
        Decoders.addDecoder(clazz: APIError.self) { (source: AnyObject, instance: AnyObject?) -> APIError in
            let sourceDictionary = source as! [AnyHashable: Any]
            let result = instance == nil ? APIError() : instance as! APIError

            result.code = Decoders.decodeOptional(clazz: Int32.self, source: sourceDictionary["code"] as AnyObject?)
            result.message = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["message"] as AnyObject?)
            return result
        }

        // Decoder for [Device]
        Decoders.addDecoder(clazz: [Device].self) { (source: AnyObject, _: AnyObject?) -> [Device] in
            return Decoders.decode(clazz: [Device].self, source: source)
        }
        // Decoder for Device
        Decoders.addDecoder(clazz: Device.self) { (source: AnyObject, instance: AnyObject?) -> Device in
            let sourceDictionary = source as! [AnyHashable: Any]
            // Check discriminator to support inheritance
            if let discriminator = sourceDictionary["deviceType"] as? String, instance == nil && discriminator != "Device" {
                return Decoders.decode(clazz: Device.self, discriminator: discriminator, source: source)
            }
            let result = instance == nil ? Device() : instance as! Device

            result.id = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["id"] as AnyObject?)
            result.createdAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["createdAt"] as AnyObject?)
            result.updatedAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["updatedAt"] as AnyObject?)
            result.group = Decoders.decodeOptional(clazz: Array.self, source: sourceDictionary["group"] as AnyObject?)
            result.name = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["name"] as AnyObject?)
            result.deviceType = Decoders.decodeOptional(clazz: DeviceType.self, source: sourceDictionary["deviceType"] as AnyObject?)
            return result
        }

        // Decoder for [DeviceType]
        Decoders.addDecoder(clazz: [DeviceType].self) { (source: AnyObject, _: AnyObject?) -> [DeviceType] in
            return Decoders.decode(clazz: [DeviceType].self, source: source)
        }
        // Decoder for DeviceType
        Decoders.addDecoder(clazz: DeviceType.self) { (source: AnyObject, _: AnyObject?) -> DeviceType in
            if let source = source as? String {
                if let result = DeviceType(rawValue: source) {
                    return result
                }
            }
            fatalError("Source \(source) is not convertible to enum type DeviceType: Maybe swagger file is insufficient")
        }

        // Decoder for [DeviceUpdate]
        Decoders.addDecoder(clazz: [DeviceUpdate].self) { (source: AnyObject, _: AnyObject?) -> [DeviceUpdate] in
            return Decoders.decode(clazz: [DeviceUpdate].self, source: source)
        }
        // Decoder for DeviceUpdate
        Decoders.addDecoder(clazz: DeviceUpdate.self) { (source: AnyObject, instance: AnyObject?) -> DeviceUpdate in
            let sourceDictionary = source as! [AnyHashable: Any]
            let result = instance == nil ? DeviceUpdate() : instance as! DeviceUpdate

            result.name = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["name"] as AnyObject?)
            result.deviceToken = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["deviceToken"] as AnyObject?)
            return result
        }

        // Decoder for [Devices]
        Decoders.addDecoder(clazz: [Devices].self) { (source: AnyObject, _: AnyObject?) -> [Devices] in
            return Decoders.decode(clazz: [Devices].self, source: source)
        }
        // Decoder for Devices
        Decoders.addDecoder(clazz: Devices.self) { (source: AnyObject, _: AnyObject?) -> Devices in
            let sourceArray = source as! [AnyObject]
            return sourceArray.map({ Decoders.decode(clazz: Device.self, source: $0, instance: nil) })
        }

        // Decoder for [IBeaconTriple]
        Decoders.addDecoder(clazz: [IBeaconTriple].self) { (source: AnyObject, _: AnyObject?) -> [IBeaconTriple] in
            return Decoders.decode(clazz: [IBeaconTriple].self, source: source)
        }
        // Decoder for IBeaconTriple
        Decoders.addDecoder(clazz: IBeaconTriple.self) { (source: AnyObject, instance: AnyObject?) -> IBeaconTriple in
            let sourceDictionary = source as! [AnyHashable: Any]
            let result = instance == nil ? IBeaconTriple() : instance as! IBeaconTriple

            result.deviceId = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["deviceId"] as AnyObject?)
            result.proximityUUID = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["proximityUUID"] as AnyObject?)
            result.major = Decoders.decodeOptional(clazz: Int32.self, source: sourceDictionary["major"] as AnyObject?)
            result.minor = Decoders.decodeOptional(clazz: Int32.self, source: sourceDictionary["minor"] as AnyObject?)
            return result
        }

        // Decoder for [IBeaconTriples]
        Decoders.addDecoder(clazz: [IBeaconTriples].self) { (source: AnyObject, _: AnyObject?) -> [IBeaconTriples] in
            return Decoders.decode(clazz: [IBeaconTriples].self, source: source)
        }
        // Decoder for IBeaconTriples
        Decoders.addDecoder(clazz: IBeaconTriples.self) { (source: AnyObject, _: AnyObject?) -> IBeaconTriples in
            let sourceArray = source as! [AnyObject]
            return sourceArray.map({ Decoders.decode(clazz: IBeaconTriple.self, source: $0, instance: nil) })
        }

        // Decoder for [Location]
        Decoders.addDecoder(clazz: [Location].self) { (source: AnyObject, _: AnyObject?) -> [Location] in
            return Decoders.decode(clazz: [Location].self, source: source)
        }
        // Decoder for Location
        Decoders.addDecoder(clazz: Location.self) { (source: AnyObject, instance: AnyObject?) -> Location in
            let sourceDictionary = source as! [AnyHashable: Any]
            let result = instance == nil ? Location() : instance as! Location

            result.createdAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["createdAt"] as AnyObject?)
            result.latitude = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["latitude"] as AnyObject?)
            result.longitude = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["longitude"] as AnyObject?)
            result.altitude = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["altitude"] as AnyObject?)
            result.horizontalAccuracy = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["horizontalAccuracy"] as AnyObject?)
            result.verticalAccuracy = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["verticalAccuracy"] as AnyObject?)
            return result
        }

        // Decoder for [Match]
        Decoders.addDecoder(clazz: [Match].self) { (source: AnyObject, _: AnyObject?) -> [Match] in
            return Decoders.decode(clazz: [Match].self, source: source)
        }
        // Decoder for Match
        Decoders.addDecoder(clazz: Match.self) { (source: AnyObject, instance: AnyObject?) -> Match in
            let sourceDictionary = source as! [AnyHashable: Any]
            let result = instance == nil ? Match() : instance as! Match

            result.id = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["id"] as AnyObject?)
            result.createdAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["createdAt"] as AnyObject?)
            result.publication = Decoders.decodeOptional(clazz: Publication.self, source: sourceDictionary["publication"] as AnyObject?)
            result.subscription = Decoders.decodeOptional(clazz: Subscription.self, source: sourceDictionary["subscription"] as AnyObject?)
            return result
        }

        // Decoder for [Matches]
        Decoders.addDecoder(clazz: [Matches].self) { (source: AnyObject, _: AnyObject?) -> [Matches] in
            return Decoders.decode(clazz: [Matches].self, source: source)
        }
        // Decoder for Matches
        Decoders.addDecoder(clazz: Matches.self) { (source: AnyObject, _: AnyObject?) -> Matches in
            let sourceArray = source as! [AnyObject]
            return sourceArray.map({ Decoders.decode(clazz: Match.self, source: $0, instance: nil) })
        }

        // Decoder for [ProximityEvent]
        Decoders.addDecoder(clazz: [ProximityEvent].self) { (source: AnyObject, _: AnyObject?) -> [ProximityEvent] in
            return Decoders.decode(clazz: [ProximityEvent].self, source: source)
        }
        // Decoder for ProximityEvent
        Decoders.addDecoder(clazz: ProximityEvent.self) { (source: AnyObject, instance: AnyObject?) -> ProximityEvent in
            let sourceDictionary = source as! [AnyHashable: Any]
            let result = instance == nil ? ProximityEvent() : instance as! ProximityEvent

            result.id = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["id"] as AnyObject?)
            result.createdAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["createdAt"] as AnyObject?)
            result.deviceId = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["deviceId"] as AnyObject?)
            result.distance = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["distance"] as AnyObject?)
            return result
        }

        // Decoder for [Publication]
        Decoders.addDecoder(clazz: [Publication].self) { (source: AnyObject, _: AnyObject?) -> [Publication] in
            return Decoders.decode(clazz: [Publication].self, source: source)
        }
        // Decoder for Publication
        Decoders.addDecoder(clazz: Publication.self) { (source: AnyObject, instance: AnyObject?) -> Publication in
            let sourceDictionary = source as! [AnyHashable: Any]
            let result = instance == nil ? Publication() : instance as! Publication

            result.id = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["id"] as AnyObject?)
            result.location = Decoders.decodeOptional(clazz: Location.self, source: sourceDictionary["location"] as AnyObject?)
            result.createdAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["createdAt"] as AnyObject?)
            result.worldId = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["worldId"] as AnyObject?)
            result.deviceId = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["deviceId"] as AnyObject?)
            result.topic = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["topic"] as AnyObject?)
            result.range = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["range"] as AnyObject?)
            result.duration = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["duration"] as AnyObject?)
            result.properties = Decoders.decodeOptional(clazz: [String: Any].self, source: sourceDictionary["properties"] as AnyObject?)
            return result
        }

        // Decoder for [Publications]
        Decoders.addDecoder(clazz: [Publications].self) { (source: AnyObject, _: AnyObject?) -> [Publications] in
            return Decoders.decode(clazz: [Publications].self, source: source)
        }
        // Decoder for Publications
        Decoders.addDecoder(clazz: Publications.self) { (source: AnyObject, _: AnyObject?) -> Publications in
            let sourceArray = source as! [AnyObject]
            return sourceArray.map({ Decoders.decode(clazz: Publication.self, source: $0, instance: nil) })
        }

        // Decoder for [Subscription]
        Decoders.addDecoder(clazz: [Subscription].self) { (source: AnyObject, _: AnyObject?) -> [Subscription] in
            return Decoders.decode(clazz: [Subscription].self, source: source)
        }
        // Decoder for Subscription
        Decoders.addDecoder(clazz: Subscription.self) { (source: AnyObject, instance: AnyObject?) -> Subscription in
            let sourceDictionary = source as! [AnyHashable: Any]
            let result = instance == nil ? Subscription() : instance as! Subscription

            result.id = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["id"] as AnyObject?)
            result.location = Decoders.decodeOptional(clazz: Location.self, source: sourceDictionary["location"] as AnyObject?)
            result.createdAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["createdAt"] as AnyObject?)
            result.worldId = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["worldId"] as AnyObject?)
            result.deviceId = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["deviceId"] as AnyObject?)
            result.topic = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["topic"] as AnyObject?)
            result.selector = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["selector"] as AnyObject?)
            result.range = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["range"] as AnyObject?)
            result.duration = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["duration"] as AnyObject?)
            result.matchTTL = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["matchTTL"] as AnyObject?)
            result.matchDTL = Decoders.decodeOptional(clazz: Double.self, source: sourceDictionary["matchDTL"] as AnyObject?)
            result.pushers = Decoders.decodeOptional(clazz: Array.self, source: sourceDictionary["pushers"] as AnyObject?)
            return result
        }

        // Decoder for [Subscriptions]
        Decoders.addDecoder(clazz: [Subscriptions].self) { (source: AnyObject, _: AnyObject?) -> [Subscriptions] in
            return Decoders.decode(clazz: [Subscriptions].self, source: source)
        }
        // Decoder for Subscriptions
        Decoders.addDecoder(clazz: Subscriptions.self) { (source: AnyObject, _: AnyObject?) -> Subscriptions in
            let sourceArray = source as! [AnyObject]
            return sourceArray.map({ Decoders.decode(clazz: Subscription.self, source: $0, instance: nil) })
        }

        // Decoder for [IBeaconDevice]
        Decoders.addDecoder(clazz: [IBeaconDevice].self) { (source: AnyObject, _: AnyObject?) -> [IBeaconDevice] in
            return Decoders.decode(clazz: [IBeaconDevice].self, source: source)
        }
        // Decoder for IBeaconDevice
        Decoders.addDecoder(clazz: IBeaconDevice.self) { (source: AnyObject, instance: AnyObject?) -> IBeaconDevice in
            let sourceDictionary = source as! [AnyHashable: Any]
            let result = instance == nil ? IBeaconDevice() : instance as! IBeaconDevice
            if decoders["\(Device.self)"] != nil {
                _ = Decoders.decode(clazz: Device.self, source: source, instance: result)
            }

            result.id = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["id"] as AnyObject?)
            result.createdAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["createdAt"] as AnyObject?)
            result.updatedAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["updatedAt"] as AnyObject?)
            result.group = Decoders.decodeOptional(clazz: Array.self, source: sourceDictionary["group"] as AnyObject?)
            result.name = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["name"] as AnyObject?)
            result.deviceType = Decoders.decodeOptional(clazz: DeviceType.self, source: sourceDictionary["deviceType"] as AnyObject?)
            result.proximityUUID = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["proximityUUID"] as AnyObject?)
            result.major = Decoders.decodeOptional(clazz: Int32.self, source: sourceDictionary["major"] as AnyObject?)
            result.minor = Decoders.decodeOptional(clazz: Int32.self, source: sourceDictionary["minor"] as AnyObject?)
            return result
        }

        // Decoder for [MobileDevice]
        Decoders.addDecoder(clazz: [MobileDevice].self) { (source: AnyObject, _: AnyObject?) -> [MobileDevice] in
            return Decoders.decode(clazz: [MobileDevice].self, source: source)
        }
        // Decoder for MobileDevice
        Decoders.addDecoder(clazz: MobileDevice.self) { (source: AnyObject, instance: AnyObject?) -> MobileDevice in
            let sourceDictionary = source as! [AnyHashable: Any]
            let result = instance == nil ? MobileDevice() : instance as! MobileDevice
            if decoders["\(Device.self)"] != nil {
                _ = Decoders.decode(clazz: Device.self, source: source, instance: result)
            }

            result.id = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["id"] as AnyObject?)
            result.createdAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["createdAt"] as AnyObject?)
            result.updatedAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["updatedAt"] as AnyObject?)
            result.group = Decoders.decodeOptional(clazz: Array.self, source: sourceDictionary["group"] as AnyObject?)
            result.name = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["name"] as AnyObject?)
            result.deviceType = Decoders.decodeOptional(clazz: DeviceType.self, source: sourceDictionary["deviceType"] as AnyObject?)
            result.platform = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["platform"] as AnyObject?)
            result.deviceToken = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["deviceToken"] as AnyObject?)
            result.location = Decoders.decodeOptional(clazz: Location.self, source: sourceDictionary["location"] as AnyObject?)
            return result
        }

        // Decoder for [PinDevice]
        Decoders.addDecoder(clazz: [PinDevice].self) { (source: AnyObject, _: AnyObject?) -> [PinDevice] in
            return Decoders.decode(clazz: [PinDevice].self, source: source)
        }
        // Decoder for PinDevice
        Decoders.addDecoder(clazz: PinDevice.self) { (source: AnyObject, instance: AnyObject?) -> PinDevice in
            let sourceDictionary = source as! [AnyHashable: Any]
            let result = instance == nil ? PinDevice() : instance as! PinDevice
            if decoders["\(Device.self)"] != nil {
                _ = Decoders.decode(clazz: Device.self, source: source, instance: result)
            }

            result.id = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["id"] as AnyObject?)
            result.createdAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["createdAt"] as AnyObject?)
            result.updatedAt = Decoders.decodeOptional(clazz: Int64.self, source: sourceDictionary["updatedAt"] as AnyObject?)
            result.group = Decoders.decodeOptional(clazz: Array.self, source: sourceDictionary["group"] as AnyObject?)
            result.name = Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["name"] as AnyObject?)
            result.deviceType = Decoders.decodeOptional(clazz: DeviceType.self, source: sourceDictionary["deviceType"] as AnyObject?)
            result.location = Decoders.decodeOptional(clazz: Location.self, source: sourceDictionary["location"] as AnyObject?)
            return result
        }
    }()

    fileprivate static func initialize() {
        _ = Decoders.__once
    }
}
