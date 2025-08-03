import SwiftUI

struct TeamSelectView: View {
    @EnvironmentObject var shiftManager: ShiftManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedTeam: String = String(format: NSLocalizedString("team_group_format", comment: "Team group format"), 1)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text(NSLocalizedString("select_team_title", comment: "Select team title"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoalBlack)
                    
                    Text(NSLocalizedString("team_schedule_description", comment: "Team schedule description"))
                        .font(.body)
                        .foregroundColor(.charcoalBlack.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                    ForEach(1...5, id: \.self) { teamNumber in
                        TeamCard(
                            teamNumber: teamNumber,
                            isSelected: selectedTeam == String(format: NSLocalizedString("team_group_format", comment: "Team group format"), teamNumber)
                        ) {
                            selectedTeam = String(format: NSLocalizedString("team_group_format", comment: "Team group format"), teamNumber)
                        }
                    }
                }
                
                Spacer()
                
                Button(NSLocalizedString("complete", comment: "Complete button")) {
                    shiftManager.settings.team = selectedTeam
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .background(Color.backgroundLight)
            .navigationTitle(NSLocalizedString("team_selection", comment: "Team selection"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("back", comment: "Back button")) {
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
                
                Text(String(format: NSLocalizedString("team_format", comment: "Team format"), teamNumber))
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
