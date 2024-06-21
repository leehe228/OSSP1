//
//  RootView.swift
//  dental-cavity-detector
//
//  Created by Hoeun Lee on 5/21/24.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: RootViewModel
    
    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .home:
                ContentView(viewModel: viewModel)
            case .progress:
                ProgressWaitingView(viewModel: viewModel)
            case .result:
                ResultView(viewModel: viewModel)
            case .loading:
                EmptyView()
            }
            
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.1)
                    ProgressView()
                }
                .ignoresSafeArea()
            }
        }
        .onAppear {
            let requestData = DataManager.all()
            
            if requestData != nil {
                viewModel.transition(.progress)
                viewModel.isLoading = false
            } else {
                viewModel.transition(.home)
                viewModel.isLoading = false
            }
        }
    }
}

#Preview {
    RootView(viewModel: RootViewModel())
}
