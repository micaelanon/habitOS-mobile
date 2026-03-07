import Foundation
import Security

/// Keychain wrapper for secure token storage
/// Tokens MUST be stored here, not UserDefaults
enum SecureStorage {
    private static let service = "app.habitos.mobile"

    static func save(key: String, data: Data) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecValueData: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureStorageError.saveFailed(status)
        }
    }

    static func load(key: String) -> Data? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    static func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    // Convenience for strings
    static func saveString(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else { return }
        try save(key: key, data: data)
    }

    static func loadString(key: String) -> String? {
        guard let data = load(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    enum SecureStorageError: Error {
        case saveFailed(OSStatus)
    }
}
