
import SwiftUI

struct CutoutReportCard: View {
    var itemName: String
    var totalProducts: Int // ✅ Updated from itemQTY
    var date: String
    var userName: String // ✅ Added userName
    var showShape: Bool = true
    var geometry: GeometryProxy

    var body: some View {
        ZStack {
            if showShape {
                CircleCutoutShape()
                    .fill(style: FillStyle(eoFill: true))
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.6)
                    .shadow(color: Color.primary.opacity(0.3), radius: 8, x: 0, y: 2)
            } else {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.6)
            }

            VStack(alignment: .leading, spacing: 20) {
                Text("Report")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("From:") // ✅ Display userName
                            .fontWeight(.semibold)
                        Text(userName)
                    }
                    
                    HStack {
                        Text("Date:")
                            .fontWeight(.semibold)
                        Text(date)
                    }
                }
                .foregroundColor(.primary)

                VStack(spacing: 0) {
                    HStack {
                        Text("Item Name")
                            .bold()
                        Spacer()
                        Text("Quantity")
                            .bold()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Divider()

                    HStack {
                        Text(itemName)
                        Spacer()
                        Text("\(totalProducts)") // ✅ Updated variable name
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
            .padding(.horizontal, geometry.size.width * 0.05)
        }
        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.6)
    }
}
