//
//  SecureValueStore.swift
//  LockBox
//
//  Created by Pekomon on 19.4.2026.
//

import Foundation
import Security

protocol SecureValueStoring {
    func loadValue(for key: SecureValueKey) throws -> Data?
    func saveValue(_ value: Data, for key: SecureValueKey) throws
    func deleteValue(for key: SecureValueKey) throws
}

struct SecureValueKey: Hashable, Sendable {
    let service: String
    let account: String

    init(service: String = "com.pekomon.LockBox", account: String) {
        self.service = service
        self.account = account
    }
}

enum SecureValueStoreError: LocalizedError, Equatable {
    case unexpectedStatus(OSStatus)
    case invalidData

    var errorDescription: String? {
        switch self {
        case let .unexpectedStatus(status):
            return "Secure storage failed with status \(status)."
        case .invalidData:
            return "Secure storage returned invalid data."
        }
    }
}

struct KeychainSecureValueStore: SecureValueStoring {
    func loadValue(for key: SecureValueKey) throws -> Data? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard let data = item as? Data else {
                throw SecureValueStoreError.invalidData
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw SecureValueStoreError.unexpectedStatus(status)
        }
    }

    func saveValue(_ value: Data, for key: SecureValueKey) throws {
        let existingQuery = baseQuery(for: key)
        let attributesToUpdate = [kSecValueData as String: value]
        let updateStatus = SecItemUpdate(existingQuery as CFDictionary, attributesToUpdate as CFDictionary)

        switch updateStatus {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            var createQuery = existingQuery
            createQuery[kSecValueData as String] = value

            let createStatus = SecItemAdd(createQuery as CFDictionary, nil)
            guard createStatus == errSecSuccess else {
                throw SecureValueStoreError.unexpectedStatus(createStatus)
            }
        default:
            throw SecureValueStoreError.unexpectedStatus(updateStatus)
        }
    }

    func deleteValue(for key: SecureValueKey) throws {
        let status = SecItemDelete(baseQuery(for: key) as CFDictionary)

        switch status {
        case errSecSuccess, errSecItemNotFound:
            return
        default:
            throw SecureValueStoreError.unexpectedStatus(status)
        }
    }

    private func baseQuery(for key: SecureValueKey) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key.service,
            kSecAttrAccount as String: key.account
        ]
    }
}
