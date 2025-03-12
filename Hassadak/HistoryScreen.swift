
import SwiftUI

struct HistoryView: View {
    @State private var showPopup = false
    @State private var pdfURL: URL?
    var itemName: String // ✅ Renamed from selectedItemName
    var totalProducts: Int // ✅ Renamed from selectedItemQTY
    var date: String // ✅ Renamed from captureDate
    var userName: String // ✅ Accept userName

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text("History")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("green"))

                    // ✅ Displays the capture date
                    Text(date) // ✅ Updated variable name
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    VStack(alignment: .leading, spacing: 16) {
                        Button {
                            showPopup = true
                        } label: {
                            HStack(spacing: 16) {
                                Image("bannerimage")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: min(geometry.size.width * 0.15, 56), height: min(geometry.size.width * 0.15, 56))

                                VStack(alignment: .leading) {
                                    Text(itemName.isEmpty ? "" : itemName) // ✅ Updated variable name
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                Text("\(totalProducts) pieces") // ✅ Updated variable name
                                    .font(.headline)
                                    .foregroundColor(Color("green"))
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 0)
                            .padding(.horizontal, 0)
                            .frame(maxWidth: .infinity)
                        }

                        Spacer()
                    }

                    Spacer()
                }
                .padding(geometry.size.width * 0.05)
                .onAppear {
                    generatePDF(geometry: geometry) // ✅ Automatically generate PDF on load
                }

                if showPopup {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showPopup = false
                        }

                    VStack(spacing: 16) {
                        // ✅ Pass `userName` to CutoutReportCard
                        CutoutReportCard(
                            itemName: itemName, // ✅ Updated variable name
                            totalProducts: totalProducts, // ✅ Updated variable name
                            date: date, // ✅ Updated variable name
                            userName: userName, // ✅ Pass userName
                            showShape: true,
                            geometry: geometry
                        )

                        if let pdfURL = pdfURL {
                            ShareLink(item: pdfURL, preview: SharePreview("Report", image: Image(systemName: "doc"))) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Report")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 56)
                                .frame(maxWidth: geometry.size.width * 0.8)
                                .background(Color("green"))
                                .cornerRadius(12)
                            }
                        } else {
                            Text("Generating Report...")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(geometry.size.width * 0.05)
                }
            }
        }
    }

    // ✅ Generates and saves the PDF automatically
    private func generatePDF(geometry: GeometryProxy) {
        let cardView = CutoutReportCard(
            itemName: itemName, // ✅ Updated variable name
            totalProducts: totalProducts, // ✅ Updated variable name
            date: date, // ✅ Updated variable name
            userName: userName, // ✅ Added userName
            showShape: false,
            geometry: geometry
        )

        let pdfData = renderViewAsPDF(cardView, size: CGSize(width: geometry.size.width * 0.8, height: geometry.size.height * 0.6))
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Report.pdf")

        do {
            try pdfData.write(to: tempURL)
            DispatchQueue.main.async {
                self.pdfURL = tempURL // ✅ Updates the PDF URL once generated
            }
        } catch {
            print("Error writing PDF data: \(error)")
        }
    }

    private func renderViewAsPDF<Content: View>(_ view: Content, size: CGSize) -> Data {
        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(origin: .zero, size: size)
        controller.view.layoutIfNeeded()
        controller.view.backgroundColor = .white
        controller.overrideUserInterfaceStyle = .light

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: controller.view.bounds)
        return pdfRenderer.pdfData { context in
            context.beginPage()
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

// ✅ Keeps preview functionality without passing arguments
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(itemName: "", totalProducts: 0, date: "", userName: "Preview User") // ✅ Updated variable names
    }
}
