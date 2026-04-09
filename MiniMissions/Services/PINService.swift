// PINService.swift
// PIN hashing with SHA-256 and Keychain storage.
// See ADR-003 for PIN storage design.

import Foundation
import CryptoKit
import Security

// MARK: - PIN Hashing

enum PINService {
    static let salt = "taskapp.pin.salt.v1"

    /// Hashes a 4-digit PIN using SHA-256 with the fixed app salt.
    /// Hash is computed as SHA-256(salt + pin) returned as lowercase hex string.
    static func hash(_ pin: String) -> String {
        let input = salt + pin
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - KeychainStore

final class KeychainStore {
    static let shared = KeychainStore()

    private let service = "com.taskapp.pin"
    private let account = "parentPin"

    private init() {}

    func savePINHash(_ hash: String) throws {
        let data = Data(hash.utf8)
        // Delete any existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new item
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func loadPINHash() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let hash = String(data: data, encoding: .utf8) else {
            return nil
        }
        return hash
    }

    func deletePINHash() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    enum KeychainError: Error {
        case saveFailed(OSStatus)
        case deleteFailed(OSStatus)
    }
}
