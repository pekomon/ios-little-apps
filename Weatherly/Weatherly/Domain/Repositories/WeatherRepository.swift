//
//  WeatherRepository.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//
	

import Foundation

protocol WeatherRepository {
    func fetchWeather(for location: Location) async throws -> WeatherDetails

}
