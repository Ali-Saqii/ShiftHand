//
//  KeychainStore.swift
//  shifthand
//
//  Secure storage for rotating refresh token using Keychain.
//  Refresh tokens must NEVER be stored in UserDefaults.
//

import Foundation
import KeychainSwift

public protocol TokenStorage: Sendable {
    func saveRefreshToken(_ token: String) throws
    func getRefreshToken() -> String?
    func deleteRefreshToken() throws
}

public final class KeychainStore: TokenStorage, @unchecked Sendable {
    public static let shared = KeychainStore()

    private let keychain: KeychainSwift
    private let refreshTokenKey = "sh_refresh_token"

    public init(keyPrefix: String = "shifthand_") {
        let kc = KeychainSwift(keyPrefix: keyPrefix)
        kc.synchronizable = false
        self.keychain = kc
    }

    public func saveRefreshToken(_ token: String) throws {
        let success = keychain.set(token, forKey: refreshTokenKey, withAccess: .accessibleAfterFirstUnlock)
        if !success {
            throw AppError.unknown("Failed to save refresh token to Keychain")
        }
    }

    public func getRefreshToken() -> String? {
        return keychain.get(refreshTokenKey)
    }

    public func deleteRefreshToken() throws {
        let success = keychain.delete(refreshTokenKey)
        // If not found or deleted, treat as success
        _ = success
    }
}
