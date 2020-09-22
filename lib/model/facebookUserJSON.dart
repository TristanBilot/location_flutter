class FacebookUserJSON {
  String lastName;
  String firstName;
  String fullName;
  String email;
  String pictureURL;
  bool hasPicture;

  FacebookUserJSON(String firstName, String lastName, String email,
      String pictureURL, bool hasPicture) {
    this.lastName = lastName;
    this.firstName = firstName;
    this.fullName = lastName + ' ' + firstName;
    this.email = email;
    this.pictureURL = pictureURL;
    this.hasPicture = hasPicture;
  }

  @override
  String toString() {
    return lastName +
        ' ' +
        firstName +
        ' ' +
        email +
        ' ' +
        pictureURL +
        ' ' +
        hasPicture.toString();
  }
}
