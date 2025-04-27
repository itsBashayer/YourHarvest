import SwiftUI
import CloudKit

struct HistoryView: View {
    @ObservedObject var cloudKitHelper: CloudKitHelper // ✅ Ensures CloudKitHelper is correctly used
    @State private var showPopup = false
    @State private var pdfURL: URL? // ✅ Stores generated PDF file
    @State private var selectedRecord: HistoryRecord? // ✅ Stores the selected record for the popup

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text("History")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("green"))

                    // ✅ ScrollView added to allow scrolling
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if cloudKitHelper.historyRecords.isEmpty {
                                Text("No history available.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(cloudKitHelper.historyRecords) { record in
                                    Button {
                                        selectedRecord = record // ✅ Store the selected record
                                        generatePDF(record: record, geometry: geometry) // ✅ Generate PDF when clicking
                                        showPopup = true
                                    } label: {
                                        HStack(spacing: 16) {
                                            Image("bannerimage")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: min(geometry.size.width * 0.15, 56), height: min(geometry.size.width * 0.15, 56))

                                            VStack(alignment: .leading) {
                                                Text(record.itemName)
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)

                                                // ✅ Show correct date for each record
                                                Text(formatDate(record.date))
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()

                                            Text("\(record.totalProducts) \(NSLocalizedString("pieces", comment: ""))")
                                                .font(.headline)
                                                .foregroundColor(Color("green"))
                                                .lineLimit(1)
                                        }
                                        .padding(.vertical, 0)
                                        .padding(.horizontal, 0)
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(geometry.size.width * 0.05)
                .onAppear {
                    print("📡 HistoryView appeared, fetching history...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // ✅ Ensure history is fully loaded before showing
                        cloudKitHelper.fetchHistory()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HistoryUpdated"))) { _ in
                    print("🔄 History updated, refreshing...")
                    DispatchQueue.main.async {
                        cloudKitHelper.fetchHistory()
                    }
                }

                // ✅ Popup for viewing & sharing PDF
                if showPopup, let record = selectedRecord {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showPopup = false
                        }

                    VStack(spacing: 16) {
                        // ✅ Display the Report Card for the selected record
                        CutoutReportCard(
                            itemName: record.itemName,
                            totalProducts: record.totalProducts,
                            date: formatDate(record.date),
                            userName: record.userName,
                            showShape: true,
                            geometry: geometry
                        )

                        // ✅ Share Button (Positioned Below the Popup)
                        if let pdfURL = pdfURL {
                            ShareLink(item: pdfURL, preview: SharePreview("Report", image: Image(systemName: "doc"))) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Export Report")
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
                    .padding()
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .frame(width: geometry.size.width * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // ✅ Keeps popup centered
                }
            }
        }
    }

    // ✅ Format the date correctly
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // ✅ Generate PDF for a selected record
    private func generatePDF(record: HistoryRecord, geometry: GeometryProxy) {
        let cardView = CutoutReportCard(
            itemName: record.itemName,
            totalProducts: record.totalProducts,
            date: formatDate(record.date),
            userName: record.userName,
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
            print("❌ Error writing PDF data: \(error)")
        }
    }

    // ✅ Render SwiftUI view as PDF
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
        HistoryView(cloudKitHelper: CloudKitHelper()) // ✅ Fixed missing CloudKitHelper argument
    }
}
// last
