class ModulState {
  static bool isSelected = false;
  static String? idModul;
  static String? namaModul;
  static String? namaDosen;

  static void setSelected({
    required String idModul,
    required String namaModul,
    required String namaDosen,
  }) {
    ModulState.idModul = idModul;
    ModulState.namaModul = namaModul;
    ModulState.namaDosen = namaDosen;
    ModulState.isSelected = true;
  }

  static void clear() {
    ModulState.idModul = null;
    ModulState.namaModul = null;
    ModulState.namaDosen = null;
    ModulState.isSelected = false;
  }
}
