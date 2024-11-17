import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    func save(_ data: Data, service: String, account: String) throws {
        var query = keychainQuery(withService: service, account: account)
        query[kSecValueData as String] = data
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, update it
            try update(data, service: service, account: account)
        } else if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    func update(_ data: Data, service: String, account: String) throws {
        let query = keychainQuery(withService: service, account: account)
        let attributesToUpdate = [kSecValueData as String: data]
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    func read(service: String, account: String) throws -> Data? {
        var query = keychainQuery(withService: service, account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecItemNotFound {
            return nil
        } else if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
        
        return item as? Data
    }
    
    private func keychainQuery(withService service: String, account: String) -> [String: Any] {
        return [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account
        ]
    }
    
    func delete(service: String, account: String) throws {
        let query = keychainQuery(withService: service, account: account)
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unhandledError(status: status)
        }
    }
}

// MARK: - KeychainError
enum KeychainError: Error {
    case unhandledError(status: OSStatus)
} 