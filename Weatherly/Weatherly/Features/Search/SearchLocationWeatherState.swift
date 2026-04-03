//
//  SearchLocationWeatherState.swift
//  Weatherly
//
//  Created by Pekomon on 3.4.2026.
//

import Foundation

enum SearchLocationWeatherState {
    case idle
    case loading
    case loaded(WeatherDetails)
    case failed(String)
}
