enum UserRole { USER, ORGANIZER, REPRESENTATIVE }

String getRoleName(UserRole role) {
  switch (role) {
    case UserRole.USER:
      return 'User';
    case UserRole.ORGANIZER:
      return 'Organizer';
    case UserRole.REPRESENTATIVE:
      return 'Representative';
    default:
      return 'Unknown';
  }
}

int getRoleValue(UserRole role) {
  switch (role) {
    case UserRole.USER:
      return 1;
    case UserRole.ORGANIZER:
      return 2;
    case UserRole.REPRESENTATIVE:
      return 3;
    default:
      return 0;
  }
}

String getRoleFromValue(int value) {
  switch (value) {
    case 1:
      return 'User';
    case 2:
      return 'Organizer';
    case 3:
      return 'Representative';
    default:
      return 'Unknown';
  }
}
