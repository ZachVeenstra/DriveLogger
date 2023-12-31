//
//  AddDriveView.swift
//  Drive Logger
//
//  Created by Zach Veenstra on 12/3/22.
//
// Lots of inspiration from: https://www.youtube.com/watch?v=O0FSDNOXCl0

import SwiftUI

struct AddDriveView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var drivesDataModel: DrivesDataModel
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var date: Date = Date()
    @State private var name: String = "Drive on \(dateFormatter.string(from: Date()))"
    @State private var distance: String = "0"
    private var durationSeconds: Int32 {
        return Int32((TimeConverter().hoursToSeconds(from: self.hours)) +
                     (TimeConverter().minutesToSeconds(from: self.minutes)) +
                     self.seconds)
    }
    
    var drive: Drive?
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Text("Drive Name")
                        .font(.title3)
                        .fontWeight(.bold)
                        .onAppear() {
                            if drive != nil {
                                hours = Int(drive!.hours)
                                minutes = Int(drive!.minutes)
                                seconds = Int(drive!.duration % 60)
                                name = drive!.name ?? ""
                                date = drive!.date!
                                distance = String(drive!.distance)
                            }
                        }
                    
                    TextField("Name", text: $name)
                        .accessibilityIdentifier("NameField")
                }

                Section {
                    Text("Drive Duration")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    HStack {
                        TimePickerView(title: "hours", range: 0...23, selection: $hours)
                        TimePickerView(title: "min", range: 0...59, selection: $minutes)
                        TimePickerView(title: "sec", range: 0...59, selection: $seconds)
                    }
                }
                                    
                Section {
                    Text("Drive Distance")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    TextField("Distance", text: $distance)
                        .keyboardType(.numberPad)
                        .accessibilityIdentifier("DistanceField")
                    
                }
                Button("Submit") {
                    submit()
                    dismiss()
                }
                .accessibilityIdentifier("SubmitButton")
            }
        }
    }
    
    func submit() {
        if drive != nil {
            print(durationSeconds)
            drivesDataModel.editDrive(drive: drive!, name: name, duration: durationSeconds, distance: Double(distance) ?? 0)
        } else {
            drivesDataModel.createDrive(name: name, duration: durationSeconds, distance: Double(distance) ?? 0)
        }
    }
}


private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()


struct AddDriveView_Previews: PreviewProvider {
    static let moc = DataController().container.viewContext
    
    static var previews: some View {
        AddDriveView()
            .environmentObject(DrivesDataModel(moc: moc))
    }
}
