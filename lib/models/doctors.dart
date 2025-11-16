// To parse this JSON data, do
//
//     final doctors = doctorsFromJson(jsonString);

import 'dart:convert';

Doctors doctorsFromJson(String str) => Doctors.fromJson(json.decode(str));

String doctorsToJson(Doctors data) => json.encode(data.toJson());

class Doctors {
  bool? success;
  int? statusCode;
  String? message;
  Data? data;

  Doctors({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory Doctors.fromJson(Map<String, dynamic> json) => Doctors(
    success: json["success"],
    statusCode: json["statusCode"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "statusCode": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  Pagination? pagination;
  List<Doctor>? doctors;

  Data({
    this.pagination,
    this.doctors,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    doctors: json["doctors"] == null ? [] : List<Doctor>.from(json["doctors"]!.map((x) => Doctor.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "pagination": pagination?.toJson(),
    "doctors": doctors == null ? [] : List<dynamic>.from(doctors!.map((x) => x.toJson())),
  };
}

class Doctor {
  int? id;
  String? name;
  String? degrees;
  int? experience;
  String? workingAt;
  int? fee;
  String? biography;
  String? profilePic;
  int? patientChecked;
  int? followupFee;
  int? followupDay;
  Specialty? specialty;

  Doctor({
    this.id,
    this.name,
    this.degrees,
    this.experience,
    this.workingAt,
    this.fee,
    this.biography,
    this.profilePic,
    this.patientChecked,
    this.followupFee,
    this.followupDay,
    this.specialty,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json["id"],
    name: json["name"],
    degrees: json["degrees"],
    experience: json["experience"],
    workingAt: json["working_at"],
    fee: json["fee"],
    biography: json["biography"],
    profilePic: json["profilePic"],
    patientChecked: json["patientChecked"],
    followupFee: json["followupFee"],
    followupDay: json["followupDay"],
    specialty: json["specialty"] == null ? null : Specialty.fromJson(json["specialty"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "degrees": degrees,
    "experience": experience,
    "working_at": workingAt,
    "fee": fee,
    "biography": biography,
    "profilePic": profilePic,
    "patientChecked": patientChecked,
    "followupFee": followupFee,
    "followupDay": followupDay,
    "specialty": specialty?.toJson(),
  };
}

class Specialty {
  int? id;
  Name? name;
  String? title;

  Specialty({
    this.id,
    this.name,
    this.title,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) => Specialty(
    id: json["id"],
    name: json["name"] == null ? null : Name.fromJson(json["name"]),
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name?.toJson(),
    "title": title,
  };
}

class Name {
  String? bn;
  String? en;

  Name({
    this.bn,
    this.en,
  });

  factory Name.fromJson(Map<String, dynamic> json) => Name(
    bn: json["bn"],
    en: json["en"],
  );

  Map<String, dynamic> toJson() => {
    "bn": bn,
    "en": en,
  };
}

class Pagination {
  int? totalItems;
  int? page;
  int? size;
  bool? hasNext;

  Pagination({
    this.totalItems,
    this.page,
    this.size,
    this.hasNext,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    totalItems: json["totalItems"],
    page: json["page"],
    size: json["size"],
    hasNext: json["hasNext"],
  );

  Map<String, dynamic> toJson() => {
    "totalItems": totalItems,
    "page": page,
    "size": size,
    "hasNext": hasNext,
  };
}
