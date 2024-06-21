//
//  ProgressView.swift
//  dental-cavity-detector
//
//  Created by Hoeun Lee on 5/21/24.
//

import SwiftUI

struct ProgressWaitingView: View {
    @ObservedObject var viewModel: RootViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Text("예측 중")
                .bold()
                .font(.system(size: 20))
                .padding(.top, 10)
                .onTapGesture {
                    // 임시로 넘어가는 transition 구현
                    viewModel.transition(.result)
                }
            
            Spacer()
            
            VStack {
                if viewModel.data != nil {
                    Text("예측 신청 시간: " + formatData(time: viewModel.data!.time))
                        .font(.system(size: 15))
                        .fontWeight(.regular)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
                    Text("서버에서 예측을 진행하고 있어요.\n잠시만 기다려 주세요.")
                        .font(.system(size: 15))
                        .fontWeight(.regular)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                } else {
                    Text("오류! 요청을 찾을 수 없습니다. \n아래 버튼을 눌러 홈 화면으로 돌아갈 수 있습니다.")
                        .font(.system(size: 15))
                        .fontWeight(.regular)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)

                    Button {
                        DataManager.reset()
                        viewModel.transition(.home)
                    } label: {
                        Text("돌아가기")
                            .font(.system(size: 15))
                            .fontWeight(.regular)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .underline()
                            .padding(.top, 10)
                    }
                }
                
                /* Text("for Debugging")
                if let data = viewModel.data {
                    Text("token: " + data.deviceToken)
                    Text("id: \(data.requestID)")
                    Text("num image: \(data.image.count)")
                } else {
                    Text("NO DATA FOUND")
                }*/
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.loadingDone()
            
            if viewModel.data != nil {
                viewModel.startTimer()
            }
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }
    
    func formatData(time: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. M. d HH:mm"
        return dateFormatter.string(from: time)
    }
}

#Preview {
    ProgressWaitingView(viewModel: RootViewModel())
}
