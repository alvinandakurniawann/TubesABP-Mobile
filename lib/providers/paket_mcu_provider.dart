import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/paket_mcu.dart';

class PaketMCUProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<PaketMCU> _paketList = [];
  String? _error;
  bool _isLoading = false;

  List<PaketMCU> get paketList => _paketList;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> loadPaketList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('paket_mcu')
          .select()
          .order('created_at', ascending: false);

      _paketList = (response as List<dynamic>)
          .map((json) => PaketMCU.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Terjadi kesalahan saat memuat data paket MCU';
      _paketList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPaketMCU(Map<String, dynamic> paketData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _supabase.from('paket_mcu').insert(paketData).select().single();

      final newPaket = PaketMCU.fromJson(response);
      _paketList = [newPaket, ..._paketList];
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat membuat paket MCU';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePaketMCU(String id, Map<String, dynamic> paketData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('paket_mcu')
          .update(paketData)
          .eq('id', id)
          .select()
          .single();

      final updatedPaket = PaketMCU.fromJson(response);
      _paketList = _paketList.map((paket) {
        if (paket.id == updatedPaket.id) {
          return updatedPaket;
        }
        return paket;
      }).toList();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat memperbarui paket MCU';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePaketMCU(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.from('paket_mcu').delete().eq('id', id);
      _paketList = _paketList.where((paket) => paket.id != id).toList();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat menghapus paket MCU';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
