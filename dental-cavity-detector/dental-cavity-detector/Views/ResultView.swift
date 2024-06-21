//
//  ResultView.swift
//  dental-cavity-detector
//
//  Created by Hoeun Lee on 5/21/24.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var viewModel: RootViewModel
    @State private var isDetailViewPresented: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text("충치 예측 서비스")
                .bold()
                .font(.system(size: 20))
                .padding(.top, 10)
            
            Text("사진을 클릭하면 상세 정보를 조회할 수 있어요.")
                .fontWeight(.regular)
                .font(.system(size: 15))
                .padding(.top, 2)
            
            ScrollView {
                /* ForEach(response.result.pred, id: \.cls) { pred in
                    Text(pred.cls)
                }*/
                
                if let data = viewModel.data {
                    
                    VStack(alignment: .center, spacing: 10) {
                        let counter: CavityCount = count()
                        
                        resultBox(image: data.image[0], isWarning: counter.warning > 0, isDanger: counter.danger > 0)
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                isDetailViewPresented.toggle()
                            }
                        
                        /* resultBox(image: 0, isWarning: true, isDanger: false)
                         .listRowSeparator(.hidden)
                         .onTapGesture {
                         isDetailViewPresented.toggle()
                         }
                         
                         resultBox(image: 0, isWarning: true, isDanger: true)
                         .listRowSeparator(.hidden)
                         .onTapGesture {
                         isDetailViewPresented.toggle()
                         }*/
                    }
                    .padding()
                }
            }
            .listStyle(.plain)
            
            Spacer()
            
            Text("*새로 신청 시, 현재 결과가 삭제됩니다.\n필요 시 기기에 다운로드를 권장합니다.")
                .fontWeight(.regular)
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.transition(.home)
            } label: {
                RoundedRectangle(cornerRadius: 15)
                    .frame(height: 52)
                    .padding()
                    .overlay {
                        Text("새로 신청")
                            .bold()
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                    }
            }
        }
        .onAppear {
            // viewModel.fetchData()
        }
        .sheet(isPresented: $isDetailViewPresented) {
            if let data = viewModel.data, let resp = viewModel.successResponse {
                ResultDetailView(data: data, response: resp)
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    @ViewBuilder
    func resultBox(image: UIImage, isWarning: Bool, isDanger: Bool) -> some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(.defaultLightGray)
            .frame(height: 90)
            .overlay {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipped()
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                        .padding(.trailing, 4)
                    
                    VStack(spacing: 4) {
                        // 충치 없음
                        if !isWarning && !isDanger {
                            HStack {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 4, height: 4)
                                
                                Text("충치 없음")
                                    .font(.system(size: 15))
                                    .foregroundColor(.defaultDarkGray)
                            }
                        }
                        
                        if isDanger {
                            HStack {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 4, height: 4)
                                
                                Text("충치 위험")
                                    .font(.system(size: 15))
                                    .foregroundColor(.defaultDarkGray)
                            }
                        }
                        
                        if isWarning {
                            HStack {
                                Circle()
                                    .fill(.yellow)
                                    .frame(width: 4, height: 4)
                                
                                Text("충치 의심")
                                    .font(.system(size: 15))
                                    .foregroundColor(.defaultDarkGray)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
                .frame(height: 90)
            }
    }
    
    func count() -> CavityCount {
        guard let data = viewModel.successResponse else { return CavityCount(warning: 0, danger: 0) }
        let result = data.result
        
        var warning = 0
        var danger = 0
        
        for prediction in result.pred {
            if prediction.cls == "1" {
                if prediction.prob >= 0.9 {
                    danger += 1
                }
                else if prediction.prob >= 0.5 {
                    warning += 1
                }
            }
        }
        
        let counter = CavityCount(warning: warning, danger: danger)
        
        return counter
    }
}

#Preview {
    ResultView(viewModel: RootViewModel())
}
