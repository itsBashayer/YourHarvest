import SwiftUI
import UIKit

// MARK: - 1) HistoryView (and everything in it)

/// A ButtonStyle that shows a faint gray border normally, and a green border (Color("green")) when selected.
struct PersistentGreenBorderStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color("green") : Color.gray.opacity(0.2), lineWidth: 2)
            )
    }
}

struct HistoryView: View {
    // States for controlling the popup, banner selection, etc.
    @State private var showPopup = false
    @State private var selectedItemName = ""
    @State private var selectedItemQTY = 0
    @State private var userName = "Younes123"
    @State private var showShareSheet = false
    @State private var pdfURL: URL?

    // Controls the persistent green border on the banner
    @State private var isBannerSelected = false

    // Current date for display
    private let currentDate = Date()

    var body: some View {
        ZStack {
            // Main content
            VStack(alignment: .leading, spacing: 16) {
                Text("History")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("green"))

                Text(Formatter.date.string(from: currentDate))
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Banner button container
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        // On tap, set states and show the popup
                        selectedItemName = "Tomato"
                        selectedItemQTY = 60
                        isBannerSelected = true
                        showPopup = true
                    } label: {
                        HStack(spacing: 16) {
                            Image("bannerimage")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 56, height: 56)

                            Text("Today's Tomato")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            Spacer()

                            Text("60 pieces")
                                .font(.headline)
                                .foregroundColor(Color("green"))
                                .lineLimit(1)
                        }
                        .padding(.vertical, 0)
                        .padding(.horizontal, 0)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PersistentGreenBorderStyle(isSelected: isBannerSelected))

                    // Push the banner up
                    Spacer()
                }

                Spacer()
            }
            .padding()
            // If the popup closes, reset the banner selection
            .onChange(of: showPopup) { newValue in
                if !newValue {
                    isBannerSelected = false
                }
            }

            // The popup overlay
            if showPopup {
                // Dim background
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPopup = false
                    }

                VStack(spacing: 16) {
                    // Show the cutout card
                    CutoutReportCard(
                        userName: userName,
                        itemName: selectedItemName,
                        itemQTY: selectedItemQTY,
                        date: currentDate,
                        showShape: true
                    )

                    Button("Share") {
                        shareReportAsPDF()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 56)
                    .frame(maxWidth: 350)
                    .background(Color("green"))
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        // Show the share sheet for the PDF
        .sheet(isPresented: $showShareSheet) {
            if let pdfURL = pdfURL {
                ActivityViewController(activityItems: [pdfURL])
            } else {
                Text("No PDF available.")
            }
        }
    }

    // Generate and share a PDF
    private func shareReportAsPDF() {
        // We pass showShape = false to remove the cutout shape in the PDF
        let cardView = CutoutReportCard(
            userName: userName,
            itemName: selectedItemName,
            itemQTY: selectedItemQTY,
            date: currentDate,
            showShape: false
        )

        let pdfData = renderViewAsPDF(cardView)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Report.pdf")

        do {
            try pdfData.write(to: tempURL)
            pdfURL = tempURL
            showShareSheet = true
        } catch {
            print("Error writing PDF data: \(error)")
        }
    }

    // Renders any SwiftUI view as PDF data
    private func renderViewAsPDF<Content: View>(_ view: Content) -> Data {
        let targetSize = CGSize(width: 350, height: 400)
        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(origin: .zero, size: targetSize)
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

// MARK: - 2) Report Card

/// A custom shape with a circular cutout at the top.
struct CircleCutoutShape: Shape {
    var cornerRadius: CGFloat = 20
    var holeRadius: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let midX = rect.midX

        // Move to top-left corner
        path.move(to: CGPoint(x: 0, y: cornerRadius))

        // Top-left corner arc
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        // Up to left edge of hole
        path.addLine(to: CGPoint(x: midX - holeRadius, y: 0))

        // Inward hole
        path.addArc(
            center: CGPoint(x: midX, y: 0),
            radius: holeRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: true
        )

        // Top-right corner arc
        path.addLine(to: CGPoint(x: w - cornerRadius, y: 0))
        path.addArc(
            center: CGPoint(x: w - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(360),
            clockwise: false
        )

        // Right edge
        path.addLine(to: CGPoint(x: w, y: h - cornerRadius))
        path.addArc(
            center: CGPoint(x: w - cornerRadius, y: h - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: cornerRadius, y: h))
        path.addArc(
            center: CGPoint(x: cornerRadius, y: h - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // Close
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        return path
    }
}

/// The card showing "Report" info, optionally with a circular top cutout.
struct CutoutReportCard: View {
    var userName: String
    var itemName: String
    var itemQTY: Int
    var date: Date
    var showShape: Bool = true

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()

    var body: some View {
        ZStack {
            if showShape {
                CircleCutoutShape()
                    .fill(style: FillStyle(eoFill: true))
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(width: 350, height: 400)
                    .shadow(color: Color.primary.opacity(0.3), radius: 8, x: 0, y: 2)
            } else {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 350, height: 400)
            }

            VStack(alignment: .leading, spacing: 20) {
                Text("Report")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("From:")
                            .fontWeight(.semibold)
                        Text(userName)
                    }
                    HStack {
                        Text("Date:")
                            .fontWeight(.semibold)
                        Text(dateFormatter.string(from: date))
                    }
                }
                .foregroundColor(.primary)

                VStack(spacing: 0) {
                    HStack {
                        Text("Items name")
                            .bold()
                        Spacer()
                        Text("QTY")
                            .bold()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Divider()

                    HStack {
                        Text(itemName)
                        Spacer()
                        Text("\(itemQTY)")
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .foregroundColor(.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )

                Spacer()
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image("logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .padding([.trailing, .bottom], 20)
                                    .padding([.leading, .bottom], 20)
                            }
                        }
        }
        .frame(width: 350, height: 400)
    }
}

// MARK: - 3) Sharing Part

/// A basic date formatter used by the HistoryView
struct Formatter {
    static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
}

/// A simple UIActivityViewController for sharing items (like PDFs).
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
