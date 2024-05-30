//
//  DrivesDataModel.swift
//  DriveLogger
//
//  Created by Zach Veenstra on 12/4/23.
//  Inspiration: https://www.hackingwithswift.com/forums/swift/trying-to-access-managed-object-context-through-a-model/23266
//

import Foundation
import CoreData

class DrivesDataModel: ObservableObject {
    let moc: NSManagedObjectContext
    
    @Published var drives: [Drive] = []

    init(moc: NSManagedObjectContext) {
        self.moc = moc
        NotificationCenter.default.addObserver(self, selector: #selector(fetchUpdates(_:)), name: .NSManagedObjectContextObjectsDidChange, object: nil)

        fetchDrives()
    }
    
    private func save() {
        do {
            try moc.save()
        } catch {
            print("Failed to save")
        }
    }

    func fetchDrives() {
        let request = Drive.fetchRequest()
        if var drives = try? moc.fetch(request) {
            drives.sort {
                $0.date! > $1.date!
            }
            self.drives = drives
        }
    }

    func fetchWeathers() {
        let request = WeatherType.fetchRequest()
        if let weathers = try? moc.fetch(request) {
            if let weather = weathers.first {
                if let drive = weather.drive {
                    print("\(drive.name ?? ""): \(weather.description)")
                } else {
                    print("No drive attatched...")
                }
            }
        }
    }

    @objc private func fetchUpdates(_ notification: Notification) {
        moc.perform {
            self.fetchDrives()
        }
    }

    func createDrive(date: Date, name: String, dayDuration: Int32, nightDuration: Int32, distance: Double, weather: WeatherType, road: RoadType, notes: String) {
        let drive = Drive(context: moc)
        drive.id = UUID()
        drive.weather = weather
        drive.road = road

        editDrive(drive: drive,
                  date: date,
                  name: name,
                  dayDuration: dayDuration,
                  nightDuration: nightDuration,
                  distance: distance,
                  notes: notes)

        drives.append(drive)
    }
    
    func editDrive(drive: Drive, date: Date, name: String, dayDuration: Int32, nightDuration: Int32, distance: Double, notes: String) {
        drive.date = date
        drive.name = name
        drive.dayDuration = dayDuration
        drive.nightDuration = nightDuration
        drive.distance = distance
        drive.notes = notes

        save()
    }

    func deleteDrive(drive: Drive) {
        if let weather = drive.weather {
            moc.delete(weather)
        }
        if let road = drive.road {
            moc.delete(road)
        }
        moc.delete(drive)

        do {
            try moc.save()

            if let index = drives.firstIndex(where: { drive.id == $0.id }) {
                drives.remove(at: index)
            }
        } catch {
            print("Error deleting drive")
        }
    }

    func createWeather(isClear: Bool, isRain: Bool, isSnow: Bool) -> WeatherType {
        let weather = WeatherType(context: moc)
        
        editWeather(weather: weather, isClear: isClear, isRain: isRain, isSnow: isSnow)

        return weather
    }

    func editWeather(weather: WeatherType, isClear: Bool, isRain: Bool, isSnow: Bool) {
        weather.isClear = isClear
        weather.isRain = isRain
        weather.isSnow = isSnow

        save()
    }

    func createRoad(roadViewModel: RoadMultiPickerViewModel) -> RoadType {
        let road = RoadType(context: moc)

        editRoad(road: road, roadViewModel: roadViewModel)

        return road
    }

    func editRoad(road: RoadType, roadViewModel: RoadMultiPickerViewModel) {
        road.city = roadViewModel.city
        road.highway = roadViewModel.highway
        road.multilane = roadViewModel.multilane
        road.residential = roadViewModel.residential
        road.roundabout = roadViewModel.roundabout
        road.rural = roadViewModel.rural

        save()
    }

    func getTotalSeconds() -> Int {
        var totalSeconds: Int32 = 0
        
        for drive in self.drives {
            totalSeconds += drive.dayDuration + drive.nightDuration
        }
        
        return Int(totalSeconds)
    }
    
    func getTotalNightSeconds() -> Int {
        var totalNightSeconds: Int32 = 0
        
        for drive in self.drives {
            totalNightSeconds += drive.nightDuration
        }
        
        return Int(totalNightSeconds)
    }
    
    func getTotalMinutes() -> Int {
        return TimeConverter.getMinutes(from: getTotalSeconds())
    }
    
    func getTotalHours() -> Int {
        return TimeConverter.getHours(from: getTotalSeconds())
    }
    
    func getTotalNightMinutes() -> Int {
        return TimeConverter.getMinutes(from: getTotalNightSeconds())
    }
    
    func getTotalNightHours() -> Int {
        return TimeConverter.getHours(from: getTotalNightSeconds())
    }
}
