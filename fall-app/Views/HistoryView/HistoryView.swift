import SwiftUI
import SkeletonUI

/// History view of the application, showing past walking records
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 15, 2023
///
struct HistoryView: View
{
    @StateObject var records = WalkingRecordsArr();
    
    var body: some View {
        
        NavigationStack {
            let numRecs = records.generalDataArr.count;
            
//            // Header
            Text("Walking History")
                .fontWeight(.bold)
                .font(.system(size: 32))
                .padding(.top, 32).padding(.bottom, 4)
            
            //  Print records
            ScrollView(.vertical) {
                if records.isDoneFetching() { // done loading
                    // Content
                    VStack {
                        NavigationLink(destination: MultiRecordsView()) {
                            HStack {
                                Text("View records from all trips")
                                Image(systemName: "arrow.right")
                                    .imageScale(.small)
                            }
                        }
                        Spacer()
                            .frame(height: 16)
                        
                        let numRecs = records.generalDataArr.count;
                        Text(String(numRecs) + " record(s) found.")
                            .padding(.bottom, 10)
                            .padding(.top, 8)
                            .frame(width: 320)

                        if(numRecs != 0) { // the boxes
                            ForEach(records.generalDataArr.indices) { index in
                                RecordItem(generalData: records.generalDataArr[numRecs - index - 1])
                                
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
