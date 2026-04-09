// PINHashHelper.swift
// Computes PIN hashes for use in UI test launch arguments.
// Mirrors PINService.hash() without importing the app target.

import Foundation
import CryptoKit

enum PINHashHelper {
    static let appSalt = "taskapp.pin.salt.v1"

    /// Compute SHA-256(salt + pin) as lowercase hex string — mirrors PINService.hash()
    static func hash(_ pin: String) -> String {
        let input = appSalt + pin
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Pre-computed hash for PIN "1234" — used as the default test PIN hash.
    static let pin1234Hash: String = hash("1234")
}
