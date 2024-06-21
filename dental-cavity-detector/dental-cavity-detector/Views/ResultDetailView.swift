//
//  ResultDetailView.swift
//  dental-cavity-detector
//
//  Created by Hoeun Lee on 5/21/24.
//

import SwiftUI

struct ResultDetailView: View {
    // @ObservedObject var viewModel: RootViewModel
    let data: RequestData
    let response: SuccessResponse
    @State private var selectedID: UUID? = nil
    
    // @State private var image: UIImage? = UIImage(named: "dummy")
    // Sample data received from the server
    
    var body: some View {
        VStack(alignment: .center) {
            Text("충치 예측 결과 상세 조회")
                .bold()
                .font(.system(size: 20))
                .padding(.top, 34)
            
            Text("사진에 박스를 클릭하면 상세 정보를 확인할 수 있어요.")
                .fontWeight(.regular)
                .font(.system(size: 15))
                .padding(.top, 2)
                .padding(.bottom, 30)
            
            VStack {
                let uiImage = data.image[0]
                GeometryReader { geometry in
                    let imageSize = uiImage.size
                    let aspectRatio = imageSize.width / imageSize.height
                    let displayWidth = geometry.size.width
                    let displayHeight = displayWidth / aspectRatio

                    let scale = displayWidth / imageSize.width
                    // let scale: CGFloat = 0.2

                    ZStack {
                        // Display the image
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: displayWidth, height: displayHeight)
                            .position(x: displayWidth / 2, y: displayHeight / 2)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .clipped()

                        let predictions = response.result.pred
                        
                        // Overlay rectangles based on the predictions
                        ForEach(Array(predictions.enumerated()), id: \.element.id) { index, prediction in
                            let bbox = prediction.bbox
                            let topLeft = CGPoint(x: bbox[0][0] * scale, y: bbox[0][1] * scale)
                            let bottomRight = CGPoint(x: bbox[1][0] * scale, y: bbox[1][1] * scale)
                            let width = bottomRight.x - topLeft.x
                            let height = bottomRight.y - topLeft.y

                            if prediction.prob >= 0.9 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.04))
                                    .stroke(self.selectedID == prediction.id ? Color.red.opacity(1.0) : Color.red.opacity(0.6), lineWidth: 1)
                                    .frame(width: width, height: height)
                                    .position(x: topLeft.x + width / 2, y: topLeft.y + height / 2)
                                    .onTapGesture {
                                        self.selectedID = prediction.id
                                    }
                            } else if prediction.prob >= 0.5 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.04))
                                    .stroke(self.selectedID == prediction.id ? Color.yellow.opacity(1.0) : Color.yellow.opacity(0.6), lineWidth: 1)
                                    .frame(width: width, height: height)
                                    .position(x: topLeft.x + width / 2, y: topLeft.y + height / 2)
                                    .onTapGesture {
                                        self.selectedID = prediction.id
                                    }
                            } else {
                                Rectangle()
                                    .fill(Color.white.opacity(0.04))
                                    .stroke(self.selectedID == prediction.id ? Color.black : Color.white.opacity(0.6), lineWidth: 1)
                                    .frame(width: width, height: height)
                                    .position(x: topLeft.x + width / 2, y: topLeft.y + height / 2)
                                    .onTapGesture {
                                        self.selectedID = prediction.id
                                    }
                            }
                            

                            // Optionally, display the index
                            /* Text("\(index)")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.75))
                                .position(x: topLeft.x, y: topLeft.y - 10)*/
                        }
                    }
                    .frame(width: displayWidth, height: displayHeight, alignment: .topLeading)
                }
                .aspectRatio(uiImage.size, contentMode: .fit)
            }
            .padding()
            
            if let selectedPred = getSelectedPred() {
                HStack {
                    if selectedPred.prob >= 0.9 {
                        Circle()
                            .fill(.red)
                            .frame(width: 4, height: 4)
                        
                        Text("충치 위험")
                            .font(.system(size: 15))
                            .foregroundColor(.defaultDarkGray)
                    } else if selectedPred.prob >= 0.5 {
                        Circle()
                            .fill(.yellow)
                            .frame(width: 4, height: 4)
                        
                        Text("충치 의심")
                            .font(.system(size: 15))
                            .foregroundColor(.defaultDarkGray)
                    } else {
                        Circle()
                            .fill(.green)
                            .frame(width: 4, height: 4)
                        
                        Text("충치 없음")
                            .font(.system(size: 15))
                            .foregroundColor(.defaultDarkGray)
                    }
                }
                .padding(.bottom, 4)
                
                Text("충치 확률: \(String(format: "%.2f", selectedPred.prob * 100))%")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)
                
                if selectedPred.prob >= 0.9 {
                    Text("충치일 확률이 매우 높으니 의사의 상담을 받아보세요.")
                        .font(.system(size: 15))
                        .fontWeight(.regular)
                        .foregroundStyle(.gray)
                    
                } else if selectedPred.prob >= 0.5 {
                    Text("충치일 확률이 있습니다.")
                        .font(.system(size: 15))
                        .fontWeight(.regular)
                        .foregroundStyle(.gray)
                }
                
            }
                
            Text("본 서비스는 개인 참고용으로만 사용해야 하며,\n부정확한 결과를 포함할 수 있습니다.\n실체 충치 여부는 반드시 의사와의\n상담을 통해 판단해야 합니다.\n본 서비스 사용의 책임은 사용자에게 있습니다.")
                .font(.system(size: 11))
                .fontWeight(.regular)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            
            Spacer()
            
            HStack(alignment: .center, spacing: 20) {
                Button {
                    // Share
                    /* if let data = viewModel.data {
                        shareImage(image: data.image[0])
                    }*/
                } label: {
                    VStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding(.bottom, 1)
                        
                        Text("공유")
                            .font(.system(size: 10))
                            .fontWeight(.regular)
                            .foregroundStyle(.gray)
                    }
                }
                
                Button {
                    // Save to Photo App
                    /* if let data = viewModel.data {
                        saveImageToPhotos(image: data.image[0])
                    }*/
                } label: {
                    VStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding(.bottom, 1)
                        
                        Text("저장")
                            .font(.system(size: 10))
                            .fontWeight(.regular)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding(.bottom)
        }
        .onAppear {
            // viewModel.fetchData()
        }
    }
    
    func shareImage(image: UIImage) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }
    
    func saveImageToPhotos(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func getSelectedPred() -> Prediction? {
        let preds = response.result.pred.filter( { $0.id == self.selectedID })
        
        if preds.isEmpty {
            return nil
        } else {
            return preds[0]
        }
    }
}

struct CavityCount {
    let warning: Int
    let danger: Int
}

#Preview {
    ResultView(viewModel: RootViewModel())
}
