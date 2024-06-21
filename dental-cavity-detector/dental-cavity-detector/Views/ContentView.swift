//
//  ContentView.swift
//  dental-cavity-detector
//
//  Created by Hoeun Lee on 6/11/24.
//

import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @ObservedObject var viewModel: RootViewModel
    
    @State private var selectedImageList: [UIImage] = []
    
    @State private var isPrivacyAlertPresented: Bool = false
    @State private var isServiceAgreeAlertPresented: Bool = false
    @State private var isPhotoPickerPresented: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text("충치 예측 서비스")
                .bold()
                .font(.system(size: 20))
                .padding(.top, 10)
            
            Text("구강 내를 촬영한 사진을 선택해주세요.")
                .fontWeight(.regular)
                .font(.system(size: 15))
                .padding(.top, 2)
            
            Spacer()
            
            HStack(alignment: .center) {
                
                ForEach(selectedImageList, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipped()
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                        .padding(.trailing, 4)
                        .onTapGesture {
                            if let index = selectedImageList.firstIndex(of: image) {
                                selectedImageList.remove(at: index)
                            }
                        }
                }
                
                if selectedImageList.count < 1 {
                    Button {
                        isPhotoPickerPresented = true
                    } label: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 45, height: 45)
                            .overlay {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .bold()
                            }
                    }
                    .sheet(isPresented: $isPhotoPickerPresented) {
                        PhotoPicker(selectedImageList: $selectedImageList)
                    }
                }
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Text("개인정보수집 및 처리방침")
                    .fontWeight(.regular)
                    .font(.system(size: 12))
                    .underline()
                    .foregroundStyle(.black)
            }
            
            Button {
                isPrivacyAlertPresented.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 15)
                    .frame(height: 52)
                    .padding()
                    .overlay {
                        Text(selectedImageList.isEmpty ? "사진을 선택해주세요" : "신청")
                            .bold()
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                    }
            }
            .disabled(selectedImageList.isEmpty)
        }
        .alert("개인정보수집 및 처리방침", isPresented: $isPrivacyAlertPresented, actions: {
            Button("동의합니다") {
                isServiceAgreeAlertPresented.toggle()
            }
            Button("취소", role: .cancel) {
                
            }
        }, message: {
            Text("사용자는 충치 예측 서비스의 개인정보수집 및 처리방침을 확인하였으며 동의합니다.")
        })
        .alert("서비스 이용 안내", isPresented: $isServiceAgreeAlertPresented, actions: {
            Button("동의합니다") {
                viewModel.loadingStart()
                
                viewModel.uploadImages(selectedImageList) { result in
                    switch result {
                    case .success(let responseString):
                        print("Upload successful: \(responseString)")
                    case .failure(let error):
                        print("Upload failed: \(error.localizedDescription)")
                        self.selectedImageList = []
                    }
                }
                
            }
            Button("취소", role: .cancel) {
                
            }
        }, message: {
            Text("본 서비스는 개인 참고용으로만 사용해야 하며, 부정확한 결과를 포함할 수 있습니다.\n실체 충치 여부는 반드시 의사와의 상담을 통해 판단해야 합니다. 본 서비스 사용의 책임은 사용자에게 있음을 동의합니다.")
        })
    }
    
    
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImageList: [UIImage]

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImageList.append(image)
                            }
                        }
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 3 - selectedImageList.count

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

}

#Preview {
    ContentView(viewModel: RootViewModel())
}

extension UIDevice {
    var deviceToken: String {
        if let identifierForVendor = UIDevice.current.identifierForVendor {
            return identifierForVendor.uuidString
        } else {
            return ""
        }
    }
}
