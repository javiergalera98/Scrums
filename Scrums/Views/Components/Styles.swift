//
//  Styles.swift
//  Scrums
//
//  Created by Javier Galera Robles on 10/12/21.
//

import SwiftUI

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

struct ScrumProgressViewStyle: ProgressViewStyle {
    var theme: Theme
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(theme.accentColor)
                        .frame(height: 20.0)
                    if #available(iOS 15.0, *) {
                        ProgressView(configuration)
                            .tint(theme.mainColor)
                            .frame(height: 12.0)
                            .padding(.horizontal)
                    } else {
                        ProgressView(configuration)
                            .frame(height: 12.0)
                            .padding(.horizontal)
                    }
                }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: Self { Self() } 
}
