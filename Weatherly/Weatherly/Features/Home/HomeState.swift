//
//  HomeState.swift
//  Weatherly
//
//  Created by Pekomon on 16.3.2026.
//
	

import Foundation

enum HomeState {
    case idle
    case loading
    case loaded(WeatherDetails)
    case failed(String)
}
