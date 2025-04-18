class Pasien {
  final String id;
  final String noKtp;
  final String namaLengkap;
  final String jenisKelamin;
  final String tempatLahir;
  final DateTime tanggalLahir;
  final String alamat;
  final String noHandphone;
  final String email;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pasien({
    required this.id,
    required this.noKtp,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.alamat,
    required this.noHandphone,
    required this.email,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      id: json['id'],
      noKtp: json['no_ktp'],
      namaLengkap: json['nama_lengkap'],
      jenisKelamin: json['jenis_kelamin'],
      tempatLahir: json['tempat_lahir'],
      tanggalLahir: DateTime.parse(json['tanggal_lahir']),
      alamat: json['alamat'],
      noHandphone: json['no_handphone'],
      email: json['email'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no_ktp': noKtp,
      'nama_lengkap': namaLengkap,
      'jenis_kelamin': jenisKelamin,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir.toIso8601String(),
      'alamat': alamat,
      'no_handphone': noHandphone,
      'email': email,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
