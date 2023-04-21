//
//  AboutView.swift
//  Africa
//
//  Created by Pekka Rasanen on 20.4.2023.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Image("compass")
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
            Text("""
    Copyright ®Pekomon
    All rights reserved
    Learning SwiftUI ❤️
    """)
            .font(.footnote)
            .multilineTextAlignment(.center)
        } //: VSTACK
        .padding()
        .opacity(0.4)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
