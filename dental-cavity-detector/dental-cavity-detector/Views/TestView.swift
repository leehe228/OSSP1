//
//  TestView.swift
//  dental-cavity-detector
//
//  Created by Hoeun Lee on 6/20/24.
//

import SwiftUI

struct TestView: View {
    // State to hold the UIImage
    @State private var image: UIImage? = UIImage(named: "dummy")
    // Sample data received from the server
    @State private var predictions: [Prediction] = [
        Prediction(cls: "1", prob: 0.6125039458274841, bbox: [[899.0, 360.0], [1179.0, 708.0]]),
        Prediction(cls: "0", prob: 0.5152251720428467, bbox: [[1259.0, 90.0], [1556.0, 434.0]]),
        Prediction(cls: "0", prob: 0.7162580490112305, bbox: [[1146.0, 361.0], [1415.0, 702.0]]),
        Prediction(cls: "0", prob: 0.5437758564949036, bbox: [[896.0, 22.0], [1296.0, 431.0]]),
        Prediction(cls: "1", prob: 0.8114379048347473, bbox: [[453.0, 361.0], [710.0, 689.0]]),
        Prediction(cls: "0", prob: 0.5151708722114563, bbox: [[249.0, 365.0], [483.0, 662.0]]),
        Prediction(cls: "0", prob: 0.8830989599227905, bbox: [[291.0, 41.0], [579.0, 387.0]]),
        Prediction(cls: "0", prob: 0.9298536777496338, bbox: [[563.0, 16.0], [923.0, 397.0]]),
        Prediction(cls: "1", prob: 0.7100352048873901, bbox: [[679.0, 391.0], [922.0, 696.0]]),
        Prediction(cls: "0", prob: 0.7699751257896423, bbox: [[1383.0, 394.0], [1634.0, 695.0]]),
        Prediction(cls: "0", prob: 0.6822678446769714, bbox: [[91.0, 375.0], [313.0, 626.0]])
    ]
    
    var body: some View {
        VStack {
            if let uiImage = image {
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

                        // Overlay rectangles based on the predictions
                        ForEach(Array(predictions.enumerated()), id: \.element.id) { index, prediction in
                            let bbox = prediction.bbox
                            let topLeft = CGPoint(x: bbox[0][0] * scale, y: bbox[0][1] * scale)
                            let bottomRight = CGPoint(x: bbox[1][0] * scale, y: bbox[1][1] * scale)
                            let width = bottomRight.x - topLeft.x
                            let height = bottomRight.y - topLeft.y

                            Rectangle()
                                .stroke(prediction.cls == "1" ? Color.red : Color.blue, lineWidth: 2)
                                .frame(width: width, height: height)
                                .position(x: topLeft.x + width / 2, y: topLeft.y + height / 2)

                            // Optionally, display the index
                            Text("\(index)")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.75))
                                .position(x: topLeft.x, y: topLeft.y - 10)
                        }
                    }
                    .frame(width: displayWidth, height: displayHeight, alignment: .topLeading)
                }
                .aspectRatio(uiImage.size, contentMode: .fit)
            } else {
                Text("No Image")
            }
        }
        .padding()
    }
}

#Preview {
    TestView()
}
