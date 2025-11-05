import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'profile_page.dart';
import 'modul_page.dart';
import 'modul_state.dart';
import 'modul_ai_page.dart';

// Search Bar
Widget buildSearchBar({
  required String hintText,
  Function(String)? onChanged,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 255, 17, 0), // merah penuh di luar
      borderRadius: BorderRadius.circular(16),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.montserrat(color: Colors.black),
        decoration: InputDecoration(
          icon: const Icon(
            Icons.search,
            color: Color.fromARGB(255, 255, 17, 0),
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.montserrat(
            color: const Color.fromARGB(255, 255, 17, 0).withOpacity(0.6),
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    ),
  );
}

class MainLayout extends StatefulWidget {
  final Widget content;
  final int currentIndex;
  final bool showFab; // <--- tambahkan

  const MainLayout({
    super.key,
    required this.content,
    required this.currentIndex,
    this.showFab = true, // default tetap tampil
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int hoveredIndex = -1;

  // ====================== APP BAR ======================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset("assets/logo_kesamping.png", height: 40),
          Row(
            // [UPDATE]: Menggunakan CrossAxisAlignment.center agar
            // semua item di dalam Row ini rata tengah secara vertikal
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilPage()),
                  );
                },
                child: Container(
                  // Total tinggi container ini adalah 40px
                  // (CircleAvatar radius 16 -> 32px + vertical padding 4+4 = 40px)
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage("assets/profile.jpg"),
                        radius: 16,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.black),
                    ],
                  ),
                ),
              ),
              // [UPDATE]: Mengurangi jarak dari 12 ke 8
              const SizedBox(width: 8),

              // [UPDATE]: Membungkus IconButton dengan SizedBox
              // agar ukurannya konsisten (40x40)
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.black, size: 28),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: logout,
                      padding: EdgeInsets.zero,
                      icon:
                          const Icon(Icons.logout, color: Colors.red, size: 26),
                      tooltip: 'Logout',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ====================== FLOATING BUTTON ======================
  Widget _buildFab() {
    final bool isActive = ModulState.isSelected;

    return GestureDetector(
      onTap: isActive
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ModulAiPage(
                          idModul: ModulState.idModul!,
                          namaModul: ModulState.namaModul!,
                          namaDosen: ModulState.namaDosen!,
                        )),
              );
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isActive ? const Color.fromARGB(255, 255, 17, 0) : Colors.grey,
          shape: BoxShape.circle,
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: const Color.fromARGB(255, 255, 17, 0).withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: Image.asset(
            "assets/ai.png",
            width: 38,
            height: 38,
            color: isActive ? null : Colors.white70, // biar pudar pas disable
          ),
        ),
      ),
    );
  }

  // ====================== NAV ITEM ======================
  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    BuildContext context, {
    Widget? page,
  }) {
    final bool isActive = widget.currentIndex == index;
    final bool isHovered = hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = -1),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (page != null && !isActive) {
            // ✅ Reset modul state saat user pindah ke Home
            if (index == 0) {
              // index 0 = Home
              ModulState.isSelected = false;
              ModulState.idModul = null;
              ModulState.namaModul = null;
              ModulState.namaDosen = null;
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: isHovered
                ? const Color.fromARGB(255, 255, 17, 0).withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? const Color.fromARGB(255, 255, 17, 0)
                    : (isHovered ? Colors.redAccent : Colors.grey),
                size: 24,
              ),
              // [FIX]: Mengurangi spasi dari 4 ke 3 untuk mengatasi overflow 1px
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  color: isActive
                      ? const Color.fromARGB(255, 255, 17, 0)
                      : (isHovered ? Colors.redAccent : Colors.grey),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== BOTTOM NAV ======================
  Widget _buildBottomNav(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 0,
        child: SafeArea(
          top: false,
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, "Home", 0, context,
                    page: const HomeScreen()),
                _buildNavItem(Icons.picture_as_pdf, "Modul", 1, context,
                    page: const ModulPage()),
                const SizedBox(width: 40),
                _buildNavItem(Icons.bar_chart, "Statistik", 2, context),
                _buildNavItem(Icons.person, "Profil", 3, context,
                    page: const ProfilPage()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_user');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ====================== BUILD ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: SafeArea(child: widget.content),
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: widget.showFab ? _buildFab() : null,
      floatingActionButtonLocation:
          widget.showFab ? FloatingActionButtonLocation.centerDocked : null,
    );
  }
}
