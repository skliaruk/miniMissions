// PINServiceTests.swift
// Unit tests for PINService SHA-256 hashing.

import XCTest
import CryptoKit
@testable import MorningRoutine

final class PINServiceTests: XCTestCase {

    func testHashIsDeterministic() {
        let hash1 = PINService.hash("1234")
        let hash2 = PINService.hash("1234")
        XCTAssertEqual(hash1, hash2, "Same PIN must always produce same hash")
    }

    func testHashIsDifferentForDifferentPINs() {
        let hash1234 = PINService.hash("1234")
        let hash5678 = PINService.hash("5678")
        XCTAssertNotEqual(hash1234, hash5678, "Different PINs must produce different hashes")
    }

    func testHashIsHexString() {
        let hash = PINService.hash("1234")
        XCTAssertEqual(hash.count, 64, "SHA-256 hash must be 64 hex characters")
        XCTAssertTrue(
            hash.allSatisfy { $0.isHexDigit },
            "Hash must contain only hex digits"
        )
    }

    func testHashIncludesSalt() {
        // A direct hash of "1234" without salt must differ from PINService hash
        let directHash = directSHA256("1234")
        let saltedHash = PINService.hash("1234")
        XCTAssertNotEqual(directHash, saltedHash, "Hash must include the app salt")
    }

    func testHashMatchesSaltPlusPin() {
        // Manually compute SHA-256(salt + pin) and compare
        let saltedInput = PINService.salt + "1234"
        let expected = directSHA256(saltedInput)
        let actual = PINService.hash("1234")
        XCTAssertEqual(actual, expected, "Hash must equal SHA-256(salt + pin)")
    }

    // MARK: - Helper

    private func directSHA256(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
