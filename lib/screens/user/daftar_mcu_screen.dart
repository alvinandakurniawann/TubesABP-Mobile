import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/paket_mcu_provider.dart';
import '../../providers/pendaftaran_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/paket_mcu.dart';
import 'riwayat_mcu_screen.dart';
import 'profil_screen.dart';

class DaftarMCUScreen extends StatefulWidget {
  const DaftarMCUScreen({super.key});

  @override
  State<DaftarMCUScreen> createState() => _DaftarMCUScreenState();
}

class _DaftarMCUScreenState extends State<DaftarMCUScreen> {
  final _formKey = GlobalKey<FormState>();
  PaketMCU? _selectedPaket;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Load paket MCU list
        await context.read<PaketMCUProvider>().loadPaketList();

        // Pastikan user data tersedia
        final userProvider = context.read<UserProvider>();
        final currentUser = userProvider.currentUser;
        if (currentUser != null) {
          await userProvider.loadCurrentUser(currentUser.username);
        }
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime && mounted) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.currentUser;

      if (user == null) {
        throw Exception('Silakan login kembali');
      }

      final success =
          await context.read<PendaftaranProvider>().createPendaftaran(
                userId: user.id,
                paketMcuId: _selectedPaket!.id,
                tanggalPendaftaran: DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                ),
                totalHarga: _selectedPaket!.harga.toDouble(),
              );

      if (!mounted) return;

      if (success) {
        await context.read<PendaftaranProvider>().loadPendaftaranList();

        setState(() {
          _selectedPaket = null;
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran berhasil'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<PendaftaranProvider>().error ??
                  'Gagal melakukan pendaftaran',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      if (e.toString().contains('User tidak ditemukan')) {
        final currentUser = context.read<UserProvider>().currentUser;
        if (currentUser != null) {
          await context
              .read<UserProvider>()
              .loadCurrentUser(currentUser.username);
        }

        final user = context.read<UserProvider>().currentUser;
        if (user == null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              color: Colors.blue,
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: const Text(
                'Daftar Medical Checkup',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Consumer<PaketMCUProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (provider.error != null) {
                            return Center(
                              child: Text('Error: ${provider.error}'),
                            );
                          }

                          return DropdownButtonFormField<PaketMCU>(
                            value: _selectedPaket,
                            decoration: const InputDecoration(
                              labelText: 'Pilih Paket MCU',
                              border: OutlineInputBorder(),
                            ),
                            items: provider.paketList.map((paket) {
                              return DropdownMenuItem(
                                value: paket,
                                child: Text(paket.namaPaket),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPaket = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Silakan pilih paket MCU';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_selectedPaket != null) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedPaket!.namaPaket,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(_selectedPaket!.deskripsi),
                                const SizedBox(height: 8),
                                Text(
                                  'Harga: Rp ${_selectedPaket!.harga.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Tanggal Pemeriksaan'),
                              subtitle: Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(context),
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              title: const Text('Jam Pemeriksaan'),
                              subtitle: Text(
                                '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.access_time),
                                onPressed: () => _selectTime(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: _isLoading ? null : _submitForm,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
