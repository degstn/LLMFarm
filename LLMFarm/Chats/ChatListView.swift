//
//  ChatListView.swift
//  ChatUI
//
//  Created by Shezad Ahamed on 05/08/21.
//

import SwiftUI



struct ChatListView: View {
    
    @State var searchText: String = ""
    @Binding var model_name: String
    @Binding var title: String
    @Binding var add_chat_dialog: Bool
    var close_chat: () -> Void
    @Binding var edit_chat_dialog: Bool
    @Binding var chat_selection: String?
    @Binding var renew_chat_list: () -> Void    
    @State var chats_previews = get_chats_list()!
    @State private var toggleSettings = false
    @State var current_detail_view_name:String? = "Chat"
    @StateObject var aiChatModel = AIChatModel()
    @StateObject var fineTuneModel = FineTuneModel()

    
    func refresh_chat_list(){
        self.chats_previews = get_chats_list()!
    }
    
    func delete(at offsets: IndexSet) {
        let chatsToDelete = offsets.map { self.chats_previews[$0] }
        _ = delete_chats(chatsToDelete)
        
    }
    
    func delete(at elem:Dictionary<String, String>){
        _ = delete_chats([elem])
        self.chats_previews.removeAll(where: { $0 == elem })
    }


    
    var body: some View {
        NavigationStack{
                List(selection: $chat_selection){
                    ForEach(chats_previews, id: \.self) { chat_preview in
                        NavigationLink(value: chat_preview["chat"]!){
                            ChatItem(
                                chatImage: String(describing: chat_preview["icon"]!),
                                chatTitle: String(describing: chat_preview["title"]!),
                                message: String(describing: chat_preview["message"]!),
                                time: String(describing: chat_preview["time"]!),
                                model:String(describing: chat_preview["model"]!),
                                chat:String(describing: chat_preview["chat"]!),
                                chat_selection: $chat_selection,
                                model_name: $model_name,
                                title: $title,
                                close_chat:close_chat
                            )
                            .listRowInsets(.init())
                            .contextMenu {
                                Button(role: .destructive) {
                                    delete(at: chat_preview)
                                } label: {
                                    Text("Delete chat")
                                }
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
                #if os(macOS)
                .listStyle(.sidebar)
                #else
                .listStyle(.insetGrouped)
                #endif
                                
                if chats_previews.count<=0{
                    VStack {
                        Label("No Chats", systemImage: "ellipsis.message")
                        Text("Create a new chat to get started.")
                        Spacer()
                    }
                    .padding(.bottom, 125)
                    
                }
            }.task {
                renew_chat_list = refresh_chat_list
                refresh_chat_list()
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        Button {
                            toggleSettings = true
                        } label: {
                            HStack {
                                Text("Settings")
                                Image(systemName: "gear")
                            }
                        }
                        #if os(iOS)
                        EditButton()
                        #endif
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            add_chat_dialog = true
                            edit_chat_dialog = false
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                }
        }
            .sheet(isPresented: $toggleSettings) {
                SettingsView(current_detail_view_name:$current_detail_view_name).environmentObject(fineTuneModel)
            }
        
    }
}



//struct ChatListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatListView(tabSelection: .constant(1),
//                     chat_selected: .constant(false),
//                     model_name: .constant(""),
//                     chat_name: .constant(""),
//                     title: .constant(""),
//                     add_chat_dialog: .constant(false),
//                     close_chat:{},
//                     edit_chat_dialog:.constant(false))
////            .preferredColorScheme(.dark)
//    }
//}
