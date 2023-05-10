import SwiftUI
import SkeletonUI

/// History view of the application, showing past survey responses
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
struct HistoryView: View
{
    @StateObject var records = ArrayOfWalkingRecords();
    
    var body: some View {
        
        VStack {
            // Header
            Text("Records History")
                .fontWeight(.bold)
                .font(.system(size: 28))
                .padding(.top, 16).padding(.bottom, 2)
            
            // Print records
            ScrollView(.vertical) {
                if records.isDoneFetching() { // done loading
                    // Content
                    VStack {
                        let numRecs = records.arr.count;
                        Text(String(numRecs) + " record(s) found.")
                            .padding(.bottom, 10)
                            .padding(.top, 8)
                            .frame(width: 320)

                        if(numRecs != 0) {
                            ForEach(records.arr.indices) { index in
                                RecordItem(record: records.arr[numRecs - index - 1])
                            }
                        }
                    }
                }
                else { // still loading
                    // Skeleton UI
                    VStack {
                        
                        Text("Loading...")
                            .padding(.bottom, 10)
                            .padding(.top, 8)
                            .frame(width: 320)
                            .skeleton(with: !records.isDoneFetching(),
                                      size: CGSize(width: 240, height: 30))
                        
                        ForEach(1..<12) { index in
                            Text("")
                                .skeleton(with: !records.isDoneFetching(),
                                          size: CGSize(width: 320, height: 56))
                        }
                    }
                }
            }
            .frame(alignment: .center)
            
        }
        .onAppear {
            getRecords()
        }
    }
    
    /// Retrieves records from Firebase and refreshes the screen.
    func getRecords() {
        records.clearArr()
        FirestoreHandler.connect()
        FirestoreHandler.getRecords(arr: records)
    }
}
