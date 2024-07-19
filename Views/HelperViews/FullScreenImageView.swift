import SwiftUI

struct FullScreenImageView: View {
    let image: UIImage
    @Environment(\.presentationMode) var presentationMode
    
    @State private var dragOffset = CGSize.zero

    var body: some View {
        VStack {
            Spacer()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: .infinity)
                .offset(y: dragOffset.height)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 { // Only allow downward swipe
                                dragOffset = value.translation
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 100 { // Threshold to dismiss
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                dragOffset = .zero
                            }
                        }
                )
            Spacer()
        }
        .background(Color.black.opacity(0.7))
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct FullScreenImageView_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenImageView(image: UIImage(systemName: "photo")!)
    }
}
