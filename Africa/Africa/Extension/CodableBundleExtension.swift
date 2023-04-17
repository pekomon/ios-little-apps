//
//  CodableBundleExtension.swift
//  Africa
//
//  Created by Pekka Rasanen on 17.4.2023.
//

import Foundation

extension Bundle {
    func decode(_ file: String) -> [CoverImage] {
        // 1. Locate JSON file
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed locating \(file) from bundle")
        }
        
        // 2. Create property for the data
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed loading \(file) from bundle")
        }
        
        // 3. Create a decoder
        let decoder = JSONDecoder()
        
        // 4. Create a property for the decoded data
        guard let loaded = try? decoder.decode([CoverImage].self, from: data) else {
            fatalError("Failed decoding \(file) from bundle")
        }
        
        // 5. Return the ready-to-use data
        return loaded
    }
}
