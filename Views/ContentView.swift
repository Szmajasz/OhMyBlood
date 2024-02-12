import SwiftUI

struct BloodPressureListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: BloodPressure.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \BloodPressure.timestamp, ascending: false)]) var bloodPressureReadings: FetchedResults<BloodPressure>

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Text("Hello Szymon. Happy to see you :)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                List {
                    ForEach(bloodPressureReadings.indices, id: \.self) { index in
                        let reading = bloodPressureReadings[index]
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                if let timestamp = reading.timestamp {
                                    Text(formatDate(timestamp))
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                HStack(spacing: 10) {
                                    Text("\(reading.sys)")
                                        .font(.system(size: 30, weight: .bold))
                                    Text("|")
                                        .font(.system(size: 30, weight: .bold))
                                    Text("\(reading.dia)")
                                        .font(.system(size: 30, weight: .bold))
                                    Text("|")
                                        .font(.system(size: 30, weight: .bold))
                                    Text("\(reading.hr)")
                                        .font(.system(size: 30, weight: .bold))
                                }
                                .foregroundColor(.primary)
                                
                                if reading.left {
                                    Text("Hand: Left")
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Hand: Right")
                                        .foregroundColor(.secondary)
                                }
                                
                                if let note = reading.note, !note.isEmpty { // Check if note is not empty
                                    Text("Note: \(note)")
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            // Information about systolic pressure
                            if reading.sys > 150 {
                                Text("Very High!")
                                    .foregroundColor(.red)
                                    .font(.system(size: 20, weight: .bold))
                            } else if reading.sys > 140 {
                                Text("High")
                                    .foregroundColor(.red)
                                    .font(.system(size: 20, weight: .bold))
                            } else {
                                Text("Good :)")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        
                    }
                    .onDelete(perform: deleteBloodPressure)
                    
                }

            }
            .navigationTitle("Oh My Blood!")
            .toolbar {
                NavigationLink(destination: BloodPressureLineChartView()) {
                    Text("Statistics")
                };
                NavigationLink(destination: AddBloodPressureView()) {
                    Text("Add")
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.dateFormat = "dd.MM.yyy   HH:mm"
        return formatter
    }()

    private func deleteBloodPressure(at offsets: IndexSet) {
        for index in offsets {
            let reading = bloodPressureReadings[index]
            viewContext.delete(reading)
        }

        do {
            try viewContext.save()
        } catch {
            print("Error deleting reading: \(error)")
        }
    }
}


struct BloodPressureListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        return BloodPressureListView()
            .environment(\.managedObjectContext, context)
    }
}
