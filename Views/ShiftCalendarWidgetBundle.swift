import WidgetKit
import SwiftUI

// 메인 앱에서 위젯을 테스트하기 위한 구조체
struct ShiftCalendarWidgetBundle {
    static var widgets: [Widget] {
        [
            ShiftCalendarWidget(),
            TodayShiftWidget()
        ]
    }
}

// 위젯 미리보기를 위한 뷰
struct WidgetPreviewView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("위젯 미리보기")
                .font(.title)
                .fontWeight(.bold)
            
            // 일주일 스케줄 위젯 미리보기
            VStack(alignment: .leading) {
                Text("일주일 스케줄 위젯")
                    .font(.headline)
                
                ShiftCalendarWidgetEntryView(entry: ShiftCalendarEntry(
                    date: Date(),
                    weekSchedule: [
                        DaySchedule(day: "월", shiftType: .주간, date: Date()),
                        DaySchedule(day: "화", shiftType: .야간, date: Date()),
                        DaySchedule(day: "수", shiftType: .휴무, date: Date()),
                        DaySchedule(day: "목", shiftType: .주간, date: Date()),
                        DaySchedule(day: "금", shiftType: .야간, date: Date()),
                        DaySchedule(day: "토", shiftType: .휴무, date: Date()),
                        DaySchedule(day: "일", shiftType: .주간, date: Date())
                    ]
                ))
                .frame(width: 300, height: 200)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
            }
            
            // 오늘 스케줄 위젯 미리보기
            VStack(alignment: .leading) {
                Text("오늘 스케줄 위젯")
                    .font(.headline)
                
                TodayShiftWidgetEntryView(entry: TodayShiftEntry(
                    date: Date(),
                    todayShift: .주간,
                    isToday: true
                ))
                .frame(width: 200, height: 200)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
            }
        }
        .padding()
        .background(Color(hex: "EFF0F2"))
    }
}

#Preview {
    WidgetPreviewView()
} 