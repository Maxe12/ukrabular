import SwiftUI


// MARK: - Views
struct ContentView: View {
    var body: some View {
        TabView {
            CategorysView()
                .tabItem {
                    Label("Words", systemImage: "list.bullet")
                }

            PracticeView()
                .tabItem {
                    Label("Practice", systemImage: "brain.head.profile")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(VocabularyStore())
    }
}
