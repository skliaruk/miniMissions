// StoreService.swift
// StoreKit 2 service for managing the one-time premium purchase.
// See REQ-010 for freemium model specification.

import StoreKit
import Observation

@Observable
final class StoreService {
    static let shared = StoreService()

    #if DEBUG
    private(set) var isPremium: Bool = false
    #else
    private(set) var isPremium: Bool = false
    #endif
    private(set) var product: Product? = nil

    static let productID = "com.morningroutine.premium"

    init() {
        Swift.Task { await load() }
    }

    func load() async {
        // Check existing transactions
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result, tx.productID == Self.productID {
                isPremium = true
                return
            }
        }
        // Load product
        if let products = try? await Product.products(for: [Self.productID]) {
            product = products.first
        }
    }

    enum PurchaseResult {
        case purchased
        case cancelled
        case failed
    }

    func purchase() async throws -> PurchaseResult {
        guard let product else { return .cancelled }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let tx) = verification {
                await tx.finish()
                isPremium = true
                return .purchased
            }
            return .failed
        case .userCancelled:
            return .cancelled
        case .pending:
            return .cancelled
        @unknown default:
            return .failed
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await load()
    }
}
