import 'package:flutter/material.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/stores/messaging_database.dart';

class MessagingTabPagesCountedElements extends ChangeNotifier {
  int nbDiscussions;
  int nbRequests;
  int nbViews;

  MessagingTabPagesCountedElements(
      this.nbDiscussions, this.nbRequests, this.nbViews);

  Future<void> initCounts() async {
    nbDiscussions = MessagingDatabase().getNbDiscussions();
    nbRequests = MessagingDatabase().getNbRequests();
    nbViews = MessagingDatabase().getNbViews();
  }

  /// Set the number of messaging elements.
  Future<void> setCounts({
    int nbDiscussions,
    int nbRequests,
    int nbViews,
  }) async {
    if (nbDiscussions != null) {
      nbDiscussions = nbDiscussions;
      MessagingDatabase().putNbDiscussions(nbDiscussions);
    }
    if (nbRequests != null) {
      nbRequests = nbRequests;
      MessagingDatabase().putNbRequests(nbRequests);
    }
    if (nbViews != null) {
      nbViews = nbViews;
      MessagingDatabase().putNbViews(nbViews);
    }
    notifyListeners();
  }

  /// Increment or decrement the number of messaging elements.
  Future<void> updateCounts({
    bool discussions = false,
    bool requests = false,
    bool views = false,
    bool increment = false,
    bool decrement = false,
  }) async {
    if (increment && decrement || !increment && !decrement)
      Logger().e('updateNb(): increment & decrement not correctly set');
    if (discussions) {
      int updated =
          MessagingDatabase().getNbDiscussions() + (increment ? 1 : -1);
      nbDiscussions = updated;
      MessagingDatabase().putNbDiscussions(updated);
    }
    if (requests) {
      int updated = MessagingDatabase().getNbRequests() + (increment ? 1 : -1);
      nbRequests = updated;
      MessagingDatabase().putNbRequests(updated);
    }
    if (views) {
      int updated = MessagingDatabase().getNbViews() + (increment ? 1 : -1);
      nbViews = updated;
      MessagingDatabase().putNbViews(updated);
    }
    notifyListeners();
  }
}
