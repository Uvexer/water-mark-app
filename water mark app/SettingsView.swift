import SwiftUI
//Вью с описанием работы
struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Курсовая работа водяные знаки БИСТ-21-2")
                .font(.largeTitle)
                .padding()
            Text("Выполнил: Чупахин Б.")
                .font(.title)
            Text("Проверил: Карпишук А.В.")
                .font(.title)
            Spacer()
        }
    }
}
