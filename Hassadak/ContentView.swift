//
//  ContentView.swift
//  Hassadak
//
//  Created by BASHAER AZIZ on 20/08/1446 AH.
//
//
import SwiftUI
import CloudKit

struct ContentView: View {
    @StateObject private var cloudKitHelper = CloudKitHelper()
    
    var body: some View {
        NavigationView {
            VStack {
                List(cloudKitHelper.historyRecords) { record in
                    VStack(alignment: .leading) {
                        Text("User: \(record.userName)")
                            .font(.headline)
                        Text("Date: \(record.date, formatter: dateFormatter)")
                            .font(.subheadline)
                        Text("Total Products: \(record.totalProducts)")
                            .font(.subheadline)
                    }
                }
                Button("Add Test History") {
                    cloudKitHelper.saveHistory(userName: "Test User", totalProducts: Int.random(in: 1...100))
                }
                .padding()
            }
            .navigationTitle("History Records")
            .onAppear {
                cloudKitHelper.fetchHistory()
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct HistoryContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(MockCloudKitHelper()) // Using Mock Data for Previews
    }
}
