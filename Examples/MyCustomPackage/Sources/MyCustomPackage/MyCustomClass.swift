import Foundation

@objc
@objcMembers
public class MyCustomClass: NSObject, NSCoding {
    public var name: String
    public var value: NSNumber
    
    // Standard initializer
    public required init(name: String, value: NSNumber) {
        self.name = name
        self.value = value
        super.init()
    }
    
    // MARK: - Plank Model Protocol
    
    // Create from dictionary
    @objc(modelObjectWithDictionary:error:)
    public class func modelObject(with dictionary: [String: Any], error: NSErrorPointer) -> Self? {
        guard let name = dictionary["name"] as? String,
              let value = dictionary["value"] as? NSNumber else {
            if let errorPtr = error {
                errorPtr.pointee = NSError(
                    domain: "MyCustomClass",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing required fields: name or value"]
                )
            }
            return nil
        }
        return self.init(name: name, value: value)
    }
    
    // Convert to dictionary
    @objc
    public func dictionaryObjectRepresentation() -> [String: Any] {
        return [
            "name": name,
            "value": value
        ]
    }
    
    // Merge with another model
    @objc(mergeWithModel:initType:)
    public func merge(with modelObject: MyCustomClass, initType: UInt) -> Self {
        return type(of: self).init(
            name: modelObject.name,
            value: modelObject.value
        )
    }
    
    // MARK: - NSCoding
    
    // NSCoding - encode
    public func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(value, forKey: "value")
    }
    
    // NSCoding - decode
    public required init?(coder: NSCoder) {
        guard let name = coder.decodeObject(forKey: "name") as? String,
              let value = coder.decodeObject(forKey: "value") as? NSNumber else {
            return nil
        }
        self.name = name
        self.value = value
        super.init()
    }
}

