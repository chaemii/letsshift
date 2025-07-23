import SwiftUI

struct ShiftTypeSelectView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    @State private var showingTeamSelection = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("근무 유형 설정")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text("5조 3교대 근무 시스템을 사용합니다")
                        .font(.body)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Show all shift types as info
                VStack(spacing: 15) {
                    ForEach(ShiftType.allCases, id: \.self) { shiftType in
                        HStack {
                            Circle()
                                .fill(shiftManager.getColor(for: shiftType))
                                .frame(width: 20, height: 20)
                            
                            Text(shiftType.rawValue)
                                .font(.body)
                                .foregroundColor(.charcoalBlack)
                            
                            Spacer()
                            
                            Text("\(shiftType.workingHours)시간")
                                .font(.caption)
                                .foregroundColor(.charcoalBlack.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.backgroundWhite)
                        .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                Button("다음") {
                    showingTeamSelection = true
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .background(Color.backgroundLight)
            .navigationTitle("근무 유형")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
            .sheet(isPresented: $showingTeamSelection) {
                TeamSelectView()
                    .environmentObject(shiftManager)
            }
        }
    }
}

struct ShiftTypeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftTypeSelectView()
            .environmentObject(ShiftManager())
    }
}
