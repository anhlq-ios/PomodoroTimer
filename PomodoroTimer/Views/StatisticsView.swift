import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    summaryCards
                    chartSection
                    focusTimeSection
                    clearDataButton
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Subviews

    private var summaryCards: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Today",
                value: "\(viewModel.todayCount)",
                icon: "flame.fill",
                color: .orange
            )

            StatCard(
                title: "This Week",
                value: "\(viewModel.weekCount)",
                icon: "calendar",
                color: .blue
            )

            StatCard(
                title: "Total",
                value: "\(viewModel.totalCount)",
                icon: "trophy.fill",
                color: .yellow
            )
        }
        .padding(.horizontal)
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days")
                .font(.headline)
                .padding(.horizontal)

            Chart(viewModel.weeklyStats) { stat in
                BarMark(
                    x: .value("Day", stat.dayString),
                    y: .value("Sessions", stat.count)
                )
                .foregroundStyle(Color.red.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .padding(.horizontal)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var focusTimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Focus Time")
                .font(.headline)

            Text(viewModel.totalFocusTimeString)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var clearDataButton: some View {
        Button(role: .destructive) {
            viewModel.clearAllSessions()
        } label: {
            Text("Clear All Data")
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

#Preview {
    StatisticsView(viewModel: TimerViewModel())
}
