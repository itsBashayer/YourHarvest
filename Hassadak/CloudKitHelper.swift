//
//  CloudKitHelper.swift
//  Hassadak
//
//  Created by BASHAER AZIZ on 20/08/1446 AH.
//
import SwiftUI
import CloudKit

// MARK: - Data Model
struct HistoryRecord: Identifiable {
    var id: CKRecord.ID
    var userName: String
    var date: Date
    var totalProducts: Int
    var itemName: String  // ✅ Added itemName
    var userReference: CKRecord.Reference? // Reference to Users record
}

// MARK: - CloudKit Helper
class CloudKitHelper: ObservableObject {
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    private let container = CKContainer.default()
    
    @Published var historyRecords: [HistoryRecord] = []
    @Published var currentUserRecordID: CKRecord.ID?
    
    init() {
        fetchUserRecordID()
    }
    
    // ✅ Step 1: Fetch the CloudKit User Record ID
    private func fetchUserRecordID() {
        container.fetchUserRecordID { recordID, error in
            DispatchQueue.main.async {
                if let recordID = recordID {
                    self.currentUserRecordID = recordID
                    print("✅ User record ID fetched: \(recordID.recordName)")
                } else {
                    print("❌ Error fetching user record ID: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    // ✅ Step 2: Save an Account record linked to Users
    func saveHistory(userName: String, totalProducts: Int, itemName: String) {
        guard let userID = currentUserRecordID else {
            print("❌ No User ID available!")
            return
        }
        
        let accountRecord = CKRecord(recordType: "Account")
        accountRecord["userName"] = userName
        accountRecord["date"] = Date()
        accountRecord["totalProducts"] = totalProducts
        accountRecord["itemName"] = itemName  // ✅ Added itemName
        
        // ✅ Create a reference to the User record
        let userReference = CKRecord.Reference(recordID: userID, action: .none)
        accountRecord["userReference"] = userReference
        
        privateDatabase.save(accountRecord) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error saving Account record: \(error.localizedDescription)")
                } else {
                    print("✅ Successfully saved Account record!")
                    self.fetchHistory()
                }
            }
        }
    }
    
    // ✅ Step 3: Fetch Account records linked to the current user
    func fetchHistory() {
        guard let userID = currentUserRecordID else {
            print("❌ No User ID available to fetch accounts!")
            return
        }
        
        let predicate = NSPredicate(format: "userReference == %@", userID)
        let query = CKQuery(recordType: "Account", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let records = records {
                    // ✅ Step 1: Check if shouldClearCache is set to true
                    if let firstRecord = records.first, let shouldClearCache = firstRecord["shouldClearCache"] as? Bool, shouldClearCache {
                        print("🔄 Clearing local cache before fetching new data")
                        self.historyRecords.removeAll()
                        
                        // ✅ Reset shouldClearCache to false after clearing
                        firstRecord["shouldClearCache"] = false
                        self.privateDatabase.save(firstRecord) { _, error in
                            if let error = error {
                                print("❌ Error resetting shouldClearCache: \(error.localizedDescription)")
                            } else {
                                print("✅ shouldClearCache reset to false")
                            }
                        }
                    }
                    
                    // ✅ Fetch and update records
                    self.historyRecords = records.map { record in
                        HistoryRecord(
                            id: record.recordID,
                            userName: record["userName"] as? String ?? "Unknown",
                            date: record["date"] as? Date ?? Date(),
                            totalProducts: record["totalProducts"] as? Int ?? 0,
                            itemName: record["itemName"] as? String ?? "No Item",
                            userReference: record["userReference"] as? CKRecord.Reference
                        )
                    }
                    print("✅ Successfully fetched \(records.count) account records!")
                } else {
                    print("❌ Error fetching account records: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}
