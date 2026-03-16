//
//  HomeViewModel.swift
//  Weatherly
//
//  Created by Pekomon on 16.3.2026.
//
	

import Foundation
import Observation

@Observable
final class HomeViewModel {
    var state: HomeState = .idle
    
    func loadMockWeather() {
        state = .loading
        state = .loaded(HomeMockData.weatherDetails)
    }
}
