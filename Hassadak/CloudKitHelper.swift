import SwiftUI
import CloudKit

// MARK: - Data Model
struct HistoryRecord: Identifiable {
    var id: CKRecord.ID
    var userName: String
    var date: Date
    var totalProducts: Int
    var itemName: String
    var userReference: CKRecord.Reference?
}

// MARK: - CloudKit Helper
class CloudKitHelper: ObservableObject {
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    private let container = CKContainer.default()
    
    @Published var historyRecords: [HistoryRecord] = []
    @Published var currentUserRecordID: CKRecord.ID?

    // ✅ Ensure User Record is Fetched Before Fetching History
    init() {
        fetchUserRecordID { recordID in
            if recordID != nil {
                self.fetchHistory() // ✅ Only fetch history AFTER getting user ID
            }
        }
    }

    // ✅ Step 1: Fetch User Record ID Before Fetching History
    private func fetchUserRecordID(completion: @escaping (CKRecord.ID?) -> Void) {
        container.fetchUserRecordID { recordID, error in
            DispatchQueue.main.async {
                if let recordID = recordID {
                    self.currentUserRecordID = recordID
                    print("✅ User record ID fetched: \(recordID.recordName)")
                    completion(recordID)
                } else {
                    print("❌ Error fetching user record ID: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
    }

    // ✅ Step 2: Save History with Correct User Reference
    func saveHistory(userName: String, totalProducts: Int, itemName: String) {
        if currentUserRecordID == nil {
            fetchUserRecordID { recordID in
                guard let recordID = recordID else {
                    print("❌ Could not fetch user record ID. Save aborted.")
                    return
                }
                self.currentUserRecordID = recordID
                self.saveHistory(userName: userName, totalProducts: totalProducts, itemName: itemName) // Retry saving
            }
            return
        }

        guard let userID = currentUserRecordID else {
            print("❌ No User ID available! Cannot save.")
            return
        }

        let historyRecord = CKRecord(recordType: "Account")
        historyRecord["userName"] = userName
        historyRecord["date"] = Date()
        historyRecord["totalProducts"] = totalProducts
        historyRecord["itemName"] = itemName

        let userReference = CKRecord.Reference(recordID: userID, action: .none)
        historyRecord["userReference"] = userReference // ✅ Correctly assign user reference

        print("📢 Saving history record:")
        print("🔹 userName: \(userName)")
        print("🔹 totalProducts: \(totalProducts)")
        print("🔹 itemName: \(itemName)")
        print("🔹 userReference: \(userReference.recordID.recordName)")

        privateDatabase.save(historyRecord) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error saving Account record: \(error.localizedDescription)")
                } else {
                    print("✅ Successfully saved history record!")
                    NotificationCenter.default.post(name: NSNotification.Name("HistoryUpdated"), object: nil)
                    self.fetchHistory() // ✅ Fetch updated history immediately
                }
            }
        }
    }

    // ✅ Step 3: Fetch History After Ensuring currentUserRecordID is Set
    func fetchHistory() {
        if currentUserRecordID == nil {
            fetchUserRecordID { recordID in
                guard let recordID = recordID else {
                    print("❌ No User ID available! Cannot fetch history.")
                    return
                }
                self.fetchHistory() // ✅ Retry fetching history after getting user ID
            }
            return
        }

        guard let userID = currentUserRecordID else {
            print("❌ No User ID available! Cannot fetch history.")
            return
        }

        let userReference = CKRecord.Reference(recordID: userID, action: .none)
        let predicate = NSPredicate(format: "userReference == %@", userReference)
        let query = CKQuery(recordType: "Account", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)] // Fetch latest first

        print("📡 Fetching history for user ID: \(userID.recordName)")

        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error fetching history: \(error.localizedDescription)")
                    return
                }

                guard let records = records, !records.isEmpty else {
                    print("⚠️ No history records found in CloudKit!")
                    self.historyRecords = []
                    return
                }

                // ✅ Ensure the stored userName is retrieved correctly
                self.historyRecords = records.map { record in
                    let storedUserName = record["userName"] as? String ?? "Unknown" // ✅ Ensures username is retrieved
                    
                    return HistoryRecord(
                        id: record.recordID,
                        userName: storedUserName, // ✅ Use stored username (from user input)
                        date: record["date"] as? Date ?? Date(),
                        totalProducts: record["totalProducts"] as? Int ?? 0,
                        itemName: record["itemName"] as? String ?? "No Item",
                        userReference: record["userReference"] as? CKRecord.Reference
                    )
                }

                print("✅ Successfully fetched \(self.historyRecords.count) history records!")
                if let latest = self.historyRecords.first {
                    print("🆕 Latest Record: \(latest.itemName) - \(latest.totalProducts) pieces - \(latest.date) - \(latest.userName)")
                }
            }
        }
    }
}
