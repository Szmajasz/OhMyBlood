import SwiftUI
import Charts

struct BloodPressureLineChartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: BloodPressure.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \BloodPressure.timestamp, ascending: true)]) var bloodPressureReadings: FetchedResults<BloodPressure>

    @State private var selectedPeriod: Period = .lastWeek // Default period selection
    @State private var selectedHour: Hour = .all // Default hour selection

    var body: some View {
        VStack {
            Picker("Select Period", selection: $selectedPeriod) {
                Text("Last Week").tag(Period.lastWeek)
                Text("Last Month").tag(Period.lastMonth)
                Text("Last 3 Months").tag(Period.last3Months)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(5)

            Picker("Select Hour", selection: $selectedHour) {
                Text("All").tag(Hour.all)
                Text("Morning").tag(Hour.morning)
                Text("Afternoon").tag(Hour.afternoon)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(5)

            GeometryReader { geometry in
                VStack {
                    Chart {
                        // Line plot for systolic pressure
                        ForEach(filteredReadings(for: selectedPeriod, and: selectedHour), id: \.self) { reading in
                            if let timestamp = reading.timestamp {
                                LineMark(
                                    x: PlottableValue.value("Date \(formatDate(timestamp))", timestamp),
                                    y: PlottableValue.value("Sys Pressure", Double(reading.sys)),
                                    series: .value("Sys Pressure", "sys")
                                )
                                .symbol(.circle)
                                .foregroundStyle(Color.red)
                            }
                        }
                        
                        // Line plot for diastolic pressure
                        ForEach(filteredReadings(for: selectedPeriod, and: selectedHour), id: \.self) { reading in
                            if let timestamp = reading.timestamp {
                                LineMark(
                                    x: PlottableValue.value("Date \(formatDate(timestamp))", timestamp),
                                    y: PlottableValue.value("Dia Pressure", Double(reading.dia)),
                                    series: .value("Dia Pressure", "dia")
                                )
                                .symbol(.circle)
                                .foregroundStyle(Color.blue)
                            }
                        }
                    }
                    .frame(width: geometry.size.width - 20, height: geometry.size.height * 0.495)
                    .padding(10)

                    BloodPressureInfoView(filteredReadings: filteredReadings(for: selectedPeriod, and: selectedHour))
                        .padding()
                }
            }
        }
        .navigationTitle("Statistics")
    }
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
    private func filteredReadings(for period: Period, and hour: Hour) -> [BloodPressure] {
        let startDate: Date
        switch period {
        case .lastWeek:
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .lastMonth:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .last3Months:
            startDate = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        }

        switch hour {
        case .all:
            return bloodPressureReadings.filter { $0.timestamp ?? Date() >= startDate }
        case .morning:
            return bloodPressureReadings.filter { reading in
                guard let timestamp = reading.timestamp else { return false }
                let hour = Calendar.current.component(.hour, from: timestamp)
                return hour >= 5 && hour < 12 && timestamp >= startDate
            }
        case .afternoon:
            return bloodPressureReadings.filter { reading in
                guard let timestamp = reading.timestamp else { return false }
                let hour = Calendar.current.component(.hour, from: timestamp)
                return (hour >= 12 || hour < 5) && timestamp >= startDate
            }
        }
    }
}

struct BloodPressureLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        BloodPressureLineChartView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

enum Period {
    case lastWeek, lastMonth, last3Months
}

enum Hour {
    case all, morning, afternoon
}

struct BloodPressureInfoView: View {
    var filteredReadings: [BloodPressure]

    var sysMin: Int? {
        filteredReadings.map { Int($0.sys) }.min()
    }

    var sysMax: Int? {
        filteredReadings.map { Int($0.sys) }.max()
    }

    var sysAverage: Double? {
        filteredReadings.map { Double($0.sys) }.reduce(0, +) / Double(filteredReadings.count)
    }

    var diaMin: Int? {
        filteredReadings.map { Int($0.dia) }.min()
    }

    var diaMax: Int? {
        filteredReadings.map { Int($0.dia) }.max()
    }

    var diaAverage: Double? {
        filteredReadings.map { Double($0.dia) }.reduce(0, +) / Double(filteredReadings.count)
    }

    let gridColumns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Blood Pressure Information")
                .font(.headline)
                .padding(.bottom, 4)

            LazyVGrid(columns: gridColumns, spacing: 0) {
                StatisticView(title: "Systolic (Min)", value: "\(sysMin ?? 0)")
                StatisticView(title: "Diastolic (Min)", value: "\(diaMin ?? 0)")
                StatisticView(title: "Systolic (Max)", value: "\(sysMax ?? 0)")
                StatisticView(title: "Diastolic (Max)", value: "\(diaMax ?? 0)")
                StatisticView(title: "Systolic (Average)", value: String(format: "%.2f", sysAverage ?? 0))
                StatisticView(title: "Diastolic (Average)", value: String(format: "%.2f", diaAverage ?? 0))
            }
        }
        .padding()
        .background(Color(.systemGray4))
        .cornerRadius(10)
    }
}

struct StatisticView: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading) // Align text to leading edge
                .padding(.trailing, 4) // Add padding to separate title from value
            Text(value)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading) // Align text to leading edge
        }
        .padding(.vertical, 8) // Add vertical padding for consistent spacing
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure each view takes full width
    }
}


