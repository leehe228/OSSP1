//
//  LoadingView.swift
//  dental-cavity-detector
//
//  Created by Hoeun Lee on 6/11/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2).ignoresSafeArea()
            
            ProgressView()
        }
    }
}

#Preview {
    LoadingView()
}
