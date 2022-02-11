//
//  ErrorView.swift
//  Scrums
//
//  Created by Javier Galera Robles on 10/12/21.
//

import SwiftUI

struct ErrorView: View {
    @Environment(\.dismiss) private var dismiss
    
    let errorWrapper: ErrorWrapper
    
    var body: some View {
        VStack {
            Text("An error has occurred!")
                .font(.title)
                .padding(.bottom)
            Text(errorWrapper.error.localizedDescription)
                .font(.headline)
            Text(errorWrapper.guidance)
                .font(.caption)
                .padding(.top)
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Dismiss") {
                    dismiss()
                }
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    enum sampleError: Error {
        case errorRequired
    }
    
    static var wrapper: ErrorWrapper {
        ErrorWrapper(error: sampleError.errorRequired, guidance: "You can safely ignore this error.")
    }
    
    static var previews: some View {
        ErrorView(errorWrapper: wrapper)
    }
}
