// Features/Tasks/SchedulePicker.swift
import SwiftUI

struct SchedulePicker: View {
    @Binding var selectedDate: Date

    var body: some View {
        DatePicker("Schedule", selection: $selectedDate, in: Date()...)
    }
}
