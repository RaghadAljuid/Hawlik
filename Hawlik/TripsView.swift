import SwiftUI
import PhotosUI
import Combine

// MARK: - Trips Screen

struct TripsView: View {
    @EnvironmentObject private var store: TripStore

    // Create
    @State private var showCreateSheet = false
    @State private var sheetID = UUID()

    // Rename
    @State private var showRenameAlert = false
    @State private var renameText = ""
    @State private var renameTrip: Trip?

    // Action menu
    @State private var menuTripID: UUID? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 0) {
                    header

                    if store.trips.isEmpty {
                        emptyState   // ✅ هنا Plan Your Trip ✈️
                    } else {
                        gridContent
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, AppUI.sidePadding)
                .padding(.top, 10)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onDisappear { menuTripID = nil }

            .overlayPreferenceValue(TripAnchorKey.self) { anchors in
                GeometryReader { proxy in
                    if let id = menuTripID,
                       let anchor = anchors[id],
                       let trip = store.trips.first(where: { $0.id == id }) {

                        let rect = proxy[anchor]
                        let center = menuCenterPoint(cardRect: rect, screen: proxy.size)

                        ZStack {
                            Color.black.opacity(0.35)
                                .ignoresSafeArea()
                                .onTapGesture { closeMenu() }

                            ActionMenuBox(
                                renameAction: {
                                    renameTrip = trip
                                    renameText = trip.name
                                    showRenameAlert = true
                                    closeMenu()
                                },
                                deleteAction: {
                                    store.delete(trip)
                                    closeMenu()
                                }
                            )
                            .frame(width: AppUI.menuW, height: AppUI.menuH)
                            .position(center)
                        }
                        .transition(.opacity)
                        .zIndex(999)
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateTripSheet()
                .environmentObject(store)
                .id(sheetID)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .overlay {
            if showRenameAlert {
                RenameAlertOverlay(
                    title: "Rename",
                    message: "Enter a new name.",
                    text: $renameText,
                    onSave: {
                        if let t = renameTrip { store.rename(t, to: renameText) }
                        renameTrip = nil
                        withAnimation(.easeInOut(duration: 0.15)) { showRenameAlert = false }
                    },
                    onCancel: {
                        renameTrip = nil
                        withAnimation(.easeInOut(duration: 0.15)) { showRenameAlert = false }
                    }
                )
                .transition(.opacity)
                .zIndex(1000)
            }
        }
    }

    private func closeMenu() {
        withAnimation(.easeInOut(duration: 0.15)) { menuTripID = nil }
    }

    private func menuCenterPoint(cardRect: CGRect, screen: CGSize) -> CGPoint {
        var x = cardRect.midX
        var y = cardRect.maxY + AppUI.menuGapBelowCard + (AppUI.menuH / 2)

        let halfW = AppUI.menuW / 2
        let halfH = AppUI.menuH / 2

        x = min(max(x, halfW + AppUI.clampPadding), screen.width - halfW - AppUI.clampPadding)
        y = min(max(y, halfH + AppUI.clampPadding), screen.height - halfH - AppUI.clampPadding)

        return CGPoint(x: x, y: y)
    }

    private var header: some View {
        HStack {
            Spacer()

            Text("My Trip")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.top, 18)
                .offset(x: 10)

            Spacer()

            Button {
                closeMenu()
                sheetID = UUID()
                showCreateSheet = true
            } label: {
                PlusButton()
                    .offset(y: -8)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 6)
    }

    // ✅ هذا اللي انحذف عندك وصار بدلها "Trips"
    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer(minLength: 120)

            Text("Plan Your Trip ✈️")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))

            Text("Everything you need, all in one place")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var gridContent: some View {
        let columns = [
            GridItem(.flexible(), spacing: AppUI.gridColumnsSpacing, alignment: .topLeading),
            GridItem(.flexible(), spacing: AppUI.gridColumnsSpacing, alignment: .topLeading)
        ]

        return ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, alignment: .leading, spacing: AppUI.gridSpacing) {
                ForEach(store.trips) { trip in
                    TripCell(trip: trip)
                        .anchorPreference(key: TripAnchorKey.self, value: .bounds) { [trip.id: $0] }
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: 0.22) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                menuTripID = (menuTripID == trip.id) ? nil : trip.id
                            }
                        }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 120) // مساحة للتاب بار تحت
            .contentShape(Rectangle())
            .onTapGesture { closeMenu() }
        }
    }
}

// MARK: - Trip Cell

struct TripCell: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            thumb

            Text(trip.name)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.92))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }

    private var thumb: some View {
        Group {
            if let data = trip.imageData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: AppUI.thumbCorner, style: .continuous)
                        .fill(.white.opacity(0.14))

                    Image(systemName: "photo")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .frame(width: AppUI.thumbW, height: AppUI.thumbH)
        .clipShape(RoundedRectangle(cornerRadius: AppUI.thumbCorner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppUI.thumbCorner, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
    }
}

// MARK: - Action Menu Box

struct ActionMenuBox: View {
    let renameAction: () -> Void
    let deleteAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: renameAction) { row(title: "Rename", icon: "pencil") }
                .buttonStyle(MenuRowPressStyle())

            Divider().overlay(Color.white.opacity(AppUI.menuDividerOpacity))

            Button(action: deleteAction) { row(title: "Delete", icon: "trash") }
                .buttonStyle(MenuRowPressStyle())
        }
        .frame(width: AppUI.menuW, height: AppUI.menuH)
        .background(
            RoundedRectangle(cornerRadius: AppUI.menuCorner, style: .continuous)
                .fill(DanahUI.menuItemColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppUI.menuCorner, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 1, x: -10, y: -10)
        .clipShape(RoundedRectangle(cornerRadius: AppUI.menuCorner, style: .continuous))
    }

    private func row(title: String, icon: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))

            Spacer()

            Image(systemName: icon)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.white.opacity(0.45))
        }
        .padding(.horizontal, 12)
        .frame(height: AppUI.menuRowH)
        .contentShape(Rectangle())
    }
}

// MARK: - Rename Overlay

struct RenameAlertOverlay: View {
    let title: String
    let message: String
    @Binding var text: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(message)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("Trip name")
                            .foregroundStyle(.white.opacity(0.45))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    TextField("", text: $text)
                        .textInputAutocapitalization(.words)
                        .foregroundStyle(.white.opacity(0.95))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )

                HStack(spacing: 10) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )

                    Button(action: onSave) {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .background(
                        Color(red: 106/255, green: 109/255, blue: 255/255).opacity(0.6)
                    )
                    .cornerRadius(25)
                    .glassEffect()
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(DanahUI.menuItemColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 12)
            .frame(maxWidth: 360)
        }
    }
}

// MARK: - Press Style

struct MenuRowPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: AppUI.menuCorner, style: .continuous)
                    .fill(configuration.isPressed ? Color.black.opacity(0.35) : Color.clear)
            )
    }
}

// MARK: - Plus Button

struct PlusButton: View {
    var body: some View {
        Image(systemName: "plus.circle.fill")
            .font(.system(size: 60, weight: .light))
            .foregroundColor(.white.opacity(0.4))
            .frame(width: 60, height: 60)
            .overlay(Circle().stroke(Color.purple.opacity(0.5), lineWidth: 1))
            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
            .glassEffect()
    }
}

// MARK: - Create Trip Sheet

struct CreateTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: TripStore

    @State private var name = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        ZStack {
            AppBackground()

            VStack {
                Spacer(minLength: 10)
                card
                Spacer()
            }
            .padding(.horizontal, AppUI.sidePadding)
            .padding(.top, 24)
        }
        .onAppear {
            name = ""
            selectedItem = nil
            imageData = nil
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run { self.imageData = data }
                }
            }
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Name Your Trip")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.95))

            ZStack(alignment: .leading) {
                if name.isEmpty {
                    Text("Riyadh")
                        .foregroundStyle(.white.opacity(0.45))
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                }

                TextField("", text: $name)
                    .foregroundStyle(.white.opacity(0.92))
                    .font(.system(size: 18, weight: .medium, design: .rounded))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.white.opacity(0.10))
            )
            .overlay(alignment: .trailing) {
                Image(systemName: "pencil")
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.trailing, 14)
                    .allowsHitTesting(false)
            }

            Text("Upload photos")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.95))

            PhotosPicker(selection: $selectedItem, matching: .images) {
                HStack {
                    Text(imageData == nil ? "Upload" : "Selected")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
            }

            Button {
                store.addTrip(name: name, imageData: imageData)
                dismiss()
            } label: {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.purple.opacity(0.5), lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .glassEffect()
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
            .padding(.top, 6)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DanahUI.cardBG)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 12)
        .frame(maxWidth: 420)
    }
}

// MARK: - Anchors

private struct TripAnchorKey: PreferenceKey {
    static var defaultValue: [UUID: Anchor<CGRect>] = [:]
    static func reduce(value: inout [UUID: Anchor<CGRect>], nextValue: () -> [UUID: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
