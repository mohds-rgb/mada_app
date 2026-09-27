/// أدوار المستخدمين الأربعة (بند 3-د). صلاحية owner/admin لا تُمنح إطلاقاً
/// عبر واجهة اختيار — فقط عبر admin_scripts/set_role.js (بند 3-ب، 12-أ).
enum UserRole { customer, driver, officeAdmin, admin, owner, unknown }

extension UserRoleParsing on String? {
  UserRole toUserRole() {
    switch (this) {
      case 'customer':
        return UserRole.customer;
      case 'driver':
        return UserRole.driver;
      case 'officeAdmin':
        return UserRole.officeAdmin;
      case 'admin':
        return UserRole.admin;
      case 'owner':
        return UserRole.owner;
      default:
        return UserRole.unknown;
    }
  }
}

extension UserRoleValue on UserRole {
  String get value {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.driver:
        return 'driver';
      case UserRole.officeAdmin:
        return 'officeAdmin';
      case UserRole.admin:
        return 'admin';
      case UserRole.owner:
        return 'owner';
      case UserRole.unknown:
        return 'unknown';
    }
  }

  bool get isOwnerOrAdmin => this == UserRole.owner || this == UserRole.admin;
}
