//
//  VideoModel.swift
//  Africa
//
//  Created by Pekka Rasanen on 18.4.2023.
//

import Foundation

struct Video: Codable, Identifiable {
    let id: String
    let name: String
    let headline: String
    
    // Computed property
    var thumbnail: String {
        "video-\(id)"
    }
}
