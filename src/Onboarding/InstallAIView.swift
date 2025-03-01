//
//  InstallAIView.swift
//  YourApp
//
//  NOTE: This file demonstrates how to automatically loaƒcheckd the model
//        immediately after writing the downloaded file. This forces
//        the llama_load_model_from_file logs to appear as soon as
//        the download/copy completes.
//

import SwiftUI
import llmfarm_core

let modelSourceUrl: String = "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q5_K_S.gguf"

/// A new view that shows a horizontally spinning carousel of icons.
/// It duplicates the icons to ensure the first icon is rendered and ready to loop seamlessly.
/// The first icon is centered on the screen initially.
/// This version uses a TimelineView to keep the animation running continuously.
struct SpinningCarousel: View {
    let icons: [String]
    // Large spacing between icons
    let spacing: CGFloat = 100
    // Icon size (same as original design)
    let iconSize: CGFloat = 210
    // Speed in points per second (adjusted for a fast loop)
    let speed: CGFloat = 90
    
    var body: some View {
        GeometryReader { geometry in
            // Calculate the initial offset so that the first icon is centered
            let initialOffset = (geometry.size.width - iconSize) / 2
            // One complete cycle width (one set of icons)
            let cycleWidth = CGFloat(icons.count) * (iconSize + spacing)
            let duration = Double(cycleWidth / speed)
            
            TimelineView(.animation) { timeline in
                // Calculate current time in the cycle
                let time = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration)
                // Compute the offset that continuously decreases then resets for seamless looping.
                let offset = initialOffset - CGFloat(time) * speed
                HStack(spacing: spacing) {
                    // Duplicate icons array for seamless looping
                    ForEach(0..<icons.count * 2, id: \.self) { index in
                        Image(systemName: icons[index % icons.count])
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize, height: iconSize)
                    }
                }
                .offset(x: offset)
            }
        }
        .frame(height: iconSize)
        .clipped()
    }
}

struct InstallAIView: View {
    @State private var done: Bool = false
    @State private var modelUrl: String = modelSourceUrl
    @State private var status: String = ""
    @State private var filename: String = String(modelSourceUrl.split(separator: "/").last ?? "")
    @State private var downloadTask: URLSessionDownloadTask?
    @State private var downloadDelegate = ModelDownloadDelegate()
    
    // Use the icons in the carousel.
    private let icons = ["dollarsign.circle", "chart.line.uptrend.xyaxis", "creditcard", "building.columns", "banknote", "list.bullet.clipboard", "chart.bar.fill", "house", "chart.pie", "car", "sparkles", "chart.xyaxis.line", "brain", "airplane"]
    
    @State private var observation: NSKeyValueObservation?
    @State private var progress: Double = 0
    @State private var showingAlert = false
    
    /// Initiates the download and handles the copy/move on completion.
    private func download() {
        withAnimation(.easeInOut) {
            status = "downloading"
        }
        
        print("Downloading model from \(modelUrl)")
        guard let url = URL(string: modelUrl) else { return }
        
        // Create the directory before writing the file:
        do {
            try createDirectoryIfNeeded(dir: "models")
        } catch {
            print("Failed to create 'models' directory: \(error.localizedDescription)")
            return
        }
        
        // Build the final fileURL
        let fileURL = getFileURLFormPathStr(dir: "models", filename: filename)
        
        // Prepare the background config
        let config = URLSessionConfiguration.background(withIdentifier: "com.yourapp.backgroundDownload.model")
        config.timeoutIntervalForRequest = 300     // 5 minutes
        config.timeoutIntervalForResource = 3600   // 1 hour
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        config.waitsForConnectivity = true
        
        // Assign the final destination to our delegate so it knows where to copy
        downloadDelegate.destinationFileURL = fileURL
        
        // Provide closures to update SwiftUI on main thread
        downloadDelegate.onProgress = { fraction in
            DispatchQueue.main.async {
                self.progress = fraction * 100
            }
        }
        downloadDelegate.onComplete = { finalFileURL in
            DispatchQueue.main.async {
                print("Writing to \(self.filename) completed.")
                
                // Mark the status to show "downloaded"
                withAnimation(.easeInOut) {
                    self.status = "downloaded"
                }
                
                // Immediately load the model in the background
                let ephemeralAI = AI(_modelPath: finalFileURL.path,
                                     _chatName: "AutoLoadBackgroundChat")
                
                ephemeralAI.initModel(.LLama_gguf)
                
                ephemeralAI.model?.modelLoadProgressCallback = { progress in
                    print("Auto-load progress: \(progress)")
                    return true
                }
                
                ephemeralAI.model?.modelLoadCompleteCallback = { loadResult in
                    print("Auto-load complete: \(loadResult)")
                }
                
                ephemeralAI.loadModel()
            }
        }
        downloadDelegate.onError = { errorMsg in
            DispatchQueue.main.async {
                print("Background download error: \(errorMsg)")
                withAnimation(.easeInOut) {
                    self.status = ""
                }
            }
        }
        
        // Create a URLSession with our delegate
        let customSession = URLSession(configuration: config,
                                       delegate: downloadDelegate,
                                       delegateQueue: nil)
        
        // Start the download task
        downloadTask = customSession.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    var body: some View {
        VStack {
            // Title
            HStack {
                Text("Welcome to Puul")
                    .bold()
                    .font(.system(size: 36))
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
            
            // Description
            HStack {
                Text("Puul local LLM (2.27GB in size) works offline to protect your data and privacy. Download to continue.")
                    .bold()
                    .font(.system(size: 21))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                Spacer()
            }
            Spacer()
            // Replace the fading single icon with the spinning carousel.
            SpinningCarousel(icons: icons)
            Spacer()
            
            // Progress Section
            if status == "downloading" {
                ProgressView()
                    .controlSize(.large)
                    .padding()
                Text("Downloading \(Int(progress))%")
                    .font(.title3)
                    .bold()
                ProgressView(value: progress, total: 100)
                    .progressViewStyle(LinearProgressViewStyle())
                    .accentColor(.primary)
                    .padding()
                    .padding(.horizontal)
                
            } else if status == "downloaded" {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding()
                Text("Installation Complete")
                    .bold()
                    .padding()
                    .onAppear {
                        // After a short delay, animate offscreen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeInOut) {
                                done = true
                            }
                        }
                    }
            }
            
            Text("(Wi-Fi connection recommended)")
                .bold()
                .font(.system(size: 21))
                .multilineTextAlignment(.center)
            
            // Download / Stop Button
            Button {
                if status.isEmpty {
                    download()
                } else if status == "downloading" {
                    showingAlert = true
                }
            } label: {
                HStack {
                    Text(status.isEmpty ? "Download AI" : "Stop Download")
                }
                .bold()
                .font(.system(size: 36))
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
                .colorInvert()
                .background(.primary)
                .cornerRadius(18)
                .padding()
            }
            .buttonStyle(HapticButtonStyle())
            if status != "downloading" {
                Button {
                    exit(0)
                } label: {
                    Text("Cancel & Exit")
                        .bold()
                        .font(.system(size: 18))
                        .padding(.bottom)
                }
                .buttonStyle(HapticButtonStyle())
            }
        }
        .background(Color.primary.colorInvert().ignoresSafeArea())
        .onAppear {
            // If the file already exists, skip this screen
            let fileURL = getFileURLFormPathStr(dir: "models", filename: filename)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                done = true
            }
        }
        .onDisappear {
            // Stop any active download when leaving this view
            downloadTask?.cancel()
        }
        .offset(x: done ? -deviceWidth : 0)
        .alert("Are you sure?",
               isPresented: $showingAlert,
               actions: {
                Button("Stop", role: .destructive) {
                    withAnimation {
                        status = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    // Do nothing, just dismiss
                }
            },
               message: {
                Text("Downloading the model is required to continue. Puul AI is safe and will not harm your device.")
            })
        .onChange(of: status) { newStatus in
            if newStatus == "" {
                progress = 0
                Task {
                    downloadTask?.cancel()
                }
            }
        }
    }
}

#Preview {
    InstallAIView()
}

final class ModelDownloadDelegate: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    /// Called every time progress updates.
    var onProgress: ((Double) -> Void)?
    /// Called when the file has been successfully copied to final destination.
    var onComplete: ((URL) -> Void)?
    /// Called if any error occurs or the user cancels.
    var onError: ((String) -> Void)?
    
    /// A file URL for the final destination of the model (so we know where to copy).
    var destinationFileURL: URL?
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else { return }
        let fractionCompleted = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        // Report progress (0.0 - 1.0)
        onProgress?(fractionCompleted)
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        // Once the download is done, move/copy the file from 'location' to the final destination.
        guard let finalURL = destinationFileURL else {
            onError?("Destination URL not set.")
            return
        }
        
        do {
            // Remove any existing file at that location before copying
            if FileManager.default.fileExists(atPath: finalURL.path) {
                try FileManager.default.removeItem(at: finalURL)
            }
            try FileManager.default.copyItem(at: location, to: finalURL)
            
            // Notify success
            onComplete?(finalURL)
        } catch {
            onError?("Failed to copy file: \(error.localizedDescription)")
        }
    }
    
    /// This gets called if the download was canceled or if an error occurred.
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        
        if let error = error {
            // If user cancels, error will be NSURLErrorCancelled; handle as needed
            onError?("Download error: \(error.localizedDescription)")
        }
    }
}
