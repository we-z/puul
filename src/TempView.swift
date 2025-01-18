import SwiftUI

struct TempView: View {
    @State var pageIndex: Int = 0

        var body: some View {
            NavigationView {
               TabView(selection: self.$pageIndex) {
                   ScrollView{
                       Text("Profile")
                           .onAppear {
                               pageIndex = 1
                           }
                   }
                    .tag(0)
                
                Text("Home")
                    .tag(1)
                
                Text("Settings")
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .navigationTitle("test")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.spring()) {
                            pageIndex = 0
                        }
                    } label: {
                        Text("Profile")
                            .foregroundColor(pageIndex == 0 ? .red : .primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.spring()) {
                            pageIndex = 2
                        }
                    } label: {
                        Text("Settings")
                            .foregroundColor(pageIndex == 2 ? .red : .primary)
                    }
                }
              }
           }
        }
}


struct TempView_Previews: PreviewProvider {
    static var previews: some View {
        TempView()
    }
}
