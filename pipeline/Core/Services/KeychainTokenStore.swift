//
//  KeychainTokenStore.swift
//  pipeline
//

import Foundation
import Security

/// Stores the GitHub token in the iOS Keychain.
///
/// `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` keeps the token
/// available to background refreshes after the first unlock while preventing
/// it from being restored to another device.
struct KeychainTokenStore: TokenStoring {
    private let service: String
    private let account: String

    init(
        service: String = Bundle.main.bundleIdentifier ?? "com.shipyard.pipeline",
        account: String = "github-token"
    ) {
        self.service = service
        self.account = account
    }

    func load() throws -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                throw KeychainError.unexpectedData
            }
            return token
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError(status: status)
        }
    }

    func save(_ token: String) throws {
        try delete()

        guard let data = token.data(using: .utf8) else {
            throw KeychainError.unexpectedData
        }

        var attributes = baseQuery
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError(status: status)
        }
    }

    func delete() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError(status: status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

enum KeychainError: LocalizedError {
    case unexpectedData
    case status(OSStatus)

    init(status: OSStatus) {
        self = .status(status)
    }

    var errorDescription: String? {
        switch self {
        case .unexpectedData:
            "The saved token could not be read."
        case .status(let status):
            SecCopyErrorMessageString(status, nil) as String?
                ?? "Keychain error \(status)."
        }
    }
}
