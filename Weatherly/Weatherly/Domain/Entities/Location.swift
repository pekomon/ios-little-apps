//
//  Location.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//
	

import Foundation

struct Location: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let country: String?
    let latitude: Double
    let longitude: Double
}
