//
//  SettingsView.swift
//  LLMFarm
//
//  Created by guinmoon on 01.11.2023.
//

import SwiftUI


struct SettingsView: View {
    @EnvironmentObject var fineTuneModel: FineTuneModel
    let app_version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    @Binding var current_detail_view_name:String?
    @State var settings_menu_items = [
        ["icon":"square.stack.3d.up.fill","value":"Models","name":"Models"],
//        ["icon":"square.stack.3d.up.fill","value":"LoRA","name":"LoRA Adepters"],
//        ["icon":"square.stack.3d.up.fill","value":"Settings","name":"App Settings"]
    ]

    var body: some View {
        NavigationStack {
                List(){
                    NavigationLink("Models"){
                        ModelsView("models")
                    }
                    NavigationLink("LoRA Adapters"){
                        ModelsView("lora_adapters")
                    }
                    NavigationLink("Fine Tune"){
                        FineTuneView().environmentObject(fineTuneModel)
                    }
//                        ForEach(settings_menu_items, id: \.self) { settings_menu_item in
//                            NavigationLink(settings_menu_item["value"]!){
////                                ModelsView()
//                                SettingsMenuItem(icon:settings_menu_item["icon"]!,name:settings_menu_item["name"]!,current_detail_view_name:$current_detail_view_name)
//                            }
//                        }
                    Section {
                        VStack{
                            HStack{
                                Image("ava0_48")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 40))
                            }
                            .buttonStyle(.borderless)
                            .controlSize(.large)
                            Text("LLMFarm v\(app_version)\nAuthor Artem Savkin\n2023")
                                .font(.footnote)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                            
                            
                        }
                    }
        }
        .frame(maxHeight: .infinity)
            #if os(iOS)
        .listStyle(.insetGrouped)
            #endif
                
        .navigationTitle("Settings")
        }
    }
}
