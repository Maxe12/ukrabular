//
//  PersistenceService.swift
//  ukrabular
//
//  Created by Maximilian Bieleke on 07.11.25.
//

import Foundation

protocol PersistenceServiceProtocol {
    func save<T: Codable>(_ object: T, to filename: String)
    func load<T: Codable>(_ type: T.Type, from filename: String) -> T?
}

final class PersistenceService: PersistenceServiceProtocol {
    private func fileURL(for filename: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }
    
    func save<T: Codable>(_ object: T, to filename: String) {
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: fileURL(for: filename), options: [.atomicWrite])
        } catch {
            print("Persistence save error: \(error)")
        }
    }
    
    func load<T: Codable>(_ type: T.Type, from filename: String) -> T? {
        do {
            let data = try Data(contentsOf: fileURL(for: filename))
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Persistence load error: \(error)")
            return nil
        }
    }
}
