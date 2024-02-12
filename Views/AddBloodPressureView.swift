import SwiftUI
import Combine

struct AddBloodPressureView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var systolic: String = ""
    @State private var diastolic: String = ""
    @State private var hr: String = ""
    @State private var selectedHandIndex = 0
    @State private var note: String = ""
    @State private var selectedDate = Date() // Initialize with current date/time

    let hands = ["Left", "Right"]

    // Create a Locale instance
    let germanLocale = Locale(identifier: "de")

    var isSaveDisabled: Bool {
        systolic.isEmpty || diastolic.isEmpty || hr.isEmpty
    }

    var body: some View {
        Form {
            Section(header: Text("Blood Pressure")) {
                TextField("Systolic", text: $systolic)
                    .keyboardType(.numberPad)
                    .onReceive(Just(systolic)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.systolic = filtered
                        }
                    }
                TextField("Diastolic", text: $diastolic)
                    .keyboardType(.numberPad)
                    .onReceive(Just(diastolic)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.diastolic = filtered
                        }
                    }
                TextField("Heart Rate", text: $hr)
                    .keyboardType(.numberPad)
                    .onReceive(Just(hr)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.hr = filtered
                        }
                    }
            }

            Section(header: Text("Hand")) {
                Picker("Hand", selection: $selectedHandIndex) {
                    ForEach(0 ..< 2) {
                        Text(self.hands[$0])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("Date")) {
                DatePicker(selection: $selectedDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute]) {
                    Text("Date")
                }
            }
            .environment(\.locale, germanLocale)

            Section(header: Text("Note")) {
                TextField("Note", text: $note)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Section {
                Button("Save") {
                    saveBloodPressureReading()
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(isSaveDisabled) // Disable the button if systolic, diastolic, or hr is empty
            }
        }
        .navigationTitle("Add Blood Pressure")
        .onAppear { selectedDate = Date() }
    }

    private func saveBloodPressureReading() {
        guard let systolicValue = Int(systolic),
              let diastolicValue = Int(diastolic),
              let hrValue = Int(hr) else {
            return
        }

        let newReading = BloodPressure(context: viewContext)
        newReading.sys = Int16(systolicValue)
        newReading.dia = Int16(diastolicValue)
        newReading.hr = Int16(hrValue)
        newReading.timestamp = selectedDate
        newReading.left = selectedHandIndex == 0
        newReading.note = note

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


struct AddBloodPressureView_Previews: PreviewProvider {
    static var previews: some View {
        AddBloodPressureView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
