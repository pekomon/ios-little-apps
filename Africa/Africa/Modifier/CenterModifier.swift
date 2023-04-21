//
//  CenterModifier.swift
//  Africa
//
//  Created by Pekka Rasanen on 21.4.2023.
//

import SwiftUI

struct CenterModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}
