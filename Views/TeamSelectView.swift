import SwiftUI

struct TeamSelectView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedTeam: String = "1조"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("소속 팀을 선택하세요")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text("팀 번호에 따라 근무 일정이 조정됩니다")
                        .font(.body)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                    ForEach(1...5, id: \.self) { teamNumber in
                        TeamCard(
                            teamNumber: teamNumber,
                            isSelected: selectedTeam == "\(teamNumber)조"
                        ) {
                            selectedTeam = "\(teamNumber)조"
                        }
                    }
                }
                
                Spacer()
                
                Button("완료") {
                    shiftManager.settings.team = selectedTeam
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .background(Color.backgroundLight)
            .navigationTitle("팀 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("뒤로") {
                        dismiss()
                    }
                    .foregroundColor(.charcoalBlack)
                }
            }
        }
    }
}

struct TeamCard: View {
    let teamNumber: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .mainColorButton)
                
                Text("\(teamNumber)팀")
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .charcoalBlack)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.charcoalBlack : Color.backgroundWhite)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}



struct TeamSelectView_Previews: PreviewProvider {
    static var previews: some View {
        TeamSelectView()
            .environmentObject(ShiftManager())
    }
}
