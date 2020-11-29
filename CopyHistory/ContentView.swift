import SwiftUI

struct ContentView: View {
    private let action: () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        VStack {
        Text("Hello, World!")
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
        Button("abc") {
            print("???")
            self.action()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
//        CommandMenu("command?") {
//            Button("abc") {
//                print("???")
//                self.action()
//            }.frame(maxWidth: .infinity, maxHeight: .infinity)
//        }
////        Menu("Actions") {
////            MenuStyleConfiguration
//            Button("abc") {
//                print("???")
//                self.action()
//            }.frame(maxWidth: .infinity, maxHeight: .infinity)
//        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView {}
    }
}
