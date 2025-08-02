import SwiftUI

struct ShiftPatternSelectView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedPattern: ShiftPatternType
    
    init() {
        _selectedPattern = State(initialValue: ShiftManager.shared.settings.shiftPatternType)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    Text("근무 패턴 선택")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text("적용할 근무 패턴을 선택하세요")
                        .font(.subheadline)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Pattern options
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(ShiftPatternType.allCases, id: \.self) { pattern in
                            PatternOptionCard(
                                pattern: pattern,
                                isSelected: selectedPattern == pattern
                            ) {
                                selectedPattern = pattern
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: applyPattern) {
                        Text("패턴 적용")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.charcoalBlack)
                            .cornerRadius(12)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("취소")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.charcoalBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.backgroundLight)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color.backgroundLight)
            .navigationBarHidden(true)
        }
    }
    
    private func applyPattern() {
        // 커스텀 패턴에서 다른 패턴으로 변경하는 경우, 기존 커스텀 패턴 삭제
        if shiftManager.settings.shiftPatternType == .custom && selectedPattern != .custom {
            shiftManager.settings.customPattern = nil
        }
        
        shiftManager.settings.shiftPatternType = selectedPattern
        shiftManager.regenerateSchedule()
        shiftManager.saveData()
        dismiss()
    }
}

struct PatternOptionCard: View {
    let pattern: ShiftPatternType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pattern.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.charcoalBlack)
                        
                        Text(pattern.description)
                            .font(.subheadline)
                            .foregroundColor(.charcoalBlack.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.pointColor)
                    }
                }
                
                // Pattern preview
                HStack(spacing: 8) {
                    ForEach(pattern.generatePattern(), id: \.self) { shiftType in
                        Text(shiftType.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(shiftType.color)
                            .cornerRadius(6)
                    }
                }
            }
            .padding(16)
            .background(isSelected ? Color.mainColor.opacity(0.3) : Color.backgroundWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.pointColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShiftPatternSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftPatternSelectView()
            .environmentObject(ShiftManager())
    }
} 