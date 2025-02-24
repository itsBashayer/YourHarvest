//
//  CloudKitHelper.swift
//  Hassadak
//
//  Created by BASHAER AZIZ on 20/08/1446 AH.
//
import CloudKit
import SwiftUI

struct HistoryRecord: Identifiable {
    var id: CKRecord.ID
    var userName: String
    var date: Date
    var totalProducts: Int
}

class CloudKitHelper: ObservableObject {
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    @Published var historyRecords: [HistoryRecord] = []
    
    func saveHistory(userName: String, totalProducts: Int) {
        let record = CKRecord(recordType: "Account") // Changed to "Users"
        record["userName"] = userName
        record["date"] = Date()
        record["totalProducts"] = totalProducts
        
        privateDatabase.save(record) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error saving record: \(error.localizedDescription)")
                } else {
                    print("✅ Successfully saved record!")
                    self.fetchHistory()
                }
            }
        }
    }
    
    func fetchHistory() {
        let query = CKQuery(recordType: "Account", predicate: NSPredicate(value: true)) // Changed to "Users"
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let records = records {
                    self.historyRecords = records.map { record in
                        HistoryRecord(
                            id: record.recordID,
                            userName: record["userName"] as? String ?? "Unknown",
                            date: record["date"] as? Date ?? Date(),
                            totalProducts: record["totalProducts"] as? Int ?? 0
                        )
                    }
                    print("✅ Successfully fetched \(records.count) records!")
                } else {
                    print("❌ Error fetching records: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}

// MARK: - Mock Data for SwiftUI Previews
class MockCloudKitHelper: CloudKitHelper {
    override init() {
        super.init()
        self.historyRecords = [
            HistoryRecord(id: CKRecord.ID(recordName: "1"), userName: "Alice", date: Date(), totalProducts: 5),
            HistoryRecord(id: CKRecord.ID(recordName: "2"), userName: "Bob", date: Date(), totalProducts: 12)
        ]
    }
}
