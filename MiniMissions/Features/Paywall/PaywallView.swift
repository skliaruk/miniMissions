// PaywallView.swift
// Paywall sheet shown when a free user tries to add a second topic.
// See REQ-010 for freemium model specification.

import SwiftUI
import StoreKit

struct PaywallView: View {
    let onDismiss: () -> Void
    let onPurchased: () -> Void

    @State private var store = StoreService.shared
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Icon + title
                    VStack(spacing: 16) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(.brandPurple)
                        Text("paywall.title")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        Text("paywall.subtitle")
                            .font(.title3)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)

                    // Benefits list
                    VStack(alignment: .leading, spacing: 16) {
                        benefitRow(icon: "infinity", text: "paywall.benefit.topics")
                        benefitRow(icon: "checkmark.seal.fill", text: "paywall.benefit.oneTime")
                        benefitRow(icon: "person.3.fill", text: "paywall.benefit.family")
                    }
                    .padding(.horizontal, 32)

                    // Purchase button
                    VStack(spacing: 12) {
                        Button {
                            Swift.Task {
                                isPurchasing = true
                                let result = try? await store.purchase()
                                isPurchasing = false
                                switch result {
                                case .purchased: onPurchased()
                                case .cancelled: break
                                case .failed, nil: showError = true
                                }
                            }
                        } label: {
                            HStack {
                                if isPurchasing {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(priceLabel)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.brandPurple)
                            .foregroundColor(.white)
                            .font(.headline)
                            .clipShape(Capsule())
                        }
                        .disabled(isPurchasing || isRestoring)
                        .accessibilityIdentifier("paywall.purchaseButton")

                        Button {
                            Swift.Task {
                                isRestoring = true
                                await store.restore()
                                isRestoring = false
                                if store.isPremium { onPurchased() }
                            }
                        } label: {
                            if isRestoring {
                                ProgressView()
                            } else {
                                Text("paywall.restore")
                                    .font(.subheadline)
                                    .foregroundColor(.brandPurple)
                            }
                        }
                        .disabled(isPurchasing || isRestoring)
                        .accessibilityIdentifier("paywall.restoreButton")
                    }
                    .padding(.horizontal, 32)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "paywall.notNow")) {
                        onDismiss()
                    }
                    .foregroundColor(.textSecondary)
                    .accessibilityIdentifier("paywall.notNowButton")
                }
            }
        }
        .presentationDetents([.large])
        .alert(String(localized: "paywall.error.title"), isPresented: $showError) {
            Button(String(localized: "paywall.error.ok"), role: .cancel) {}
        } message: {
            Text("paywall.error.message")
        }
    }

    private var priceLabel: String {
        if let product = store.product {
            return String(format: String(localized: "paywall.unlock"), product.displayPrice)
        }
        return String(localized: "paywall.unlock.noPrice")
    }

    @ViewBuilder
    private func benefitRow(icon: String, text: LocalizedStringKey) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.brandPurple)
                .frame(width: 36)
            Text(text)
                .font(.body)
                .foregroundColor(.textPrimary)
        }
    }
}
