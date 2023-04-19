//
//  MapView.swift
//  Africa
//
//  Created by Pekka Rasanen on 17.4.2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State private var region: MKCoordinateRegion = {
        var mapCoordinates = CLLocationCoordinate2D(latitude: 6.600286, longitude: 16.4377599)
        var mapZoomLevel = MKCoordinateSpan(latitudeDelta: 70.0, longitudeDelta: 70.0)
        var mapRegion = MKCoordinateRegion(center: mapCoordinates, span: mapZoomLevel)
        return mapRegion
    } ()
    
    let locations: [NationalParkLocation] = Bundle.main.decode("locations.json")
    
    var body: some View {
        // Basic map
        // Map(coordinateRegion: $region)
        
        // Advanced map
        Map(
            coordinateRegion: $region,
            annotationItems: locations,
            annotationContent: { item in
                // a) PIN - OLD STYLE, always static
                //MapPin(coordinate: item.location, tint: .accentColor)
                
                // b) MARKER - NEW Style, always static
                //MapMarker(coordinate: item.location, tint: .accentColor)
                
                // c) CUSTOM basic annotation (can be interactive)
                MapAnnotation(coordinate: item.location) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32, alignment: .center)
                } //: ANNOTATION
            }
        )
        
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
