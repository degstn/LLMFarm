//
//  ChatViewModel.swift
//  AlpacaChatApp
//
//  Created by Yoshimasa Niwa on 3/19/23.
//

import Foundation
import SwiftUI
import llmfarm_core

private extension Duration {
    var seconds: Double {
        Double(components.seconds) + Double(components.attoseconds) / 1.0e18
    }
}

//@MainActor
final class FineTuneModel: ObservableObject {
    enum State {
        case none
        case loading
        case tune
        case cancel
        case completed
    }
    @Published var state: State = .none
    @Published  var model_file_url: URL = URL(filePath: "/")
    @Published  var model_file_path: String = "Select model"
    @Published  var dataset_file_url: URL = URL(filePath: "/")
    @Published  var dataset_file_path: String = "Select dataset"
    @Published  var lora_name: String = ""
    @Published  var n_ctx: Int32 = 64
    @Published  var n_batch: Int32 = 4
    @Published  var adam_iter: Int32 = 1
    @Published  var n_threads: Int32 = 0
    @Published  var use_metal: Bool = false
    @Published  var use_checkpointing: Bool = true
    @Published  var tune_log: String = ""
    public  var llama_finetune:LLaMa_FineTune? = nil
    
    var tuneQueue = DispatchQueue(label: "LLMFarm-Tune", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    public func finetune() async {
        Task{
            self.tune_log = ""
            self.state = .loading
            let documents_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let model_path = get_path_by_short_name(model_file_path,dest:"models")
            if (model_path == nil || documents_path == nil){
                return
            }
            _ = get_path_by_short_name(lora_name,dest:"lora_adapters")
            let lora_path:String = String(documents_path!.appendingPathComponent("lora_adapters").path(percentEncoded: true) + lora_name)
//            try! lora_path.write(to: URL(fileURLWithPath: lora_path), atomically: true, encoding: String.Encoding.utf8)
            print("Lora_path: \(lora_path)")
            let dataset_path = get_path_by_short_name(dataset_file_path,dest:"datasets")
            if dataset_path == nil{
                return
            }
            llama_finetune = LLaMa_FineTune(model_path!,lora_path,dataset_path!,threads: 
                                                n_threads, adam_iter: adam_iter,batch: n_batch,ctx: n_ctx,
                                            use_checkpointing: use_checkpointing, use_metal: use_metal)
            self.state = .tune
            tuneQueue.async{
                do{
                    try self.llama_finetune!.finetune(
                    { progress_str in
                        DispatchQueue.main.async {
                            self.tune_log += "\n\(progress_str)"
                            if self.llama_finetune?.cancel == true
                            {
                                self.state = .completed
                                self.llama_finetune = nil
                            }
                        }
                    })
                }
                catch{
                    DispatchQueue.main.async {
                        self.tune_log += "\nERROR: \(error)"
                        self.state = .completed
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.state = .completed
                }
            }
            
        }
    }
    
    public func cancel_finetune() async {
        self.llama_finetune?.cancel = true        
        self.state = .cancel
    }
}
