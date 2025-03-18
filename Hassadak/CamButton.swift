import SwiftUI
import AVFoundation

struct CamButton: View {
    @State private var showInstructions = true
    @State private var selectedNavItem: String? = nil
    @State private var showHistoryView = false
    @State private var itemName: String = ""
    @State private var totalProducts: Int = 0
    @State private var date: String = ""

    var userName: String
    var capturePhotoAction: () -> Void
    @ObservedObject var cloudKitHelper: CloudKitHelper // ✅ Accept CloudKitHelper instance

    let soundPlayer = SoundPlayer()

    var body: some View {
        ZStack {
            VStack {
                Spacer()

                if showInstructions {
                    InstructionBox(showInstructions: $showInstructions)
                }

                Spacer()

                BottomNavBar(
                    showInstructions: $showInstructions,
                    selectedNavItem: $selectedNavItem,
                    showHistoryView: $showHistoryView,
                    itemName: $itemName,
                    totalProducts: $totalProducts,
                    date: $date,
                    userName: userName,
                    capturePhotoAction: {
                        soundPlayer.playSound()
                        capturePhotoAction()
                    },
                    cloudKitHelper: cloudKitHelper // ✅ Ensure cloudKitHelper is used
                )
            }
        }
        .fullScreenCover(isPresented: $showHistoryView) {
            NavigationStack {
                HistoryView(cloudKitHelper: cloudKitHelper) // ✅ Only pass cloudKitHelper
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: { showHistoryView = false }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(Color("green"))
                                    Text("Back")
                                        .foregroundColor(Color("green"))
                                }
                            }
                        }
                    }
            }
        }

        .onAppear {
            print("📡 CamButton appearing - fetching history")
            cloudKitHelper.fetchHistory()
        }
    }
}
    
    
    struct InstructionBox: View {
        @Binding var showInstructions: Bool
        
        var body: some View {
            VStack(spacing: 12) {
                InstructionRow(imageName: "adjust", text: NSLocalizedString("Adjust on wide view", comment: "Instruction text"))
                InstructionRow(imageName: "arrange", text: NSLocalizedString("Arrange vegetables neatly", comment: "Instruction text"))
                InstructionRow(imageName: "surface", text: NSLocalizedString("Use a flat surface", comment: "Instruction text"))
                InstructionRow(imageName: "light", text: NSLocalizedString("Ensure good lighting", comment: "Instruction text"))

                
                Divider()
                
                Button("Done") {
                    showInstructions = false
                }
                .foregroundColor(Color("green"))
                .padding(.top, 4)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(radius: 5)
            .frame(width: 280)
        }
    }
    
    struct InstructionRow: View {
        var imageName: String
        var text: String
        
        var body: some View {
            HStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34.31, height: 34.31)
                
                Text(text)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                
                Spacer()
            }
        }
    }
    
    //struct BottomNavBar: View {
    //    @Binding var showInstructions: Bool
    //    @Binding var selectedNavItem: String?
    //    @Binding var showHistoryView: Bool
    //    @Binding var itemName: String
    //    @Binding var totalProducts: Int
    //    @Binding var date: String
    //    var userName: String
    //    var capturePhotoAction: () -> Void
    //
    //    var body: some View {
    //        HStack {
    //            NavBarItem(imageName: "history", text: "History", selectedNavItem: $selectedNavItem) {
    //                itemName = "Tomato"
    //                totalProducts = 3
    //                date = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
    //
    //                showHistoryView = true
    //            }
    //
    //            NavBarItem(imageName: "counter", text: "Counter", selectedNavItem: $selectedNavItem, action: {
    //                capturePhotoAction()
    //            })
    //
    //            NavBarItem(imageName: "Instructions", text: "Instructions", selectedNavItem: $selectedNavItem) {
    //                showInstructions = true
    //            }
    //        }
    //    }
    //}


struct BottomNavBar: View {
    @Binding var showInstructions: Bool
    @Binding var selectedNavItem: String?
    @Binding var showHistoryView: Bool
    @Binding var itemName: String
    @Binding var totalProducts: Int
    @Binding var date: String
    var userName: String
    var capturePhotoAction: () -> Void
    @ObservedObject var cloudKitHelper: CloudKitHelper
    
    var body: some View {
        HStack {
            NavBarItem(imageName: "history", text: NSLocalizedString("History", comment: "Navigation Bar Item"), selectedNavItem: $selectedNavItem)
 {
                
                // ✅ Fetch the latest history data BEFORE navigating
                cloudKitHelper.fetchHistory()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // ✅ Ensuring fetchHistory() completes
                    if !cloudKitHelper.historyRecords.isEmpty {
                        let latestRecord = cloudKitHelper.historyRecords.first!
                        itemName = latestRecord.itemName
                        totalProducts = latestRecord.totalProducts
                        date = DateFormatter.localizedString(from: latestRecord.date, dateStyle: .medium, timeStyle: .short)
                    } else {
                        itemName = "No Data"
                        totalProducts = 0
                        date = "Unknown"
                    }
                    
                    print("✅ Navigating to HistoryView with: \(itemName), \(totalProducts), \(date)")
                    showHistoryView = true
                }
            }

            NavBarItem(imageName: "count", text: NSLocalizedString("count", comment: "Navigation Bar Item"), selectedNavItem: $selectedNavItem, action: {
                capturePhotoAction()
            })

       
            
            NavBarItem(imageName: "Instructions", text: NSLocalizedString("Instructions", comment: "Navigation Bar Item"), selectedNavItem: $selectedNavItem) {
                showInstructions = true
            

            }
        }
    }
}

    
    
    
    struct NavBarItem: View {
        var imageName: String
        var text: String
        @Binding var selectedNavItem: String?
        var action: (() -> Void)?
        
        var isSelected: Bool {
            selectedNavItem == text
        }
        
        var body: some View {
            VStack {
                Button(action: {
                    selectedNavItem = text
                    action?()
                }) {
                    ZStack {
                        Circle()
                            .fill(isSelected && text == "Counter" ? Color("green") : Color(.systemGray5))
                            .frame(
                                width: text == "Counter" ? 90.63 : 71.84,
                                height: text == "Counter" ? 90.85 : 73.34
                            )
                        
                        Image(isSelected && text == "Counter" ? "white_counter" : imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: text == "Counter" ? 55.62 : 44.88,
                                height: text == "Counter" ? 55.58 : 44.86
                            )
                            .foregroundColor(isSelected && text == "Counter" ? .white : .gray)
                    }
                }
                
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? Color("green") : .gray)
            }
            .padding(.horizontal, 22)
        }
    }
    
    class SoundPlayer {
        var player: AVAudioPlayer?
        
        func playSound() {
            if let soundURL = Bundle.main.url(forResource: "CounterSound", withExtension: "mp3") {
                do {
                    player = try AVAudioPlayer(contentsOf: soundURL)
                    player?.play()
                } catch {
                    print("Error playing sound: \(error.localizedDescription)")
                }
            } else {
                print("Sound file not found!")
            }
        }
    }
