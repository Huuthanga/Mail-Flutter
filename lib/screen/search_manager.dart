import 'package:cloud_firestore/cloud_firestore.dart';

class SearchManager {
  static Stream<QuerySnapshot> getSearchResults({
    required String currentFolder,
    required String userId,
    required String searchQuery,
  }) {
    try {
      final collection = FirebaseFirestore.instance.collection('emails');

      // Start building the query based on the selected folder
      Query query = collection
          .where('folder', isEqualTo: currentFolder)
          .where('receiverId', isEqualTo: userId)
          .orderBy('timestamp', descending: true);

      // Apply search filter if there's a search query
      if (searchQuery.isNotEmpty) {
        query = query
            .where('subject', isGreaterThanOrEqualTo: searchQuery)
            .where('subject', isLessThan: searchQuery + 'z')
            .where('body', isGreaterThanOrEqualTo: searchQuery)
            .where('body', isLessThan: searchQuery + 'z');
      }

      // Return the stream of documents
      return query.snapshots();
    } catch (e) {
      print('Error in Firestore query: $e');
      return Stream.empty();
    }
  }
}
