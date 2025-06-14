import 'package:task_manager/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required super.id, required super.email, required super.name});
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: json["id"], email: json["email"], name: json["name"]);
  Map<String, dynamic> toJson() => {"id": id, "email": email, "name": name};
}
