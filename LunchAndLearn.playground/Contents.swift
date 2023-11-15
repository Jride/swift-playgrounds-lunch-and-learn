import SwiftUI
import PlaygroundSupport
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    
    var originalImage: UIImage {
        UIImage(named: imageOptions[selectedImageOption])!
    }
    
    let imageOptions = ["hello", "woman", "man", "halloween"]
    @State var selectedImageOption = 0
    
    @State var sepiaIntensity: Float = 0
    @State var saturation: Float = 0
    @State var brightness: Float = 0
    @State var contrast: Float = 0
    @State var twirlDistortionRadius: Float = 0
    
    @State private var filteredImage: UIImage?
    
    var body: some View {
        VStack(alignment: .center) {
            
            Text("Image Filter")
                .bold()
                .italic()
                .underline()
                .font(.largeTitle)
            
            Picker("Select an image", selection: $selectedImageOption) {
                ForEach(0..<4) {
                    Text(self.imageOptions[$0])
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedImageOption) { oldValue, newValue in
                reset()
            }
            
            Image(uiImage: (filteredImage ?? originalImage))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400)
            
            HStack {
                Text("Sepia Tone: \(String(format: "%.2f", sepiaIntensity))")
                Slider(value: $sepiaIntensity, in: 0...1) { _ in
                    applyFilters()
                }.padding(.trailing, 10)
                
            }.font(.caption).padding(.leading, 10)
            
            HStack {
                Text("Saturation: \(Int(saturation))")
                Slider(value: $saturation, in: -20...20, step: 1) { _ in
                    applyFilters()
                }.padding(.trailing, 10)
                
            }.font(.caption).padding(.leading, 10)
            
            HStack {
                Text("Brightness: \(String(format: "%.2f", brightness))")
                Slider(value: $brightness, in: 0...1) { _ in
                    applyFilters()
                }.padding(.trailing, 10)
                
            }.font(.caption).padding(.leading, 10)
            
            HStack {
                Text("Contrast: \(String(format: "%.2f", contrast))")
                Slider(value: $contrast, in: -5...5, step: 0.1) { _ in
                    applyFilters()
                }.padding(.trailing, 10)
                
            }.font(.caption).padding(.leading, 10)
            
            HStack {
                Text("Twirl Distortion: \(String(format: "%.2f", twirlDistortionRadius))")
                Slider(value: $twirlDistortionRadius, in: 0...500, step: 1) { _ in
                    applyFilters()
                }.padding(.trailing, 10)
                
            }.font(.caption).padding(.leading, 10)
        }
        .background(.yellow)
        .ignoresSafeArea()
    }
    
    func reset() {
        filteredImage = nil
        sepiaIntensity = 0
        saturation = 0
        brightness = 0
        contrast = 0
        twirlDistortionRadius = 0
    }
    
    func applyFilters() {
        
        var ciOutputImage: CIImage?
        
        let ciInput = CIImage(image: originalImage)
        
        let sepiaFilter = CIFilter.sepiaTone()
        sepiaFilter.inputImage = ciInput
        sepiaFilter.intensity = sepiaIntensity
        ciOutputImage = sepiaFilter.outputImage
        
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = ciOutputImage
        if saturation != 0 {
            colorFilter.saturation = saturation
        }
        colorFilter.brightness = brightness
        if contrast != 0 {
            colorFilter.contrast = contrast
        }
        ciOutputImage = colorFilter.outputImage
        
        let twirlDistortion = CIFilter.twirlDistortion()
        twirlDistortion.inputImage = ciOutputImage
        twirlDistortion.radius = twirlDistortionRadius
        twirlDistortion.center = centerOf(image: ciOutputImage!)
        ciOutputImage = twirlDistortion.outputImage
        
        // Convert the CIImage into a UIImage
        let context = CIContext()
        guard
            let ciOutputImage,
            let finalOutput = context.createCGImage(
                ciOutputImage,
                from: ciOutputImage.extent
            )
        else { return }
        
        filteredImage = UIImage(cgImage: finalOutput)
    }
    
    func centerOf(image: CIImage) -> CGPoint {
        let boundingBox = image.extent
        let centerX = boundingBox.origin.x + boundingBox.size.width / 2.0
        let centerY = boundingBox.origin.y + boundingBox.size.height / 2.0
        return CGPoint(x: centerX, y: centerY)
    }
}

PlaygroundPage.current.setLiveView(ContentView())
