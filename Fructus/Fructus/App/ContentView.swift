//
//  ContentView.swift
//  Fructus
//
//  Created by Pekka Rasanen on 4.4.2023.
//

import SwiftUI

struct ContentView: View {

    // MARK: - PROPERTIES
    
    @State private var isShowningSettings: Bool = false
    
    var fruits: [Fruit] = fruitsData
    
    // MARK: - BO
    var body: some View {
        NavigationView {
            List {
                ForEach(fruits.shuffled()) { item in
                    NavigationLink(destination: FruitDetailView(fruit: item)) {
                        FruitRowView(fruit: item)
                            .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Fruits")
            .navigationBarItems(
                trailing:
                    Button(action: {
                        isShowningSettings = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                    } //: BUTTON
                    .sheet(isPresented: $isShowningSettings) {
                        SettingsView()
                    }
            )
        } //: NAVIGATION
    }
}

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(fruits: fruitsData)
    }
}
