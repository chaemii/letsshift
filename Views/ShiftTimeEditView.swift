import SwiftUI

struct ShiftTimeEditView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    
    let shiftType: ShiftType
    @State private var startHour: Int
    @State private var startMinute: Int
    @State private var endHour: Int
    @State private var endMinute: Int
    
    init(shiftType: ShiftType) {
        self.shiftType = shiftType
        let currentTime = shiftManager.getShiftTime(for: shiftType)
        self._startHour = State(initialValue: currentTime.startHour)
        self._startMinute = State(initialValue: currentTime.startMinute)
        self._endHour = State(initialValue: currentTime.endHour)
        self._endMinute = State(initialValue: currentTime.endMinute)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 25) {
                        // 헤더 섹션
                        VStack(spacing: 12) {
                            HStack {
                                Circle()
                                    .fill(shiftManager.getColor(for: shiftType))
                                    .frame(width: 40, height: 40)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(shiftManager.getShiftName(for: shiftType))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.charcoalBlack)
                                    
                                    Text("근무 시간 설정")
                                        .font(.subheadline)
                                        .foregroundColor(.charcoalBlack.opacity(0.7))
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        // 시작 시간 설정
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sunrise")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("시작 시간")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            HStack(spacing: 20) {
                                // 시작 시간
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("시")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.charcoalBlack)
                                    
                                    Picker("시작 시간", selection: $startHour) {
                                        ForEach(0..<24, id: \.self) { hour in
                                            Text("\(hour)시").tag(hour)
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                                    .frame(height: 120)
                                    .clipped()
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("분")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.charcoalBlack)
                                    
                                    Picker("시작 분", selection: $startMinute) {
                                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                                            Text("\(minute)분").tag(minute)
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                                    .frame(height: 120)
                                    .clipped()
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        // 종료 시간 설정
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sunset")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("종료 시간")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            HStack(spacing: 20) {
                                // 종료 시간
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("시")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.charcoalBlack)
                                    
                                    Picker("종료 시간", selection: $endHour) {
                                        ForEach(0..<25, id: \.self) { hour in
                                            Text("\(hour)시").tag(hour)
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                                    .frame(height: 120)
                                    .clipped()
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("분")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.charcoalBlack)
                                    
                                    Picker("종료 분", selection: $endMinute) {
                                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                                            Text("\(minute)분").tag(minute)
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                                    .frame(height: 120)
                                    .clipped()
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        // 미리보기 섹션
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                    .font(.title3)
                                Text("설정 미리보기")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoalBlack)
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("근무 시간")
                                        .font(.subheadline)
                                        .foregroundColor(.charcoalBlack.opacity(0.7))
                                    
                                    Spacer()
                                    
                                    Text("\(String(format: "%02d:%02d", startHour, startMinute)) - \(String(format: "%02d:%02d", endHour, endMinute))")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.charcoalBlack)
                                }
                                
                                HStack {
                                    Text("근무 시간")
                                        .font(.subheadline)
                                        .foregroundColor(.charcoalBlack.opacity(0.7))
                                    
                                    Spacer()
                                    
                                    Text("\(String(format: "%.1f", calculateWorkingHours()))시간")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.charcoalBlack)
                                }
                            }
                            .padding(16)
                            .background(Color(hex: "F8F9FA"))
                            .cornerRadius(12)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        // 기본값으로 되돌리기 버튼
                        Button(action: resetToDefault) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                                
                                Text("기본값으로 되돌리기")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .padding(.bottom, 100)
                }
            }
            .background(Color(hex: "EFF0F2"))
            .navigationTitle("근무 시간 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveShiftTime()
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    private func calculateWorkingHours() -> Double {
        var hours = Double(endHour - startHour) + Double(endMinute - startMinute) / 60.0
        
        // 야간 근무의 경우 다음날로 넘어가는 경우 처리
        if endHour < startHour {
            hours += 24.0
        }
        
        return max(0, hours)
    }
    
    private func resetToDefault() {
        let defaultTime = shiftType.defaultShiftTime
        startHour = defaultTime.startHour
        startMinute = defaultTime.startMinute
        endHour = defaultTime.endHour
        endMinute = defaultTime.endMinute
    }
    
    private func saveShiftTime() {
        let newShiftTime = ShiftTime(
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute
        )
        
        shiftManager.updateShiftTime(newShiftTime, for: shiftType)
    }
}

#Preview {
    ShiftTimeEditView(shiftType: .주간)
        .environmentObject(ShiftManager())
} 