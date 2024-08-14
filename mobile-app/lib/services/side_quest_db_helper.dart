import 'package:sidequests/models/side_quest.dart';

/// Abstract base class for the DB helpers, allowing an easy switch from SWLite to Appwrite or another provider
abstract class SideQuestDBHelper {
  /// Retrieves a list of side quests from the database.
  ///
  /// This function asynchronously fetches side quest documents from the database
  /// and converts them into [SideQuest] objects.
  ///
  /// Returns a [Future] that resolves to a [List] of [SideQuest] objects.
  Future<List<SideQuest>> getSideQuests();

  /// Creates a new side quest in the database.
  ///
  /// This function takes a [name] parameter and creates a new side quest
  /// document in the database with the given name and a default 'complete'
  /// status of false.
  ///
  /// Parameters:
  ///   - [name]: A String representing the name of the side quest.
  ///
  /// Returns:
  ///   A Future<SideQuest> representing the newly created side quest.
  Future<SideQuest> createSideQuest(String name);

  /// Updates the completion status of a SideQuest.
  ///
  /// This method updates the 'complete' field of a SideQuest document in the database.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the SideQuest to be updated.
  /// - [complete]: A boolean value indicating whether the SideQuest is completed or not.
  ///
  /// Returns:
  /// A [Future] that resolves to a [SideQuest] object representing the updated SideQuest.
  ///
  /// Throws:
  /// May throw exceptions related to database operations if the update fails.
  Future<SideQuest> updateSideQuest(String id, bool complete);
}
