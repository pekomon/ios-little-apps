//
//  SectionHeader.swift
//  Weatherly
//
//  Created by Pekomon on 26.3.2026.
//
	

import SwiftUI

struct SectionHeader: View {
    
    let title: String
    let systemImage: String?
    
    var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
            }
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
        }
    }
}

#Preview {
    VStack {
        SectionHeader(title: "Hourly Forecast", systemImage: "clock")
        SectionHeader(title: "Daily Forecast", systemImage: "calendar")
        SectionHeader(title: "Title", systemImage: nil)
    }
}
